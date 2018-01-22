import strutils

from color_atla import colorize, colorize_seq
from configs import Config

proc process_fasta*(fname:string, config:Config) =
  let record_type = config.fa_config.record_type

  let use_color = config.fa_config.use_color
  let use_base_color = config.fa_config.use_base_color
  let id_color  = config.fa_config.identifier_color
  let base_color = config.base_color
  let amino_color = config.fa_config.amino_color

  var f: File
  if open(f, fname):
    for line in f.lines:
      if line.startsWith('>'): # identifier line
        if use_color:
          echo line.colorize(id_color)
        else:
          echo line
      else:
        if use_color and use_base_color:
          let colored = 
            if record_type.toUpperAscii == "PROTEIN":
              line.colorize_seq(amino_color)
            else:
              line.colorize_seq(base_color)
          echo colored
        else:
          echo line

when isMainModule:
  discard
