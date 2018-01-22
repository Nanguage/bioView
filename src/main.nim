let doc = """
Command line tool for bioinformatics file format readability enhancement.

Usage:
  bioview fq <file> [--config-file=<config_file>] [--hist=<yes/no>] [--color=<yes/no>] [--phred=<33/64>] [--delimiter=<yes/no>]
  bioview fa <file> [--config-file=<config_file>] [--color=<yes/no>] [--type=<dna/rna/protein>]
  bioview sam <file> [--config-file=<config_file>] [--hist=<yes/no>] [--color=<yes/no>] [--phred=<33/64>]
  bioview color-atla
  bioview example-config
  bioview (-h | --help)

Options:
  -h --help        Show this help information.
  --phred=<33/64>  Quality score encode for fastq file, 33 or 64. [33]
  --hist=<yes/no>  Show quality hist or not. [yes]
  --delimiter=<yes/no> Show fastq record delimiter or not. [yes]
  --color=<yes/no> Show color height light of bases or not. [yes]
  --type=<dna/rna/protein>       The record type of fasta file. [dna]
  --config-file=<config_file>    The path to config file. [~/.config/bioview/config.json]
"""

import os

import docopt

import color_atla
import fastq_utils
import fasta_utils
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
var config: Config
if args["--config-file"]:
  let conf = $args["--config-file"]
  if not existsFile(conf):
    stderr.writeLine("Config file " & conf & " not exist, use default config.")
  config = load_config(conf)
else:
  config = load_config(DEFAULT_CONFIG_PATH)


if (args["fq"]):
  # process fastq file

  case $args["--phred"]
  of "33":
    config.fq_config.phred = 33
  of "64":
    config.fq_config.phred = 64

  case $args["--hist"]:
  of "no":
    config.fq_config.hist.use = false
  of "yes":
    config.fq_config.hist.use = true

  case $args["--color"]:
  of "no":
    config.fq_config.use_color = false
  of "yes":
    config.fq_config.use_color = true

  case $args["--delimiter"]:
  of "no":
    config.fq_config.delimiter.use = false
  of "yes":
    config.fq_config.delimiter.use = true

  process_fastq($args["<file>"], config)

elif (args["fa"]):
  # process fasta file

  case $args["--color"]:
  of "no":
    config.fa_config.use_color = false
  of "yes":
    config.fa_config.use_color = true
  
  case $args["--type"]:
  of "dna":
    config.fa_config.record_type = "dna"
  of "rna":
    config.fa_config.record_type = "rna"
  of "protein":
    config.fa_config.record_type = "protein"

  process_fasta($args["<file>"], config)