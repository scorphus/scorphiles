#!/usr/bin/env python
import ConfigParser
import os
import sys


def main(argv):
    '''Usage: extract_iniconf.py {} {} <option>'''

    if len(argv) < 2 or not os.path.isfile(argv[1]):
        print main.__doc__.format('<ini-file>', '<section>')
        return

    with open(argv[1]) as config_file:
        config = ConfigParser.ConfigParser()
        config.readfp(config_file)

        if len(argv) < 3 or not config.has_section(argv[2]):
            print main.__doc__.format(argv[1], '<section>')
            print 'Available sections:\n  {}'.format(
                '\n  '.join(sorted(config.sections()))
            )
            return

        if len(argv) < 4 or not config.has_option(argv[2], argv[3]):
            print main.__doc__.format(argv[1], argv[2])
            print 'Available options:\n  {}'.format(
                '\n  '.join(sorted(config.options(argv[2])))
            )
            return

        print config.get(argv[2], argv[3])

if __name__ == '__main__':
    main(sys.argv)
