function piplg -d 'Alias to pip list | grep -i xyz'
    pip list ^ /dev/null | grep -i $argv
end
