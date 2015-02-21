#!/bin/bash

mysql -u root holmes -e "select id, name from domains where name like '%$1%';"
