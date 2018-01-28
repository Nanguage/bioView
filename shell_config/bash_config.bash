export PATH="/path/to/bioview/:$PATH"

function bio-less {
    file=$1

    if   [[ $file == *.fq ]]; then
        bioview fq $file ${@:2} | less -rS
    elif [[ $file == *.fa ]]; then
        bioview fa $file ${@:2} | less -rS
    elif [[ $file == *.sam ]]; then
        bioview sam $file ${@:2} | less -rS
    elif [[ $file == *.bam ]]; then
        samtools view -h $file | bioview sam - ${@:2} | less -rS
    else
        less -S $file
    fi

}

function fq-less {
    bioview fq $@ | less -rS
}

function fa-less {
    bioview fa $@ | less -rS
}

function sam-less {
    bioview sam $@ | less -rS
}