function gpip15 -d "Globoi's artifactory-aware pip v1.5"
    if test (count $argv) -ge 2
        if test $argv[1] = 'install'
            pip install \
                --allow-external \
                --allow-unverified \
                --process-dependency-links \
                --index-url=http://artifactory.globoi.com/artifactory/api/pypi/pypi-all/simple/ \
                --extra-index-url=http://artifactory.globoi.com/artifactory/api/pypi/pypi/simple/ \
                --extra-index-url=http://artifactory.globoi.com/artifactory/api/pypi/pypi/simple/ \
                --extra-index-url=http://artifactory.globoi.com/artifactory/api/pypi/pypi-all/simple/ \
                --extra-index-url=http://artifactory.globoi.com/artifactory/api/ipypi/pypi/simple/ \
                --extra-index-url=http://artifactory.globoi.com/artifactory/api/ipypi/pypi-all/simple/ \
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
