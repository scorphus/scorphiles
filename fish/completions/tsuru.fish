# Tsuru completions for Fish Shell

function __tsuru_apps
  set -l cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ "$cmd[-1]" = "-a" ]
      tsuru app-list -q
    end
    if [ "$cmd[-2]" = "-a" ]
      tsuru app-list -q -n $cmd[-1]
    end
  end
end

function __tsuru_needs_app
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 2 ]
    if [ "$cmd[-1]" = "-a" -o "$cmd[-2]" = "-a" ]
      return 0
    end
  end
  return 1
end

function __tsuru_needs_cmd
  set cmd (commandline -op)
  if [ (count $cmd) -eq 1 -o (count $cmd) -eq 2 ]
    return 0
  end
  return 1
end

function __tsuru_completions
  for arg in $argv
    set cmd_txt (expr $arg : '.*\|\(.*\)')
    if [ "$cmd_txt" != "" ]
      set cmd_name (expr $arg : '\(.*\)\|.*')
      complete -c tsuru -n "__tsuru_needs_cmd" -a $cmd_name -d "$cmd_txt"
    end
  end
end

__tsuru_completions (tsuru | egrep "^  " | awk -F ' ' '{
    tsuru_cmd = $1;
    $1 = "";
    print tsuru_cmd "|" $0
}' | sed 's/| /|/')

complete -f -c tsuru -n "__tsuru_needs_app" -a "(__tsuru_apps)" -d "app"
