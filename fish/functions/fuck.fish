function fuck -d 'Correct your previous console command'
    set -l TF_ALIAS fuck
    set -l exit_code $status
    set -l fucked_up_command $history[1]
    thefuck $fucked_up_command | read unfucked
    eval $unfucked
    if test $exit_code -ne 0
        history --delete $fucked_up_command
        history --merge
        return 0
    end
end
