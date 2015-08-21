function pip-uninstall-all -d 'Uninstall all pip modules'
    set -l read_prompt ""
    if test "$VIRTUAL_ENV" = ""
        set read_prompt "We are NOT in a virtualenv, proceed (y/N)? "
    else
        set read_prompt "We are in "(basename $VIRTUAL_ENV)", proceed (y/N)? "
    end
    read -l -p "echo '$read_prompt'" doit
    if test "$doit" = "y"
        for package in (pip list | egrep -iv 'pip' | awk '{print $1}')
            echo -n "uninstalling $package... "
            pip uninstall -q $package -y
            echo " ...done!"
        end
        pip install -U pip
        pip install -U setuptools
    end
end
