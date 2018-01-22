import os
import json
import unicode

from color_atla import Color, BaseColor, AminoColor, FqIdPartsColors

type
  FqIdentifier* = object
    color*: Color
    parse_parts*: bool
    parts_colors*: FqIdPartsColors

  Hist* = object
    use*: bool
    symbols*: string
    symbol_unit_len*: int
    align*: int
    color*: Color

  Delimiter* = object
    use*: bool
    str*: string
    len*: int
    color*: Color

  FastqConfig* = object
    phred*: int
    use_color*: bool
    use_base_color*: bool
    hist*: Hist
    identifier*: FqIdentifier
    delimiter*: Delimiter

  FastaConfig* = object
    use_color*: bool
    use_base_color*: bool
    record_type*: string
    amino_color*: AminoColor
    identifier_color*: Color
  
  SamConfig* = object
    phred*: int
    use_color*: bool
    use_base_color*: bool
    hist*: Hist

  Config* = object
    base_color*: BaseColor
    fq_config*: FastqConfig
    fa_config*: FastaConfig
    sam_config*: SamConfig


let default_json_str* = """
  {
    "base_color": 
    {
      "A": {"fg": 196, "bg": -1},
      "T": {"fg": 50 , "bg": -1},
      "C": {"fg": 226, "bg": -1},
      "G": {"fg": 82 , "bg": -1},
      "U": {"fg": -1,  "bg": -1},
      "N": {"fg": -1,  "bg": -1}
    },

    "fq_config":
    {
      "phred": 33,

      "use_color": true,
      "use_base_color": true,

      "hist": {
        "use": true,
        "symbols": 
        "▁▁▁▁▁▁▁▁▂▂▂▂▂▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇██████",
        "symbol_unit_len": 3,
        "align": 1,
        "color": {"fg": -1, "bg": -1}
      },

      "identifier": {
        "color": {"fg": -1, "bg": -1},
        "parse_parts": false,
        "parts_colors": {
          "instrument":   {"fg": -1, "bg": -1},
          "run_id":       {"fg": -1, "bg": -1},
          "flowcell_id":  {"fg": -1, "bg": -1},
          "tile_number":  {"fg": -1, "bg": -1},
          "x_coordinate": {"fg": -1, "bg": -1},
          "y_coordinate": {"fg": -1, "bg": -1},
          "pair":         {"fg": -1, "bg": -1},
          "filtered":     {"fg": -1, "bg": -1},
          "control_bits": {"fg": -1, "bg": -1},
          "index_seq":    {"fg": -1, "bg": -1}
        }
      },

      "delimiter": {
        "use": true,
        "str": "-",
        "len": 150,
        "color": {"fg": -1, "bg": -1}
      }

    },

    "fa_config":
    {
      "use_color": true,
      "use_base_color": true,

      "record_type": "dna",

      "amino_color": {
        "A": {"fg": 1, "bg": -1},
        "R": {"fg": 2, "bg": -1},
        "N": {"fg": 3, "bg": -1},
        "D": {"fg": 4, "bg": -1},
        "C": {"fg": 5, "bg": -1},
        "E": {"fg": 6, "bg": -1},
        "Q": {"fg": 7, "bg": -1},
        "G": {"fg": 8, "bg": -1},
        "H": {"fg": 9, "bg": -1},
        "I": {"fg": 10, "bg": -1},
        "L": {"fg": 11, "bg": -1},
        "K": {"fg": 12, "bg": -1},
        "M": {"fg": 13, "bg": -1},
        "F": {"fg": 14, "bg": -1},
        "P": {"fg": 15, "bg": -1},
        "S": {"fg": 16, "bg": -1},
        "T": {"fg": 17, "bg": -1},
        "W": {"fg": 18, "bg": -1},
        "Y": {"fg": 19, "bg": -1},
        "V": {"fg": 20, "bg": -1}
      },

      "identifier_color": {"fg": -1, "bg": -1}
    },

    "sam_config":
    {
      "phred": 33,

      "use_color": true,
      "use_base_color": true,

      "hist": {
        "use": true,
        "symbols": 
        "▁▁▁▁▁▁▁▁▂▂▂▂▂▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇██████",
        "symbol_unit_len": 3,
        "align": 1,
        "color": {"fg": -1, "bg": -1}
      }

    }
  }
"""


proc example_json*() =
  echo(default_json_str)

proc load_from_path(path: string="~/.config/bioview/config.json"): JsonNode =
  parseFile(path)

proc load_config*(path: string=nil): Config =
  var config_json: JsonNode
  if path != nil and existsFile(path):
    config_json = load_from_path(path)
  else:
    config_json = parseJson(default_json_str)
  
  result = to(config_json, Config)


when isMainModule:
  # unit tests

  echo("example config json:")
  example_json()

  let config = load_config()

  let a_color_fg: int = config.base_color.A.fg
  doAssert(a_color_fg == 196)

  let a_color_bg: int = config.base_color.A.bg
  doAssert(a_color_bg == -1)

  let hist_symbols: string = config.fq_config.hist.symbols
  doAssert(hist_symbols.len() / 3 == 44)