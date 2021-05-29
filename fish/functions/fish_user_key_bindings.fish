function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
  bind \e\[1\;5A 'echo -n $history[1] | pbcopy'
  bind \e\[1\;5B 'echo (commandline) | tr -d "\n" | pbcopy'
  bind \cS 'mina_paster.sh'
end
