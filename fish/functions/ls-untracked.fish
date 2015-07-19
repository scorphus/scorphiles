function ls-untracked -d 'List all files and directories untracked by Git'
    git clean -fd --dry-run | sed s/^Would\ remove\ //
end
