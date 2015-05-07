function gpip -d "Globoi's artifactory-aware pip"
    if test (count $argv) -eq 2
        if test $argv[1] = 'install'
            echo $argv[2]
            pip install \
                --allow-external \
                --allow-unverified \
                --process-dependency-links \
                --index-url=http://artifactory.globoi.com/artifactory/api/pypi/pypi/simple \
                --extra-index-url=http://artifactory.globoi.com/artifactory/api/pypi/pypi/simple/ \
                --extra-index-url=http://artifactory.globoi.com/artifactory/api/pypi/pypi-all/simple/ \
                -U $argv[2]
        else
            echo 'Sorry, we only support `install`, mate :('
            return 1
        end
    else
        echo 'Too many arguments, dude :|'
        return 1
    end
end
