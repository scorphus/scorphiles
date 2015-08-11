function pipf -d 'Alias to pip freeze'
    pip freeze | less -XRF
end
