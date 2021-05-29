#!/usr/bin/env python
# Prints when python packages were installed
from __future__ import print_function
from datetime import datetime
from pip._internal.utils.misc import get_installed_distributions
import os

if __name__ == "__main__":
    packages = []
    for package in get_installed_distributions():
        package_name_version = str(package)
        try:
            module_dir = next(package._get_metadata('top_level.txt'))
            package_location = os.path.join(package.location, module_dir)
            os.stat(package_location)
        except (StopIteration, OSError):
            try:
                package_location = os.path.join(package.location, package.key)
                os.stat(package_location)
            except:
                package_location = package.location
        modification_time = os.path.getctime(package_location)
        modification_time = datetime.fromtimestamp(modification_time)
        packages.append([
            modification_time,
            package_name_version
        ])
    for modification_time, package_name_version in sorted(packages):
        print("{0} - {1}".format(modification_time,
                                 package_name_version))