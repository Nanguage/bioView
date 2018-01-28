import future
import strutils

from configs import Config, SamConfig, Delimiter
from color_atla import colorize, colorize_seq, colorize_score, Color, ColorRange, BaseColor
from fastq_utils import parse_quality, to_hist, encode_quality, add_space, to_string


type

  OptionalField = tuple[tag:string, field_type:string, value:string]

  SamRecord = object
    qname: string
    flag: int
    rname: string
    pos: int
    mapq: int
    cigar: string
    rnext: string
    pnext: int
    tlen: int
    sequence: string
    qual: string
    optional_fields: seq[OptionalField]

  HeaderItem = tuple[name:string, value:string]

  SamHeader = object
    header_type: string
    items: seq[HeaderItem]


proc parse_header(line:string): SamHeader =
  let items = line.split("\t")
  let header_type = items[0][1..<items[0].len]
  var header_items: seq[HeaderItem] = @[]
  for item in items[1..<items.len]:
    let name_val = item.split(":")
    let h_item: HeaderItem = (name:name_val[0], value:name_val[1])
    header_items.add(h_item)
  result = SamHeader(header_type:header_type, items:header_items)


proc to_string(header:SamHeader, type_color: Color, key_color: Color, val_color: Color, use_color: bool): string =
  let header_type_str =
    if use_color:
      header.header_type.colorize(type_color)
    else:
      header.header_type
  var colored_items: seq[string]
  if use_color:
    colored_items = lc[ (item.name.colorize(key_color) & ":" & item.value.colorize(val_color) ) | (item <- header.items), string]
  else:
    colored_items = lc[ (item.name & ":" & item.value ) | (item <- header.items), string ]
  let items_str = join(colored_items, "\t")
  result = "@" & header_type_str & "\t" & items_str


proc parse_record(line:string): SamRecord = 
  let items = line.split("\t")

  let qname = items[0]
  let flag = items[1].parseInt
  let rname = items[2]
  let pos = items[3].parseInt
  let mapq = items[4].parseInt
  let cigar = items[5]
  let rnext = items[6]
  let pnext = items[7].parseInt
  let tlen = items[8].parseInt
  let sequence = items[9]
  let qual = items[10]

  var optional_fields: seq[OptionalField] = @[]

  for item in items[11..<items.len]:
    let t_p_v = item.split(":")
    let field: OptionalField = (tag:t_p_v[0], field_type:t_p_v[1], value:t_p_v[2])
    optional_fields.add(field)
  
  result = SamRecord(
    qname: qname,
    flag:  flag,
    rname: rname,
    pos:   pos,
    mapq:  mapq,
    cigar: cigar,
    rnext: rnext,
    pnext: pnext,
    tlen:  tlen,
    sequence: sequence,
    qual: qual,
    optional_fields: optional_fields,
  )


proc to_string(record:SamRecord, base_color:BaseColor, config:SamConfig): string =
  let rec = record
  var
    qname_str = rec.qname
    flag_str  = rec.flag.intToStr
    rname_str = rec.rname
    pos_str   = rec.pos.intToStr

    mapq  = rec.mapq
    mapq_str: string

    cigar_str = rec.cigar
    rnext_str = rec.rnext
    pnext_str = rec.pnext.intToStr
    tlen_str  = rec.tlen.intToStr
    seq_str = rec.sequence

    optional_str: string

  let qual = rec.qual.parse_quality(phred=config.phred)
  var hist_str =
    if config.hist.use:
      qual.to_hist(config.hist.symbols, config.hist.symbol_unit_len)
    else:
      qual.encode_quality(phred=config.phred)
  
  if config.hist.align > 1:
    seq_str  = seq_str.add_space(unit=1, space=(config.hist.align - 1))
    hist_str = hist_str.add_space(unit=config.hist.symbol_unit_len, space=(config.hist.align - 1))
  
  let ofc = config.optional_fields_color

  if config.use_color:
    qname_str = qname_str.colorize(config.qname_color)
    flag_str  = flag_str.colorize(config.flag_color)
    rname_str = rname_str.colorize(config.rname_color)
    pos_str   = pos_str.colorize(config.pos_color)
    mapq_str  = mapq.colorize_score(config.mapq_color_range)
    cigar_str = cigar_str.colorize(config.cigar_color)
    rnext_str = rnext_str.colorize(config.rnext_color)
    pnext_str = pnext_str.colorize(config.pnext_color)
    tlen_str  = tlen_str.colorize(config.tlen_color)
    if config.use_base_color:
      seq_str   = seq_str.colorize_seq(base_color)
    hist_str  = hist_str.colorize(config.hist.color)

    let optional_items =
      lc[ ( item.tag.colorize(ofc.tag) & ":" & item.field_type.colorize(ofc.field_type) & ":" & item.value.colorize(ofc.value) ) | (item <- rec.optional_fields), string ]
    optional_str = optional_items.join("\t")
  else:
    mapq_str = mapq.intToStr

    let optional_items =
      lc[ ( item.tag & ":" & item.field_type & ":" & item.value ) | (item <- rec.optional_fields), string ]
    optional_str = optional_items.join("\t")

  if not config.multiline:
    result =
      qname_str & "\t" & flag_str  & "\t" & rname_str & "\t" &
      pos_str   & "\t" & mapq_str  & "\t" & cigar_str & "\t" &
      rnext_str & "\t" & pnext_str & "\t" & tlen_str  & "\t" &
      seq_str   & "\t" & hist_str  & "\t" & optional_str
  else:
    result =
      "query_name: " & qname_str & "\t" & "flag: " & flag_str  & "\t" & "ref_name: " & rname_str & "\n" &
      "position: " & pos_str & "\t" & "mapq: " & mapq_str  & "\t" & "cigar: " & cigar_str & "\n" &
      "next: " & rnext_str & "\t" & pnext_str & "\t" & "templete_len: " & tlen_str  & "\n" &
      seq_str   & "\n" & hist_str & "\n" &
      optional_str


proc process_sam*(fname:string, config:Config) =
  var f: File
  if fname == "-":
    f = stdin
  else:
    if open(f, fname):
      discard
    else:
      raise newException(IOError, fname & " can not open.")

  for line in f.lines:

    if line.startswith("@"):
      let header = parse_header(line)
      let hc = config.sam_config.header_color
      echo header.to_string(hc.header_type, hc.item_key, hc.item_value, config.sam_config.use_color)
    else:
      if config.sam_config.delimiter.use:
        echo config.sam_config.delimiter.to_string()
      let rec = parse_record(line)
      echo rec.to_string(config.base_color, config.sam_config)

  if config.sam_config.delimiter.use:
    echo config.sam_config.delimiter.to_string()


when isMainModule:
  import configs
  let config = load_config()
  let sam_conf = config.sam_config

  let header_line_1 = "@SQ	SN:chr1	LN:248956422"
  let header_line_2 = "@PG	ID:bwa	PN:bwa	VN:0.7.15-r1140	CL:bwa samse ./data/BWA_index/genome.fa test_left.bwa hookers_test_left.fq"

  var
    hc = sam_conf.header_color.header_type
    kc = sam_conf.header_color.item_key
    vc = sam_conf.header_color.item_value

  let header_1 = parse_header(header_line_1)
  echo header_1.to_string(hc, kc, vc, true)

  let header_2 = parse_header(header_line_2)
  echo header_2.to_string(hc, kc, vc, true)