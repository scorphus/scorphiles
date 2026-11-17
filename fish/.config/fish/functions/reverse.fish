function reverse -d 'Reverse a string'
  if [ (count $argv) -gt 0 ]
    switch $argv[1]
    case "-h*" "--h*" "help"
      echo "Usage:"
      echo "  reverse"
      echo "  reverse reverseme"
      echo "  echo reverseme | reverse"
      return 0
    end
    set input $argv
  else
    read -p "echo '> '" input
  end
  echo $input | rev
end
