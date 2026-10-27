function fish_user_key_bindings
  bind \cr 'peco_select_history (commandline -b)'
  bind \e\[1\;5A 'printf "%s" $history[1] | load-buffer'  # Ctrl+Up: copy last command to buffer
  bind \e\[1\;5B 'printf "%s" (commandline) | load-buffer'  # Ctrl+Down: copy current command to buffer
  bind \ey 'paste-buffer'  # Alt+y: paste from buffer
  bind ctrl-h kill-word  # Ctrl+Delete: Ghostty sends ctrl-h for it
  # bind \cS 'mina_paster.sh'
end
