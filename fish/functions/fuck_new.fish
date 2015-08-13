function fuck_new -d 'Correct your previous console command'
    set -l TF_ALIAS fuck_new
    set -l exit_code $status
    set -l fucked_up_command $history[1]
    echo "Trying to unfuck $fucked_up_command"
    set -l unfucked (command thefuck $fucked_up_command ^/dev/null)
    if [ "$unfucked" != "" ]
        echo "Got $unfucked"
        read -l -p "echo '$unfucked (enter/ctrl+c) '" doit
        if test "$doit" = ""
            eval $unfucked
            if test $exit_code -ne 0
                history --delete $fucked_up_command
                history --merge
                return 0
            end
        end
    else
        echo "No fucks given"
    end
end
