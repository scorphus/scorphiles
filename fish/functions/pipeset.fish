# https://github.com/fish-shell/fish-shell/issues/159#issuecomment-37057175
function pipeset --no-scope-shadowing -d "Set multiline variable"
    set -l _options
    set -l _variables
    for _item in $argv
        echo 1 $_item
        switch $_item
            case '-*'
                set _options $_options $_item
            case '*'
                set _variables $_variables  $_item
        end
    end
    for _variable in $_variables
        echo 2 $_line
        set $_variable ""
    end
    echo " = = = "
    while read _line
        echo 3 $_line
        for _variable in $_variables
            echo 4 $_variable
            set $_options $_variable $$_variable$_line\n
        end
    end
    return 0
end
