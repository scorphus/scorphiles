function gpip -d "Globoi's artifactory-aware pip"
    if test (count $argv) -ge 2
        if test $argv[1] = 'install'
            set trusted_host_a "--trusted-host" "pypi.globoi.com"
            set trusted_host_b "--trusted-host" "artifactory.globoi.com"
            pip --version | awk '{print $2}' | read -l pip_version
            if [ "$pip_version" = "1.5.6" ]
                set -e trusted_host_a
                set -e trusted_host_b
            end
            pip install \
                --allow-external \
                --allow-unverified \
                --process-dependency-links \
                --index-url=https://artifactory.globoi.com/artifactory/api/pypi/pypi/simple \
                --extra-index-url=https://artifactory.globoi.com/artifactory/api/pypi/pypi/simple/ \
                --extra-index-url=https://artifactory.globoi.com/artifactory/api/pypi/pypi-all/simple/ \
                --extra-index-url=https://artifactory.globoi.com/artifactory/api/ipypi/pypi/simple/ \
                --extra-index-url=https://artifactory.globoi.com/artifactory/api/ipypi/pypi-all/simple/ \
                $trusted_host_a $trusted_host_b -U $argv[2..-1]
        else
            echo 'Sorry, we only support `install`, mate :('
            return 1
        end
    else
        echo 'Wrong arguments number, dude :|'
        return 1
    end
end
