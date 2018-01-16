let doc = """
Command line tool for bioinformatics file format readability enhancement.

Usage:
  bioview <file> [--file-format=<format>] [--config-file=<config_file>]
  bioview --color-atla
  bioview --example-config
  bioview (-h | --help)

Options:
  -h --help       Show this help information.
  --color-atla    Show color atla.
  --example-config    Print example json config.
  --file-format=<format>    Specify file format. [fastq] | fasta | sam 
  --config-file=<config_file>    The path to config file. default: "~/.config/bioview/config.json"
"""

import docopt

import color_atla
import fastq_utils
import configs

let args = docopt(doc, version = "BioView 0.0.0")

if args["--color-atla"]:
  print_color_atla()
  quit(0)

if args["--example-config"]:
  example_json()
  quit(0)

# write arguments to stderr, for debug
when not defined(release):
  stderr.writeLine("arguments:")
  stderr.write($args & "\n")
  stderr.flushFile()

# parse config
let DEFAULT_CONFIG_PATH = "~/.config/bioview/config.json"
let config = load_config(DEFAULT_CONFIG_PATH)

var input_format: string
if "file-format" in args:
  input_format = $args["file-format"]
else:
  input_format = ""

if (input_format == "") or
   (input_format == "fastq") or
   (input_format == "fq"):
  process_fastq($args["<file>"], config)
