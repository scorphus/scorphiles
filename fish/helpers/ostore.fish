function ostore-fix-pip-dependencies
    gpip install \
         beautifulsoup4 \
         django==1.4.13 \
         freezegun \
         globo_foto \
         globocore \
         menu_designer \
         pymongo\<3 \
         widgetssi \
         --upgrade
end

function ostore-kill-test-server
    ps ax | grep 8000 | grep python | awk '{print $1}' | xargs kill
end

function ostore-kill-test-server-2
    ps ax | grep 8002 | grep python | awk '{print $1}' | xargs kill
end

function ostore-run-test-server -d 'make -n clean_pycs run_test_server'
    ostore-kill-test-server
    clean-pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py runserver 0.0.0.0:8000 \
        --settings=testproject.settings_IGNOREME
end

function ostore-run-test-server-2 -d 'make -n clean_pycs run_test_server 2'
    ostore-kill-test-server-2
    clean-pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py runserver 0.0.0.0:8002 \
        --settings=testproject.settings_IGNOREME
end

function ostore-run-event -d 'Run an event'
    if test (count $argv) -lt 2
        echo "Just too bad, you supplied a wrong number of arguments!"
        echo "Usage: ostore-run-event <uuid> <event>"
        echo "Example: ostore-run-event techtudo/ayrton accelerate"
        return 1
    end
    clean-pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    echo python -u tests/testproject/manage.py run_event -p $argv[1] -a $argv[2] \
        --settings=testproject.settings_IGNOREME $argv[3..-1]
    python -u tests/testproject/manage.py run_event -p $argv[1] -a $argv[2] \
        --settings=testproject.settings_IGNOREME $argv[3..-1]
end

function ostore-run-test-server-no-reload -d 'make -n clean_pycs run_test_server'
    ostore-kill-test-server
    clean-pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py runserver 0.0.0.0:8000 \
        --settings=testproject.settings_IGNOREME --noreload
end

function ostore-run-test-server-2-no-reload -d 'make -n clean_pycs run_test_server'
    ostore-kill-test-server-2
    clean-pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py runserver 0.0.0.0:8002 \
        --settings=testproject.settings_IGNOREME --noreload
end

function ostore-tests-cleanup -d 'Clean pycs, reset installed_test'
    clean-pycs
    rmf tests/testproject/components/installed_test
    mkdirp tests/testproject/components/installed_test
end

function ostore-nosetests-unit -a verbosity -d 'Run nosetests unit tests'
    ostore-tests-cleanup
    set -x REUSE_DB "1"
    coverage run tests/testproject/manage.py test tests/ \
        --settings=testproject.settings_test \
        --with-yanc --yanc-color=yes $verbosity
    if test $status -eq 0
        coverage report -m --fail-under=65
    end
end

function ostore-nosetests-unit-v -d 'Run nosetests unit tests verbosely'
    ostore-nosetests-unit --verbosity=2
end

function ostore-nosetests-focus -a verbosity -d 'Run nosetests focused tests'
    ostore-tests-cleanup
    set -x REUSE_DB "1"
    coverage run tests/testproject/manage.py test tests/ \
        --settings=testproject.settings_test_focus \
        --with-yanc --yanc-color=yes --ipdb --ipdb-failures $verbosity
end

function ostore-nosetests-focus-v -d 'Run nosetests focused tests verbosely'
    ostore-nosetests-focus --verbosity=2
end

function ostore-nosetests-focus-ignore -a verbosity -d 'Run nosetests ignoring focus-ignored tests'
    clean-pycs
    set -x REUSE_DB "1"
    coverage run tests/testproject/manage.py test tests/ \
        --settings=testproject.settings_test_focus_ignore \
        --with-yanc --yanc-color=yes $verbosity
end

function ostore-nosetests-focus-ignore-v -d 'Run nosetests ignoring focus-ignored tests verbosely'
    ostore-nosetests-ignore --verbosity=2
end
