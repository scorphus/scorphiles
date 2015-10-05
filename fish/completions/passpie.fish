# passpie completions for Fish Shell

function _passpie_credentials
  grep -EhriIo '[A-Z0-9._%+-]+@[A-Z0-9.-]+(@[A-Z0-9_\-\.]+)?' /Users/pablo/.passpie
end

function _passpie_credential_names
  ls -1 /Users/pablo/.passpie
end

function _passpie_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'passpie' ]
    return 0
  end
  return 1
end

function _passpie_using_command
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

complete -f -c passpie -n '_passpie_needs_command' -a 'add copy remove search update' --description 'Manage a credential'
complete -f -c passpie -n '_passpie_using_command add copy remove search update' -a '(_passpie_credentials)
                                                                  (_passpie_credential_names)' --description 'Credential'

