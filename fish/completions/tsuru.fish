# Tsuru completions for Fish Shell

function __add_tsuru_completions -d 'Add Tsuru completions'
    for arg in $argv
        set command_text (expr $arg : '.*\|\(.*\)')
        if test "$command_text" != ''
            set command_name (expr $arg : '\(.*\)\|.*')
            echo "complete -c tsuru -a $command_name -d \"$command_text\""
            complete -c tsuru -a $command_name -d "$command_text"
        end
    end
end

__add_tsuru_completions (tsuru | egrep "^  " | awk -F ' ' '{
    tsuru_cmd = $1;
    $1 = "";
    print tsuru_cmd "|" $0
}' | sed 's/| /|/')
