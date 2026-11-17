# Tsuru completions for Fish Shell

function __tsuru_apps
  set -l cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ "$cmd[-1]" = "-a" -o "$cmd[-1]" = "--app" ]
      tsuru app-list -q
    end
    if [ "$cmd[-2]" = "-a" -o "$cmd[-2]" = "--app" ]
      tsuru app-list -q -n $cmd[-1]
    end
  end
end

function __tsuru_needs_app
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 2 ]
    if [ "$cmd[-1]" = "-a" -o "$cmd[-2]" = "-a" \
         -o "$cmd[-1]" = "--app" -o "$cmd[-2]" = "--app" ]
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

function __tsuru_completions -a tsuru
  for arg in $argv
    set cmd_txt (expr $arg : '.*\|\(.*\)')
    if [ "$cmd_txt" != "" ]
      set cmd_name (expr $arg : '\(.*\)\|.*')
      complete -c $tsuru -n "__tsuru_needs_cmd" -a $cmd_name -d "$cmd_txt"
    end
  end
end

function __tsuru_extract_command
  tee | egrep "^  " | awk -F ' ' '{
    tsuru_cmd = $1;
    $1 = "";
    print tsuru_cmd "|" $0
  }' | sed 's/| /|/'
end

__tsuru_completions tsuru (tsuru | __tsuru_extract_command)
__tsuru_completions tsuru-admin (tsuru-admin | __tsuru_extract_command)

complete -f -c tsuru -n "__tsuru_needs_app" -a "(__tsuru_apps)" -d "app"
complete -f -c tsuru-admin -n "__tsuru_needs_app" -a "(__tsuru_apps)" -d "app"
