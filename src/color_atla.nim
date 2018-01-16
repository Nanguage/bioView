import tables
import strutils

type
  Color* = ref object
    fg*: int
    bg*: int

  BaseColor* = ref object
    A*: Color
    T*: Color
    C*: Color
    G*: Color
    N*: Color


proc toTable(base_color: BaseColor): Table[char, Color] =
  result = {
    'A': base_color.A,
    'T': base_color.T,
    'C': base_color.C,
    'G': base_color.G,
    'N': base_color.N,
  }.toTable()


proc colorize*(str_in:string|char, color_fg, color_bg: int): string =
  result = "\e[38;5;" & $color_fg & "m" & "\e[48;5;" & $color_bg & "m" & str_in & "\e[0m"


proc colorize*(str_in:string|char, color:Color): string =
  let color_fg: int = color.fg
  let color_bg: int = color.bg
  result = "\e[38;5;" & $color_fg & "m" & "\e[48;5;" & $color_bg & "m" & str_in & "\e[0m"


proc colorize*(str_in:string|char, color_fg: int): string =
  result = "\e[38;5;" & $color_fg & "m" & str_in & "\e[0m"


proc colorize*(str_in:string|char, color_bg: int): string =
  result = "\e[48;5;" & $color_bg & "m" & str_in & "\e[0m"
  

proc colorize_seq*(seq_str:string, base_color:BaseColor): string =
  result = ""
  var colored: string
  var color_map: Table[char, Color] = base_color.toTable()
  var newbase: char
  for base in seq_str:
    if base.toUpperAscii() in {'A', 'T', 'C', 'G'}:
      newbase = base.toUpperAscii()
    else:
      newbase = 'N'
    let color = color_map[newbase]
    let color_bg = color.bg
    let color_fg = color.fg

    if color_bg < 0:
      colored = base.colorize(color_fg=color_fg)
    elif color_fg < 0:
      colored = base.colorize(color_bg=color_bg)
    else:
      colored = base.colorize(color_fg=color_fg, color_bg=color_bg)
    result.add(colored)


proc print_color_atla*(num_per_line:int=10) =
  #[
    print color atla to console.
  ]#
  proc print_colors(fgbg:string) =
    var color_block: string
    for color in 0..255:
      if fgbg == "fg":
        color_block = ("  " & ($color).align(3) & "  ").colorize(color_fg=color)
      else:
        color_block = ("  " & ($color).align(3) & "  ").colorize(color_bg=color)
      stdout.write(color_block)
      if (color + 1) %% num_per_line == 0:
        stdout.write("\n")
    stdout.write("\n")

  echo("Color code:")
  echo()
  echo("Forground:".colorize(color_fg=16, color_bg=255))
  print_colors(fgbg="fg")
  echo()
  echo("Background:".colorize(color_fg=16, color_bg=255))
  print_colors(fgbg="bg")
