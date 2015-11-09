function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
  bind \e\e 'fuck-command-line'
  bind \[1\;5A 'echo -n $history[1] | pbcopy'
  bind \[1\;5B 'commandline -r (pbpaste)'
end
