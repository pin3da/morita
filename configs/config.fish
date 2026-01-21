# Fish configuration for Raspberry Pi

function mkcd
    mkdir $argv
    cd $argv[1]
end

mise activate fish | source
