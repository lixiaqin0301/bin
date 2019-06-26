#!/usr/bin/env python3

import sys

for path in sys.argv[1:]:
    with open(path) as f:
        content = [x.strip() for x in f.read().split('\n\n') if x.startswith('Direct') and x.find('.c:') >= 0]
    content.sort(reverse=True, key=lambda x: (int(x.split()[6]), int(x.split()[3])))
    for c in content:
        if c.find('cbdataInitType') < 0:
            print(c)
