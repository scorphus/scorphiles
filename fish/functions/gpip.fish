function gpip -d "Globoi's artifactory-aware pip"
    if test (count $argv) -ge 2
        if test $argv[1] = 'install'
            pip install \
                --allow-external \
                --allow-unverified \
                --process-dependency-links \
                --trusted-host pypi.globoi.com \
                --trusted-host artifactory.globoi.com \
                --index-url=https://artifactory.globoi.com/artifactory/api/pypi/pypi/simple \
                --extra-index-url=https://artifactory.globoi.com/artifactory/api/pypi/pypi/simple/ \
                --extra-index-url=https://artifactory.globoi.com/artifactory/api/pypi/pypi-all/simple/ \
                -U $argv[2..-1]
        else
            echo 'Sorry, we only support `install`, mate :('
            return 1
        end
    else
        echo 'Wrong arguments number, dude :|'
        return 1
    end
end
