# TheFuck by way of changing the command line

function __fuck_complete
    set -x TF_ALIAS fuck
    set -x THEFUCK_REQUIRE_CONFIRMATION False
    set -l fucked_up_command $history[1]
    thefuck $fucked_up_command | read unfucked_command
    if [ "$unfucked_command" != "" ]
        commandline -r $unfucked_command
    else
        commandline -r ""
    end
end

complete -x -c fuck -a "(__fuck_complete)" -d "Unfuck"
