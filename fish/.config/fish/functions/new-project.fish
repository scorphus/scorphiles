function __usage
  echo "Usage:"
  echo "  new-project <project-url-on-github>"
end

function new-project -d "Reverse a string"
  if [ (count $argv) -ne 1 ]
    __usage
  else if [ (count $argv) -gt 0 ]
    switch $argv[1]
    case "-h*" "--h*" "help"
      __usage
      return 0
    end
    set url $argv
    echo $url | grep -q scorphus; and set remote "origin"; or set remote "upstream"
    set project (basename -s .git $url)
    echo Creating $project with $remote origin...
    mkproject $project
    git clone --origin $remote $url .
    echo Done!
  end
end
