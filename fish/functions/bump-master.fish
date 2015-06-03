function bump-master -d 'Add a commit to master and push it to origin'
    set date_now (date)
    gsed -i "s/Date: .*\$/Date: $date_now/" README.md
    git diff
    git add README.md
    git commit -m 'bump to master'
    echo 'Bumping...'
    time git push origin master
end
