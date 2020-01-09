# bioView

A configurable and easy install command line tool for the readability enhancement of bioinformatic file format: fasta, fastq and sam file.

![title](./example/imgs/title.png)

## Installation

This tools is writen in Nim, it can be compiled to a single excutable file.
So, it is very easy to install, just download the [released](https://github.com/Nanguage/bioView/releases) excutable file, and add it to your PATH.

### Shell configuration

For ease of use, you can append the configuration to your shell config file.

* For Bash shell: [bash config](./shell_config/bash_config.bash)
* For Fish shell: [fish config](./shell_config/fish_config.fish)

## Usage

```
Usage:
  bioview fq <file> [--config-file=<config_file>] [--hist=<yes/no>] [--color=<yes/no>] [--phred=<33/64>] [--delimiter=<yes/no>]
  bioview fa <file> [--config-file=<config_file>] [--color=<yes/no>] [--type=<dna/rna/protein>]
  bioview sam <file> [--config-file=<config_file>] [--hist=<yes/no>] [--color=<yes/no>] [--phred=<33/64>] [--multiline=<yes/no>]
  bioview color-atla
  bioview example-config
  bioview (-h | --help)
```

### Example:

View fastq file:

``` bash
$ bioview fq example.fq | less -rS
```

View fasta file:

``` base
$ bioview fa example_dna.fa | less -rS
```

View fasta file(protein record):

``` bash
$ bioview fa example_protein.fa | less -rS
```

View sam file:

``` bash
$ bioview sam example_sam.sam | less -rS
```

View sam file(multiline format):

``` bash
$ bioview sam example_sam.sam --multiline | less -rS
```

Use '-' to read from stdin:

``` bash
$ samtools view -h example.bam | bioview sam - | less -rS
```

### bio-less

Use the `bio-less` function defined in the [shell configuration](./shell_config/bash_config.bash), it let you use bioView more conveniently.

```
Usage:
  bio-less <*.fq/*.fa/*.sam/*.bam>
  fq-less <*.fq>
  fa-less <*.fa>
  sam-less <*.sam>
```

For example:

``` bash
$ bio-less example.fq
```

This is equal to: `bioview fq example.fq | less -rS`

```
$ fq-less example.fq # equal to `bioview fq example.fq | less -rS`
$ samtools view -h example.bam | sam-less - # equal to `samtools view -h example.bam | bioview sam - | less -rS`
```

## Theme

Provide different themes you can choise.

### simple (default)

### verbose

### emoji

[see more](./theme/README.md).

## Make your own theme

You can make your own theme through the config file.

Just generate the config templete, and edit it:

``` bash
$ mkdir -p ~/.config/bioview/config.json
$ bioview example-config > ~/.config/bioview/config.json
$ vim ~/.config/bioview/config.json
```

### Color

The `color` fields used to specify the color of related item, for example the `base color` denote the color of base(ATCG),
and the `fq_config::hist::color` denote the color of histogram in the fastq view. The `fg` and `bg` field means the color
code of the forground color and the background color. You can query the color code through the command:

``` bash
$ bioview color-atla
```

It will list all supported forground color and background color. like:

![color-atla](./example/imgs/color_atla.png)

And use the code `-1` denote the "non-color".

### Histogram

The `fq_config::hist` and `sam_config::hist` fields used to specify the color and symbols of the histogram.

default histogram symbols:
```
▁▁▁▁▁▁▁▁▂▂▂▂▂▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇██████
```

You can also use other symbols, like the emoji:
```
👿👿👿👿👿😫😫😫😫😫🙁🙁🙁🙁🙁😣😣😣😣😣🙃🙃🙃🙃🙃😑😑😑😑😑🙂🙂🙂🙂🙂😃😃😃😃😃
```

For align histogram with the base correctly, you should specify the `hist::align` field.

## Development

This project is written by [Nim](https://nim-lang.org/), and tested under unix-like system environment. 
You need [install Nim](https://nim-lang.org/install.html) firstly.

### Compile the code

Compilation:

``` bash
$ git clone https://github.com/Nanguage/bioView.git
$ cd bioView
$ mkdir bin
$ nim c -d:release -o:./bin/bioview src/main.nim
```

Unit test:

``` bash
$ ./test.sh # test all moudles
$ ./test.sh fastq_utils # test the fastq_utils.nim moudle
```
## TODO
+ upport other file format:
    * GTF/GFF
    * PDB
    * VCF
    * BED/BedGraph/BEDPE
+ Fix the color show bug with `less`.
