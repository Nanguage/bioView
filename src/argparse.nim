import tables
import parseopt2

type

  ValueKind* = enum
    vkNone,
    vkBool,
    vkStr,

  Value* = object
    case kind*: ValueKind
    of vkNone:
      nil
    of vkBool:
      bool_v: bool
    of vkStr:
      str_v: string


converter to_bool*(v: Value): bool =
  case v.kind
  of vkNone:
    false
  of vkBool:
    v.bool_v
  of vkStr:
    v.str_v != nil and v.str_v.len > 0 


proc val(): Value = Value(kind: vkNone)
proc val(v: bool): Value = Value(kind: vkBool, bool_v: v)
proc val(v: string): Value = Value(kind: vkStr, str_v: v)


proc `$`*(v: Value): string =
  case v.kind
  of vkNone:
    "nil"
  of vkBool:
    $v.bool_v
  of vkStr:
    v.str_v


proc parse_args*(doc: string): Table[string, Value] =

  result = {
    "fq": val(),
    "fa": val(),
    "sam": val(),
    "<file>": val(),
    "color-atla": val(),
    "example-config": val(),

    "--phred": val(),
    "--hist": val(),
    "--delimiter": val(),
    "--multiline": val(),
    "--color": val(),
    "--type": val(),
    "--config-file": val(),
  }.toTable()

  var arg_ct: int = 0

  for kind, key, value in getopt():
    when not defined(release):
      stderr.write(($kind) & " " & ($key) & " " & ($value) & "\n")
      stderr.flushFile()
    case kind
    of cmdArgument:
      case arg_ct:
      of 0:
        case key:
        of "fq":
          result["fq"] = val(true)
        of "fa":
          result["fa"] = val(true)
        of "sam":
          result["sam"] = val(true)
        of "color-atla":
          result["color-atla"] = val(true)
          return result
        of "example-config":
          result["example-config"] = val(true)
          return result
      of 1:
        result["<file>"] = val(key)
      else:
        echo doc
        quit(1)
      inc arg_ct
    of cmdShortOption:
      case key
      of "h":
        echo doc
        quit(0)
      if key == "" and value == "":
        result["<file>"] = val("-")
        inc arg_ct
    of cmdLongOption:
      case key:
      of "h", "help":
        echo doc
        quit(0)
      of "phred":
        result["--phred"] = val(value)
      of "hist":
        result["--hist"] = val(value)
      of "delimiter":
        result["--delimiter"] = val(value)
      of "multiline":
        if value != "":
          result["--multiline"] = val(value)
        else:
          result["--multiline"] = val("yes")
      of "color":
        result["--color"] = val(value)
      of "type":
        result["--type"] = val(value)
      of "config-file":
        result["--config-file"] = val(value)
    of cmdEnd:
      discard
    
  if (not result["fq"]) and (not result["fa"]) and (not result["sam"]) and
     (not result["example-config"]) and (not result["color-atla"]):
    echo doc
    quit(1)


when isMainModule:
  discard