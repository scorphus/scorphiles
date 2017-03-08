function set-abbreviations -d "Set default abbreviations"
  abbr -a gcam git commit --amend
  abbr -a gcamn git commit --amend --no-edit
  abbr -a gco git checkout
  abbr -a gcvp git commit -vp
  abbr -a gcvpa git commit -vp --amend
  abbr -a gl git log -40 --branches=* --graph --decorate --abbrev-commit --oneline --all
  abbr -a gla git log -25 --branches=* --graph --decorate --abbrev-commit --oneline --all
  abbr -a glaa git log --branches=* --graph --decorate --abbrev-commit --oneline --all
  abbr -a gll git log --branches=* --graph --decorate --abbrev-commit
  abbr -a glo git log --branches=* --graph --decorate --abbrev-commit --oneline
  abbr -a gmefom git merge --ff-only origin/master
  abbr -a gmefum git merge --ff-only upstream/master
  abbr -a gmf git merge --ff-only
  abbr -a gpd git push --delete
  abbr -a gpufom git pull --ff-only origin master
  abbr -a gpufum git pull --ff-only upstream master
  abbr -a gpurom git pull --rebase origin master
  abbr -a gpurum git pull --rebase upstream master
  abbr -a gru git remote update
  abbr -a grup git remote update --prune
  abbr -a pbc pbcopy
  abbr -a pbp pbpaste
end
