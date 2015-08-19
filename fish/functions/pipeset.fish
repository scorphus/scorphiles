# https://github.com/fish-shell/fish-shell/issues/159#issuecomment-37057175
function pipeset --no-scope-shadowing -d "Set a multi-line variable from stdin"
    set -l _options
    set -l _variables
    for _item in $argv
        switch $_item
            case '-*'
                set _options $_options $_item
            case '*'
                set _variables $_variables  $_item
        end
    end
    for _variable in $_variables
        set $_variable ""
    end
    while read _line
        for _variable in $_variables
            set $_options $_variable $$_variable$_line\n
        end
    end
    return 0
end
