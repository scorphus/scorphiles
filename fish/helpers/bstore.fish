function __bstore-sql-query -a api_url -a host -a db -a user -a pass
    set -l sql "
        SELECT id, title, url_slug, secret_key AS secret,
            TO_BASE64(secret_key) AS shared, CONCAT(
                \"curl \", \"-H'X-SECRET-KEYS:\", secret_key, \"' \",
                \"$api_url/api/projects/list/\"
            ) AS projects
        FROM applications\G"
    echo $sql | mysql -u$user -p$pass -h $host $db
end

function bstore-release-component -d "Bump a new release of a component"
    if test (count $argv) -eq 1
        set step $argv[1]
    else
        set step 1
    end

    set -l minor (
        echo (egrep '0\.0\.\d' README.md | awk -F. '{print $NF}' ) + $step | bc
    )

    if [ (uname) = "Darwin" ]
        gsed -ie "s/0\.0\.[0-9]*/0.0.$minor/" README.md
    else
        sed -ie "s/0\.0\.[0-9]*/0.0.$minor/" README.md
    end
    git add README.md
    git commit -am "bump(0.0.$minor): yeah, bump!"
    git tag 0.0.$minor
    git push origin master --tags
end

function bstore-show-apps -a environ -d "Show applications on backstage-store"
    if test "$environ" = "" -o "$environ" = "local"
        __bstore-sql-query http://localhost:2369 localhost backstage_store root
    else
        if [ (uname) != "Darwin" ]
            alias gsed="sed"
        end

        set -l conf_file ~/Workspace/backstage-store/$environ.conf
        set -l ini_file ~/Workspace/backstage-store/alembic.$environ.ini

        set -l api_url (extract_derpconf.py $conf_file STORE_API_URL)
        set -l mysql_url (extract_iniconf.py $ini_file alembic sqlalchemy.url)

        set -l pattern "mysql:\/\/([^:]+):([^@]+)@([^:]+):3306\/(.+)"
        set -l user (echo $mysql_url | gsed -r "s/$pattern/\1/")
        set -l pass (echo $mysql_url | gsed -r "s/$pattern/\2/")
        set -l host (echo $mysql_url | gsed -r "s/$pattern/\3/")
        set -l db (echo $mysql_url | gsed -r "s/$pattern/\4/")

        __bstore-sql-query $api_url $host $db $user $pass | less -XRF
    end
end

function bstore-setup-extra -d "Install extra dependencies"
    pip install -U ipdbplugin
end

function bstore-focus-ipdb -d "Same as make focus but with --ipdb"
    make clear_repositories_test
    coverage run --branch (which nosetests) -vv --with-yanc \
        --with-nosegrowlnotify --logging-level=WARNING --with-focus -i \
        --processes=4 --ipdb --ipdb-failures -s tests/
end

function bstore-focus-ignore-ipdb -d "Same as make focus-ignore but with --ipdb"
    make clear_repositories_test
    @coverage run --branch (which nosetests) -vv --with-yanc \
        --with-nosegrowlnotify --logging-level=WARNING --without-ignored -i \
        --processes=4 --ipdb --ipdb-failures -s tests/
end

function bstore-focus-ipdb-exhaustion -d "Run bstore-focus exhaustively"
    set -l counter 1
    echo "Running stint $counter..."
    while bstore-focus-ipdb
        echo "Stint $counter went OK"
        set -l counter (expr $counter + 1)
        echo "Running stint $counter..."
     end
end
