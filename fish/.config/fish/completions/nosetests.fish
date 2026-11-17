# Nosecomplete
#
# https://github.com/alonho/nosecomplete#fish

function __fish_nosetests
    set -l file (commandline -ot)
    command nosecomplete $file ^/dev/null | tr ' ' '\n'
end

complete -f -c nosetests -a '(__fish_nosetests)' -d 'Nosetests'
