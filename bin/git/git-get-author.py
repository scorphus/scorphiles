#!/usr/bin/env python

import json
import os
import sys


def main(json_file_path, what, which):
    try:
        with open(json_file_path) as json_file:
            json_content = json.load(json_file)
    except Exception as e:
        sys.stdout.write(u'{}'.format(which))
        sys.stderr.write(u'Error opening: {}\n'.format(e))
        sys.stderr.write(u'    {}\n'.format(os.getcwd()))
        sys.exit(1)
    try:
        sys.stdout.write(u'{}'.format(json_content[which][what]))
    except Exception as e:
        sys.stdout.write(u'{}'.format(which))
        sys.stderr.write(u'Error writing: {}\n'.format(e))
        sys.stderr.write(u'    {} {}\n' % (what, which))
        sys.exit(1)

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3])
