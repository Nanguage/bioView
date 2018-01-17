let doc = """
Command line tool for bioinformatics file format readability enhancement.

Usage:
  bioview fq <file> [--config-file=<config_file>] [--hist=<yes/no>] [--color=<yes/no>]
  bioview color-atla
  bioview example-config
  bioview (-h | --help)

Options:
  -h --help        Show this help information.
  --hist=<yes/no>  Show quality hist or not. [yes]
  --color=<yes/no> Show color height light or not. [yes]
  --config-file=<config_file>    The path to config file. [~/.config/bioview/config.json]
"""

import docopt

import color_atla
import fastq_utils
import configs

let args = docopt(doc, version = "BioView 0.0.0")

if args["color-atla"]:
  print_color_atla()
  quit(0)

if args["example-config"]:
  example_json()
  quit(0)

# write arguments to stderr, for debug
when not defined(release):
  stderr.writeLine("arguments:")
  stderr.write($args & "\n")
  stderr.flushFile()

# parse config
let DEFAULT_CONFIG_PATH = "~/.config/bioview/config.json"
var config = load_config(DEFAULT_CONFIG_PATH)


if (args["fq"]):
  # process fastq file

  if $args["--hist"] == "no":
    config.fq_config.hist = false
  elif $args["--hist"] == "yes":
    config.fq_config.hist = true

  if $args["--color"] == "no":
    config.fq_config.base_color = false
  elif $args["--hist"] == "yes":
    config.fq_config.base_color = true

  process_fastq($args["<file>"], config)
