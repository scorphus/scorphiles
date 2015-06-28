function fix_pip_dependencies
    gpip install \
         beautifulsoup4 \
         freezegun \
         globo_foto \
         menu_designer \
         pymongo\<3 \
         widgetssi
end

function kill_test_server
    ps ax | grep 8000 | grep python | awk '{print $1}' | xargs kill
end

function run_test_server -d 'make -n clean_pycs run_test_server'
    kill_test_server
    clean-pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py runserver 0.0.0.0:8000 \
        --settings=testproject.settings_IGNOREME
end

function run_event -d 'Usage: run_event <uuid> <event>'
    clean-pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py run_event -p $argv[1] -a $argv[2] \
        --settings=testproject.settings_IGNOREME
end

function run_test_server_no_reload -d 'make -n clean_pycs run_test_server'
    kill_test_server
    clean-pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py runserver 0.0.0.0:8000 \
        --settings=testproject.settings_IGNOREME --noreload
end

function cleanup -d 'Clean pycs, reset installed_test'
    clean-pycs
    rmf tests/testproject/components/installed_test
    mkdirp tests/testproject/components/installed_test
end

function nosetests-unit -a verbosity -d 'Run nosetests unit tests'
    cleanup
    set -x REUSE_DB "1"
    coverage run tests/testproject/manage.py test tests/ \
        --settings=testproject.settings_test \
        --with-yanc --yanc-color=yes $verbosity
    if test $status -eq 0
        coverage report -m --fail-under=65
    end
end

function nosetests-unit-v -d 'Run nosetests unit tests verbosely'
    nosetests-unit --verbosity=2
end

function nosetests-focus -a verbosity -d 'Run nosetests focused tests'
    cleanup
    set -x REUSE_DB "1"
    coverage run tests/testproject/manage.py test tests/ \
        --settings=testproject.settings_test_focus \
        --with-yanc --yanc-color=yes --ipdb --ipdb-failures $verbosity
end

function nosetests-focus-v -d 'Run nosetests focused tests verbosely'
    nosetests-focus --verbosity=2
end

function nosetests-focus-ignore -a verbosity -d 'Run nosetests ignoring focus-ignored tests'
    clean-pycs
    set -x REUSE_DB "1"
    coverage run tests/testproject/manage.py test tests/ \
        --settings=testproject.settings_test_focus_ignore \
        --with-yanc --yanc-color=yes $verbosity
end

function nosetests-focus_ignore-v -d 'Run nosetests ignoring focus-ignored tests verbosely'
    nosetests-ignore --verbosity=2
end
