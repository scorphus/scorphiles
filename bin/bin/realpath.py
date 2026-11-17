#!/usr/bin/env python
# Get the full absolute path (realpath) of args
# @author Weston Ruter (@westonruter) http://weston.ruter.net/

import sys
import os
for path in sys.argv[1:]:
    print os.path.realpath(path)
