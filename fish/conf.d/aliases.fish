alias clean-pycs='find . -name "*.pyc" -delete'
alias g='git'
alias ls-untracked='git clean -fd --dry-run | sed s/^Would\ remove\ //'
alias lszip='unzip -l $zip | less -XRF'
alias mcd='mkdir -p $argv; and cd'
alias mkdirp='mkdir -p'
alias pythoni='ipython'
alias r!='refresh'
alias rmf='rm -rf'
alias pe='pipenv'

alias http-format='command http --style monokai --pretty=format'
alias http-all='command http --style monokai --pretty=all'
alias http='http --style monokai'

if not test (uname) = Darwin
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
end

alias real-code='/usr/local/bin/code'

alias code='zed'
alias code.='zed .'
alias code,='zed .'
alias c.='zed .'
alias c,='zed .'

alias ip='ipython'

alias decolor='sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g"'

alias lart="la -rt"
alias lar="la -rt"
alias lat="la -rt"
alias lra="la -rt"
alias lrt="la -rt"
alias lr="la -rt"
alias ltr="la -rt"
alias lt="la -rt"

alias hm='history merge'
alias hd='history delete -- (pbpaste )'
