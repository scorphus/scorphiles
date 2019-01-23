alias clean-pycs='find . -name "*.pyc" -delete'
alias g='git'
alias ls-untracked='git clean -fd --dry-run | sed s/^Would\ remove\ //'
alias lszip='unzip -l $zip | less -XRF'
alias mcd='mkdir -p $argv; and cd'
alias mkdirp='mkdir -p'
alias pythoni='ipython'
alias r!='refresh'
alias rmf='rm -rf'
alias subl..='subl ..'
alias subl.='subl .'
alias v='vagrant'

alias http-format='command http --style monokai --pretty=format'
alias http-all='command http --style monokai --pretty=all'
alias http='http --style monokai'

if not test (uname) = Darwin
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
end
