#!/bin/sh

git filter-branch -f --commit-filter '
    GIT_COMMITTER_NAME="$(git-get-author.py ../../CONTRIBUTORS.json name $GIT_AUTHOR_EMAIL)";
    GIT_AUTHOR_NAME="$(git-get-author.py ../../CONTRIBUTORS.json name $GIT_AUTHOR_EMAIL)";
    GIT_COMMITTER_EMAIL="$(git-get-author.py ../../CONTRIBUTORS.json email $GIT_AUTHOR_EMAIL)";
    GIT_AUTHOR_EMAIL="$(git-get-author.py ../../CONTRIBUTORS.json email $GIT_AUTHOR_EMAIL)";
    git commit-tree "$@";
' HEAD
