function rm-untracked -d 'Remove all files and directories untracked by Git'
    git clean -fd --dry-run | sed s/^Would/Will/
    read --prompt="echo 'Remove ALL these files/directories (y/N)? '" doit
    if test "$doit" = "y" -o "$doit" = "Y"
        git clean -fd
    end
end
