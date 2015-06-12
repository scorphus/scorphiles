#!/usr/bin/env python
import sys

if __name__ == '__main__':
    conf_vars = {}
    with open(sys.argv[1]) as conf_file:
        for line in conf_file.readlines():
            if '=' in line:
                try:
                    exec(line, {}, conf_vars)
                except:
                    pass
        try:
            print conf_vars[sys.argv[2]]
        except:
            print 'Available variables:\n  {}'.format(
                '\n  '.join(sorted(conf_vars.keys()))
            )
            print 'Usage: extract_derpconf.py <file.conf> <variable>'
