function Helper --argument-names name -d "Load a helper"
    set -l config_path ~/.config/fish
    set -l fish_helpers $config_path/helpers

    if test (count $argv) -ne 1
        echo -ne "Usage: Helper <helper_name>\n"
        echo -ne "\nAvailable helpers:\n"
        for helper in (ls $fish_helpers)
            echo (basename -s .fish $helper)
        end
        return
    end

    if [ -e $fish_helpers/$name.fish ]
        source $fish_helpers/$name.fish
    else
        set_color red
        echo -ne "There is no Helper '$name'.\n"
        set_color normal
        echo $fish_path/helpers/$name.fish
        echo $fish_custom/helpers/$name.fish
    end
end
