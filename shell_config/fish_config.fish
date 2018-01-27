set PATH /path/to/bioview $PATH

function bio-less
    set file $argv[1]
    set --erase argv[1]

    switch $file
        case "*.fq" 
            bioview fq $file $argv | less -S
        case "*.fa"
            bioview fa $file $argv | less -S
        case "*.sam"
            bioview sam $file $argv | less -S
        case "*.bam"
            samtools view -h $file | bioview sam - $argv | less -S
        case "*"
            less -S $file
    end
end

function fq-less
    bioview fq $argv | less -S
end

function fa-less
    bioview fa $argv | less -S
end

function sam-less
    bioview sam $argv | less -S
end