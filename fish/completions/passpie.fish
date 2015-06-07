# passpie completions for Fish Shell

function __fish_passpie_credentials
  grep -Ehrio '[A-Z0-9._%+-]+@[A-Z0-9.-]+(@[A-Z0-9_\-\.]+)?' /Users/pablo/.passpie
end

function __fish_passpie_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'passpie' ]
    return 0
  end
  return 1
end

function __fish_passpie_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    for arg in $argv
      if [ $arg = $cmd[2] ]
        return 0
      end
    end
  end
  return 1
end

complete -f -c passpie -n '__fish_passpie_needs_command' -a 'add copy remove update' --description 'Manage a credential'
complete -f -c passpie -n '__fish_passpie_using_command add copy remove update' -a '(__fish_passpie_credentials)' --description 'Credential'

