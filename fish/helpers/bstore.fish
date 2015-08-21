function __bstore-query-apps -a api_url -a host -a db -a user -a title -a pass
    set -l sql "SELECT id, title, url, url_slug, secret_key AS secret,
            TO_BASE64(secret_key) AS shared,
            CONCAT(
                \"curl \", \"-H'X-SECRET-KEYS:\", secret_key, \"' \",
                \"$api_url/api/projects/list/\"
            ) AS projects,
            CONCAT(
                \"curl \", url, \"/admin/omni-store/version\"
            ) AS version
        FROM applications"
    if [ "$title" != "" ]
        set colate "COLLATE UTF8_GENERAL_CI"
        set sql (printf "%s WHERE title %s LIKE \"%%%s%%\"" $sql $colate $title | tr "\n" " ")
    end
    set sql (printf "%s \G" $sql)
    echo $sql | mysql -u$user -p$pass -h $host $db
end

function __bstore-mysql-credentials -a env_
    if [ "$env_" = "" ]
        echo We need an environment here, pal\!
        return 1
    end

    if [ (uname) != "Darwin" ]
        alias gsed="sed"
    end

    set -l ini_file ~/Workspace/backstage-store/alembic.$env_.ini
    set -l mysql_url (extract_iniconf.py $ini_file alembic sqlalchemy.url)

    set -l pattern "mysql:\/\/([^:]+):([^@]+)@([^:]+):3306\/(.+)"

    echo $mysql_url | gsed -r "s/$pattern/\1\n\2\n\3\n\4/"  # user, pass, host, db
end

function bstore-list-projects -a env_ -d "List all projects"
    set -l sql "SELECT CONCAT(t.slug, '/', p.slug) as uuid, p.name as name
        FROM projects p
        LEFT JOIN teams t on p.owner_id = t.id
        WHERE is_deleted IS false"
    set sql (printf "%s \G" $sql)
    if test "$env_" = "" -o "$env_" = "local"
        echo $sql | mysql -uroot -h localhost backstage_store
    else
        set cred (__bstore-mysql-credentials $env_)
        echo $sql | mysql -u$cred[1] -p$cred[2] -h $cred[3] $cred[4]
    end
end

function bstore-release-component -d "Bump a new release of a component"
    if test (count $argv) -eq 1
        set step $argv[1]
    else
        set step 1
    end

    set current (egrep '0\.0\.\d' README.md | awk -F. '{print $NF}')
    if [ "$current" = "" ]
        set current "0"
    end
    set -l minor (echo $current + $step | bc)

    set name (basename (pwd))

    if [ (uname) = "Darwin" ]
        gsed -ie "s/# $name.*/# $name 0.0.$minor/" README.md
    else
        sed -ie "s/# $name.*/# $name 0.0.$minor/" README.md
    end
    git add README.md
    git commit -am "bump(0.0.$minor): yeah, bump!"
    git tag 0.0.$minor
    git push origin master --tags
end

function bstore-show-apps -a env_ -a title -d "Show applications on backstage-store"
    if test "$env_" = "" -o "$env_" = "local"
        __bstore-query-apps http://localhost:2369 localhost backstage_store root $title
    else
        set -l conf_file ~/Workspace/backstage-store/$env_.conf
        set -l api_url (extract_derpconf.py $conf_file STORE_API_URL)

        set cred (__bstore-mysql-credentials $env_)

        __bstore-query-apps $api_url $cred[3] $cred[4] $cred[1] "$title" $cred[2] ^ /dev/null | less -XRF
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
    if [ $status != 0 ]
        echo 'Maybe you forgot to install ipdbplugin? (pip install ipdbplugin)'
    end
end

function bstore-focus-ignore-ipdb -d "Same as make focus-ignore but with --ipdb"
    make clear_repositories_test
    @coverage run --branch (which nosetests) -vv --with-yanc \
        --with-nosegrowlnotify --logging-level=WARNING --without-ignored -i \
        --processes=4 --ipdb --ipdb-failures -s tests/
    if [ $status != 0 ]
        echo 'Maybe you forgot to install ipdbplugin? (pip install ipdbplugin)'
    end
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
