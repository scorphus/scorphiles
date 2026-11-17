# Nosecomplete
#
# https://github.com/alonho/nosecomplete#fish

function __fish_coverage
    set -l file (commandline -ot)
    command nosecomplete $file ^/dev/null | tr ' ' '\n'
end

complete -f -c coverage -a '(__fish_coverage)' -d 'Nosetests'
