set PATH /path/to/bioview $PATH

function bio-less
    set file $argv[1]
    set --erase argv[1]

    switch $file
        case "*.fq" 
            bioview fq $file $argv | less -rS
        case "*.fa"
            bioview fa $file $argv | less -rS
        case "*.sam"
            bioview sam $file $argv | less -rS
        case "*.bam"
            samtools view -h $file | bioview sam - $argv | less -rS
        case "*"
            less -S $file
    end
end

function fq-less
    bioview fq $argv | less -rS
end

function fa-less
    bioview fa $argv | less -rS
end

function sam-less
    bioview sam $argv | less -rS
end