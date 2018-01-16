from color_atla import colorize_seq
from color_atla import BaseColor
from configs import Config

proc parse_quality(quality_string:string, phred:int=33): seq[int] =
  assert phred == 33 or phred == 64
  result = @[]
  var q: int
  for c in quality_string:
    q = ord(c) - phred
    result.add(q) 


proc encode_quality(quality:seq[int], phred:int=33): string =
  assert phred == 33 or phred == 64
  result = ""
  var c: char
  for q in quality:
    c = chr(q + phred)
    result.add(c)


proc to_hist(quality:seq[int], hist_symbols:string, symbol_unit_len:int=3): string =
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


type
  FastqRecord = object
    name: string
    sequence: string
    quality: seq[int]


proc to_string(self:FastqRecord, hist_symbols:string=nil,
               base_color: BaseColor=nil): string =
  var qua_str: string
  var seq_str: string

  if hist_symbols == nil:
    qua_str = self.quality.encode_quality()
  else:
    qua_str = self.quality.to_hist(hist_symbols)

  if base_color != nil:
    seq_str = self.sequence.colorize_seq(base_color)
  else:
    seq_str = self.sequence

  result = "@" & self.name & "\n" &
    seq_str & "\n" &
    "+\n" &
    qua_str & "\n"


iterator read_fastq(file:File): FastqRecord =
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
      rec.quality = line.parse_quality()
      yield rec
      rec = FastqRecord(name:nil, sequence:nil, quality:nil)


proc process_fastq*(fname: string, config:Config) =
  let base_color = config.base_color
  let hist_symbols = config.hist_symbols
  var f: File
  if open(f, fname):
    for rec in read_fastq(f):
      echo rec.to_string(hist_symbols=hist_symbols, base_color=base_color)


when isMainModule:
  import configs

  let config = configs.load_config()

  let qua_str_1 = "-AAFFJJJJJJJJJJJJJJJJFJJJFJJJJJJJFJJJJJJJJJJJJFJJJJJ"
  echo qua_str_1

  let qua_1 =  qua_str_1.parse_quality()
  echo $qua_1
  doAssert(qua_1.len() == qua_str_1.len())
  doAssert(qua_1.encode_quality() == qua_str_1)

  let qua_1_hist = qua_1.to_hist(config.hist_symbols)
  echo qua_1_hist
  doAssert(qua_str_1.len() == int(qua_1_hist.len() / 3))

  var i: int = 0
  var f: File = open("example/example.fq")
  for rec in read_fastq(f):
    if i == 0:
      echo rec.to_string(hist_symbols=config.hist_symbols)
    if i == 1:
      echo rec.to_string(hist_symbols=config.hist_symbols, base_color=config.base_color)
    inc i
  f.close()