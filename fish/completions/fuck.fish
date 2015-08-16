# TheFuck by way of changing the command line

function __fuck_complete
    set -l fucked_up_command $history[1]
    set -l unfucked (thefuck $fucked_up_command ^/dev/null)
    if [ "$unfucked" != "" ]
        commandline -r $unfucked
    else
        commandline -r ""
    end
end

complete -x -c fuck -a "(__fuck_complete)" -d "Unfuck"
