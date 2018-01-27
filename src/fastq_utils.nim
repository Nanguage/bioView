import strutils

from color_atla import colorize, colorize_seq
from color_atla import Color, BaseColor, FqIdPartsColors
from configs import Config, Delimiter

proc parse_quality*(quality_string:string, phred:int=33): seq[int] =
  assert phred == 33 or phred == 64
  result = @[]
  var q: int
  for c in quality_string:
    q = ord(c) - phred
    result.add(q) 


proc encode_quality*(quality:seq[int], phred:int=33): string =
  assert phred == 33 or phred == 64
  result = ""
  var c: char
  for q in quality:
    c = chr(q + phred)
    result.add(c)


proc to_hist*(quality:seq[int], hist_symbols:string, symbol_unit_len:int=3): string =
  result = ""
  let slen = symbol_unit_len
  for q in quality:
    let s: int = ord(q) * slen
    let e: int = s + slen - 1
    if s < 0:
      result.add(hist_symbols[0..<slen])
    elif e > hist_symbols.len:
      result.add(hist_symbols[hist_symbols.len-slen ..< hist_symbols.len])
    else:
      result.add(hist_symbols[s..e])


proc add_space*(str:string, unit:int=1, space:int=1): string =
  result = ""
  var i: int = 1
  while i <= str.len:
    result.add(str[i-1])
    if i mod unit == 0:
      result.add(" ".repeat(space))
    inc i


type 
  Identifier = ref object
    instrument:   string
    run_id:       string
    flowcell_id:  string
    tile_number:  string
    x_coordinate: string
    y_coordinate: string
    pair:         string
    filtered:     string
    control_bits: string
    index_seq:    string


proc parse_identifier(name: string): Identifier =
  try:
    let names = name.split(' ')
    let (name1, name2) = (names[0], names[1])
    let part1 = name1.split(':')
    let part2 = name2.split(':')
    result = Identifier(
      instrument:   part1[0],
      run_id:       part1[1],
      flowcell_id:  part1[2],
      tile_number:  part1[3],
      x_coordinate: part1[4],
      y_coordinate: part1[5],
      pair:         part2[0],
      filtered:     part2[1],
      control_bits: part2[2],
      index_seq:    part2[3],
    )
  except:
    result = nil


proc to_string(id:Identifier, color:FqIdPartsColors): string =
  result = 
    id.instrument.colorize(color.instrument) & ":" &
    id.run_id.colorize(color.run_id) & ":" &
    id.flowcell_id.colorize(color.flowcell_id) & ":" &
    id.tile_number.colorize(color.tile_number) & ":" &
    id.x_coordinate.colorize(color.x_coordinate) & ":" &
    id.y_coordinate.colorize(color.y_coordinate) &
    " " &
    id.pair.colorize(color.pair) & ":" &
    id.filtered.colorize(color.filtered) & ":" &
    id.control_bits.colorize(color.control_bits) & ":" &
    id.index_seq.colorize(color.index_seq)


type
  FastqRecord = object
    name: string
    sequence: string
    quality: seq[int]


proc to_string(self:FastqRecord,
               phred:int=33,
               use_color:bool=true,
               hist_symbols:string=nil,
               hist_symbol_unit_len:int=3,
               align:int=1,
               hist_color:Color=nil,
               base_color: BaseColor=nil,
               id_color: Color=nil,
               parts_colors: FqIdPartsColors=nil): string =
  var id_str: string
  var qua_str: string
  var seq_str: string

  # process identifier
  if parts_colors == nil:
    id_str =
      if use_color and id_color != nil:
        self.name.colorize(id_color)
      else:
        self.name
  else:
    let id = self.name.parse_identifier()
    if id != nil and use_color:
      id_str = id.to_string(parts_colors)
    else:
      # not use color or
      # exception occured when parse name to identifier
      id_str = self.name

  # process sequence
  seq_str =
    if align > 1: # align sequence
      self.sequence.add_space(unit=1, space=(align-1))
    else:
      self.sequence

  if use_color and base_color != nil: # colorize sequence
    seq_str = seq_str.colorize_seq(base_color)
  else:
    seq_str = seq_str

  # process quality string
  if hist_symbols == nil:
    qua_str = self.quality.encode_quality(phred=phred)
  else: # use histogram
    qua_str = self.quality.to_hist(hist_symbols, symbol_unit_len=hist_symbol_unit_len)
    if align > 1: # align quality string
      qua_str = qua_str.add_space(unit=hist_symbol_unit_len, space=(align-1))
    if use_color and hist_color != nil: # colorize quality string
      qua_str = qua_str.colorize(color=hist_color)
    
  result = "@" & id_str & "\n" &
    seq_str & "\n" &
    "+\n" &
    qua_str


iterator read_fastq(file:File, phred:int=33): FastqRecord =
  var rec = FastqRecord(name:nil, sequence:nil, quality:nil)
  var line_num = 0
  for line in file.lines:
    inc line_num
    let i = (line_num) %% 4
    case i:
    of 1:
      rec.name = line[1..line.len]
    of 2:
      rec.sequence = line
    of 3:
      continue
    of 0:
      rec.quality = line.parse_quality(phred=phred)
      yield rec
      rec = FastqRecord(name:nil, sequence:nil, quality:nil)


proc to_string*(delimiter: Delimiter): string =
  result = delimiter.str.repeat(delimiter.len).colorize(delimiter.color)


proc process_fastq*(fname: string, config:Config) =
  let phred = config.fq_config.phred
  if phred != 33 and phred != 64:
    raise newException(ValueError, "phred encode must be 33 or 64")
  let use_color = config.fq_config.use_color
  let base_color = if use_color: config.base_color else: nil

  let use_hist = config.fq_config.hist.use
  let hist_symbols = if use_hist: config.fq_config.hist.symbols else: nil
  let hist_color = config.fq_config.hist.color
  let hist_symbol_unit_len = config.fq_config.hist.symbol_unit_len
  let align = config.fq_config.hist.align

  let use_delimiter = config.fq_config.delimiter.use
  let delimiter = config.fq_config.delimiter

  let id_color = config.fq_config.identifier.color
  let parse_parts = config.fq_config.identifier.parse_parts
  let parts_colors = if parse_parts == false: nil else: config.fq_config.identifier.parts_colors

  var f: File
  if fname == "-":
    f = stdin
  else:
    if open(f, fname):
      discard
    else:
      raise newException(IOError, fname & " can not open.")

  if use_delimiter:
    echo delimiter.to_string()
  for rec in read_fastq(f, phred=phred):
    echo rec.to_string(
      hist_symbols=hist_symbols, hist_color=hist_color, hist_symbol_unit_len=hist_symbol_unit_len, align=align,
      use_color=use_color, base_color=base_color, phred=phred,
      id_color=id_color, parts_colors=parts_colors)
    if use_delimiter:
      echo delimiter.to_string()


when isMainModule:
  import configs

  let config = configs.load_config()

  let qua_str_1 = "-AAFFJJJJJJJJJJJJJJJJFJJJFJJJJJJJFJJJJJJJJJJJJFJJJJJ"
  echo qua_str_1

  let qua_1 =  qua_str_1.parse_quality()
  echo $qua_1
  doAssert(qua_1.len() == qua_str_1.len())
  doAssert(qua_1.encode_quality() == qua_str_1)

  let symbols_1 = "▁▁▁▁▁▁▁▁▂▂▂▂▂▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇██████"
  let qua_1_hist = qua_1.to_hist(symbols_1)
  echo qua_1_hist
  doAssert(qua_str_1.len() == int(qua_1_hist.len() / 3))

  echo qua_str_1.add_space(space=1)
  let symbols_2 = "👿👿👿👿👿😫😫😫😫😫🙁🙁🙁🙁🙁😣😣😣😣😣🙃🙃🙃🙃🙃😑😑😑😑😑🙂🙂🙂🙂🙂😃😃😃😃😃"
  let qua_2_hist = qua_1.to_hist(symbols_2, symbol_unit_len=4).add_space(unit=4, space=1)
  echo qua_2_hist


  var i: int = 0
  var f: File = open("example/example.fq")
  for rec in read_fastq(f):
    if i == 0:
      echo rec.to_string(hist_symbols=config.fq_config.hist.symbols)
    if i == 1:
      echo rec.to_string(hist_symbols=config.fq_config.hist.symbols, base_color=config.base_color)
    if i == 2:
      echo rec.to_string(hist_symbols=symbols_2, hist_symbol_unit_len=4, align=2)
    inc i
  f.close()

  let name1 = "@ST-E00126:415:HKVGNALXX:1:1101:2777:1836 1:N:0:GGACTC"
  let id1 = name1.parse_identifier()
  doAssert id1 != nil
  var parts_colors = config.fq_config.identifier.parts_colors
  parts_colors.instrument = Color(fg:10, bg:(-1))
  parts_colors.index_seq = Color(fg:(-1), bg:20)
  echo id1.to_string(parts_colors)