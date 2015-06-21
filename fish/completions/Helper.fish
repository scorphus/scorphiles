# Helper completions for Fish Shell

function __helpers_list
    set -l config_path ~/.config/fish
    set -l fish_helpers $config_path/helpers

    for helper in (ls $fish_helpers)
        echo (basename -s .fish $helper)
    end
end

complete -f -c Helper -a '(__helpers_list)' --description 'Helper'
