import os
import json
import unicode

from color_atla import Color, BaseColor

type
  Config* = object
    base_color*: BaseColor
    hist_symbols*: string

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

    "hist_symbols": 
    "▁▁▁▁▁▁▁▁▂▂▂▂▂▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇██████"
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

  let hist_symbols: string = config.hist_symbols
  doAssert(hist_symbols.len() / 3 == 44)