function pip_uninstall_all -d 'Uninstall all pip modules'
    set packages (pip list | egrep -iv 'pip|setuptools' | awk '{print $1}')
    for package in $packages
        echo uninstalling $package...
        echo 'y' | pip uninstall -q $package
    end
end
