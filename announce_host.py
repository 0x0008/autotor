#!/usr/bin/env python3

import flatbencode
import furl
import sys
import time

if len(sys.argv) != 2:
    print('usage: autotor.py torrent', file=sys.stderr)
    print('  prints tracker hostname', file=sys.stderr)
    sys.exit(1)

time.sleep(.2)
bencoded_torrent = open(sys.argv[1], 'rb').read()
torrent = flatbencode.decode(bencoded_torrent)
host = furl.furl(torrent[b'announce']).host
print(host)
