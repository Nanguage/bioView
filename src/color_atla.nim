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
    U*: Color
    N*: Color

  AminoColor* = ref object
    A*: Color
    R*: Color
    N*: Color
    D*: Color
    C*: Color
    E*: Color
    Q*: Color
    G*: Color
    H*: Color
    I*: Color
    L*: Color
    K*: Color
    M*: Color
    F*: Color
    P*: Color
    S*: Color
    T*: Color
    W*: Color
    Y*: Color
    V*: Color

  FqIdPartsColors* = ref object
    instrument*:   Color
    run_id*:       Color
    flowcell_id*:  Color
    tile_number*:  Color
    x_coordinate*: Color
    y_coordinate*: Color
    pair*:         Color
    filtered*:     Color
    control_bits*: Color
    index_seq*:    Color


proc toTable(base_color: BaseColor): Table[char, Color] =
  result = {
    'A': base_color.A,
    'T': base_color.T,
    'C': base_color.C,
    'G': base_color.G,
    'U': base_color.U,
    'N': base_color.N,
  }.toTable()


proc toTable(amino_color: AminoColor): Table[char, Color] =
  result = {
    'A': amino_color.A,
    'R': amino_color.R,
    'N': amino_color.N,
    'D': amino_color.D,
    'C': amino_color.C,
    'E': amino_color.E,
    'Q': amino_color.Q,
    'G': amino_color.G,
    'H': amino_color.H,
    'I': amino_color.I,
    'L': amino_color.L,
    'K': amino_color.K,
    'M': amino_color.M,
    'F': amino_color.F,
    'P': amino_color.P,
    'S': amino_color.S,
    'T': amino_color.T,
    'W': amino_color.W,
    'Y': amino_color.Y,
    'V': amino_color.V,
  }.toTable()


proc colorize*(str_in:string|char, color:Color): string =
  if color.fg < 0 and color.bg >= 0:
    result = "\e[48;5;" & $color.bg & "m" & str_in & "\e[0m"
  elif color.fg >= 0 and color.bg < 0:
    result = "\e[38;5;" & $color.fg & "m" & str_in & "\e[0m"
  elif color.fg >= 0 and color.bg >= 0:
    result = "\e[38;5;" & $color.fg & "m" & "\e[48;5;" & $color.bg & "m" & str_in & "\e[0m"
  else:
    result = $str_in


proc colorize*(str_in:string|char, color_fg, color_bg: int): string =
  result = "\e[38;5;" & $color_fg & "m" & "\e[48;5;" & $color_bg & "m" & str_in & "\e[0m"


proc colorize*(str_in:string|char, color_fg: int): string =
  result = "\e[38;5;" & $color_fg & "m" & str_in & "\e[0m"


proc colorize*(str_in:string|char, color_bg: int): string =
  result = "\e[48;5;" & $color_bg & "m" & str_in & "\e[0m"


proc colorize_seq*(seq_str:string, color:BaseColor|AminoColor): string =
  result = ""
  var colored: string
  let color_map: Table[char, Color] = color.toTable()
  var char_set:set[char] = {}
  for c in color_map.keys():
    char_set.incl(c)

  for base in seq_str:
    if base.toUpperAscii() in char_set:
      let color = color_map[base.toUpperAscii()]
      colored = base.colorize(color)
    else:
      colored = $base
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


when isMainModule:
  let s1 = "attggc"
  var c1 = Color(fg:56, bg:(-1))

  echo s1.colorize(c1)

  c1.fg = -1
  echo s1.colorize(c1)

  c1.fg = -1
  c1.bg = 30
  echo s1.colorize(c1)

  c1.fg = 10
  c1.bg = 20
  echo s1.colorize(c1)