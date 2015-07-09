function pipfg -d 'Alias to pip freeze | grep -i xyz'
    pip freeze ^ /dev/null | grep -i $argv
end
