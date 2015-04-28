function fish_user_key_bindings -d 'bind peco_select_history to ctrl+r'
  bind \cr 'peco_select_history (commandline -b)'
end
