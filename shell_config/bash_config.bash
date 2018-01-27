export PATH="/path/to/bioview/:$PATH"

function bio-less {
    file=$1

    if   [[ $file == *.fq ]]; then
        bioview fq $file ${@:2} | less -S
    elif [[ $file == *.fa ]]; then
        bioview fa $file ${@:2} | less -S
    elif [[ $file == *.sam ]]; then
        bioview fa $file ${@:2} | less -S
    elif [[ $file == *.bam ]]; then
        samtools view -h $file | bioview sam - ${@:2} | less -S
    else
        less -S $file
    fi

}

function fq-less {
    bioview fq $@ | less -S
}

function fa-less {
    bioview fq $@ | less -S
}

function sam-less {
    bioview fq $@ | less -S
}