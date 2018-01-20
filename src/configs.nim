import os
import json
import unicode

from color_atla import Color, BaseColor, FqIdPartsColors

type
  FqIdentifier* = object
    color*: Color
    parse_parts*: bool
    parts_colors*: FqIdPartsColors

  Delimiter* = object
    str*: string
    len*: int
    color*: Color

  FastqConfig* = object
    phred*: int
    base_color*: bool
    use_hist*: bool
    hist_symbols*: string
    identifier*: FqIdentifier
    use_delimiter*: bool
    delimiter*: Delimiter
  
  FastaConfig* = object
    base_color*: bool
  
  SamConfig* = object
    phred*: int
    base_color*: bool
    use_hist*: bool
    hist_symbols*: string

  Config* = object
    base_color*: BaseColor
    fq_config*: FastqConfig
    fa_config*: FastaConfig
    sam_config*: SamConfig


let default_json_str* = """
  {
    "base_color": 
    {
      "A": {"fg":196, "bg":-1},
      "T": {"fg":50 , "bg":-1},
      "C": {"fg":226, "bg":-1},
      "G": {"fg":82 , "bg":-1},
      "N": {"fg":-1,  "bg":-1}
    },

    "fq_config":
    {
      "phred": 33,
      "base_color": true,

      "use_hist": true,
      "hist_symbols": 
      "▁▁▁▁▁▁▁▁▂▂▂▂▂▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇██████",

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

      "use_delimiter": true,
      "delimiter": {
        "str": "-",
        "len": 150,
        "color": {"fg": -1, "bg": -1}
      }

    },

    "fa_config":
    {
      "base_color": true
    },

    "sam_config":
    {
      "phred": 33,
      "base_color": true,
      "use_hist": true,
      "hist_symbols": 
      "▁▁▁▁▁▁▁▁▂▂▂▂▂▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇██████"
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

  let hist_symbols: string = config.fq_config.hist_symbols
  doAssert(hist_symbols.len() / 3 == 44)