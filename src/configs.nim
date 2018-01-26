import os
import json
import unicode

import color_atla

type
  FqIdentifier* = ref object
    color*: Color
    parse_parts*: bool
    parts_colors*: FqIdPartsColors

  Hist* = ref object
    use*: bool
    symbols*: string
    symbol_unit_len*: int
    align*: int
    color*: Color

  Delimiter* = ref object
    use*: bool
    str*: string
    len*: int
    color*: Color

  FastqConfig* = ref object
    phred*: int
    use_color*: bool
    use_base_color*: bool
    hist*: Hist
    identifier*: FqIdentifier
    delimiter*: Delimiter

  FastaConfig* = ref object
    use_color*: bool
    use_base_color*: bool
    record_type*: string
    amino_color*: AminoColor
    identifier_color*: Color

  SamHeader* = ref object
    header_type*: Color
    item_key*: Color
    item_value*: Color

  SamOptionalFields* = ref object
    tag*: Color
    field_type*: Color
    value*: Color
  
  SamConfig* = ref object
    phred*: int
    multiline*: bool
    delimiter*: Delimiter
    use_color*: bool
    header_color*: SamHeader
    qname_color*: Color
    flag_color*: Color
    rname_color*: Color
    mapq_color_range*: ColorRange
    cigar_color*: Color
    rnext_color*: Color
    pnext_color*: Color
    tlen_color*: Color
    optional_fields: SamOptionalFields 
    use_base_color*: bool
    hist*: Hist

  Config* = ref object
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

      "multiline": false,

      "delimiter": {
        "use": true,
        "str": "-",
        "len": 150,
        "color": {"fg": -1, "bg": -1}
      },

      "header_color": {
        "header_type": {"fg": -1,  "bg": -1},
        "item_key":    {"fg": 202, "bg": -1},
        "item_value":  {"fg": 202, "bg": -1}
      },

      "qname_color": {"fg": -1, "bg": -1},
      "flag_color":  {"fg": -1, "bg": -1},
      "rname_color": {"fg": -1, "bg": -1},
      "pos_color":   {"fg": -1, "bg": -1},

      "mapq_color_range": {
        "buttom": {"val":0,  "color": {"fg": -1, "bg": -1}},
        "top":    {"val":30, "color": {"fg": -1, "bg": -1}},
      },

      "cigar_color": {"fg": -1, "bg": -1},
      "rnext_color": {"fg": -1, "bg": -1},
      "pnext_color": {"fg": -1, "bg": -1},
      "tlen_color":  {"fg": -1, "bg": -1},

      "optional_fields_color": {
        "tag": {"fg": -1, "bg": -1},
        "field_type": {"fg": -1, "bg": -1},
        "value": {"fg": -1, "bg": -1}
      },

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