function pip-publish -d "Show working dir status and publish a python package"
    function _gpublish_git_dirty
      echo (command git status -s --ignore-submodules=dirty ^/dev/null)
    end

    if test ! -e setup.py
        echo "I can't issue a publish here, there's no setup.py to work with!"
        return 1
    end

    echo "Package:" (command python setup.py --name --version)

    if [ (_gpublish_git_dirty) ]
        echo 'Your working directory is dirty! Look:'
        command git status
    end

    read -l -p "echo 'Proceed with publish? (y/N) '" doit
    if test "$doit" = "y"
        python setup.py sdist upload $argv
    else
        echo "Giving up..."
    end
end
