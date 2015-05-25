function lss --description "Show more detailed 'ls' output"
    if [ (uname) = "Darwin" ]
        gls -lah --classify --color=always $argv | less -XRF
    else
        ls -lah --classify --color=always $argv | less -XRF
    end
end
