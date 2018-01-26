import future
import strutils

from configs import Config, SamConfig
from color_atla import colorize, colorize_score, Color, ColorRange, BaseColor


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
  var header_items: seq[HeaderItem]
  for item in items[1..<items.len]:
    let name_val = item.split(":")
    let h_item: HeaderItem = (name:name_val[0], value:name_val[1])
    header_items.add(h_item)
  result = SamHeader(header_type:header_type, items:header_items)


proc to_string(header:SamHeader, type_color: Color, key_color: Color, val_color: Color): string =
  let header_type_str = header.header_type.colorize(type_color)
  let colored_items = lc[ (item.name.colorize(key_color) & ":" & item.value.colorize(val_color) ) | (item <- header.items), string]
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

  var optional_fields: seq[OptionalField]

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
  result = ""


proc process_sam*(fname:string, config:Config) =
  var f: File
  if open(f, fname):
    for line in f.lines:
      if line.startswith("@"):
        let header = parse_header(line)
        let hc = config.sam_config.header_color
        echo header.to_string(hc.header_type, hc.item_key, hc.item_value)
      else:
        let rec = parse_record(line)
        echo rec.to_string(config.base_color, config.sam_config)


when isMainModule:
  discard
