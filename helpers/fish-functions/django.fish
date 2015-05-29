function fix_pip_dependencies
    gpip install menu_designer
    gpip install globo_foto
    gpip install freezegun
    gpip install 'pymongo==2.8.1'
end

function kill_test_server
    ps ax | grep 8000 | grep python | awk '{print $1}' | xargs kill
end

function clean_pycs
    find . -name '*.pyc' -delete
end

function run_test_server -d 'make -n clean_pycs run_test_server'
    kill_test_server
    clean_pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py runserver 0.0.0.0:8000 \
        --settings=testproject.settings_IGNOREME
end

function run_event -d 'Usage: run_event <uuid> <event>'
    clean_pycs
    set -l PYTHONPATH "$PYTHONPATH:."
    python -u tests/testproject/manage.py run_event -p $argv[1] -a $argv[2] \
        --settings=testproject.settings_IGNOREME
end
