#!/usr/bin/env python3
import imp
import sys

for x in sys.argv[1:]: 
    # Trim off anything after == for locked versions
    try: 
        x = x[0:x.index("=")]
    except ValueError: pass

    try:
        imp.find_module(x)
    except ImportError:
        sys.exit(1)

sys.exit(0)
