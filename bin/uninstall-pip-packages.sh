#!/bin/sh

packages=$(pip list | egrep -iv 'pip|setuptools' | awk '{print $1}')

for package in $packages; do
    echo "uninstalling $package..."
    echo 'y' | pip uninstall -q $package
done
