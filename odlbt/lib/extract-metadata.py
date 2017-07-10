#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  extract-header.py
#  
#  Copyright 2017 Andrea Bignamini <bigna@eastfold>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  
"""
extract-header

Usage:
  extract-header <input-file>...
  extract-header -h | --help
  extract-header --version

Options:
  -h --help   Show this screen.
  --version   Show version.
"""
from docopt import docopt
ARGS = docopt(__doc__, version='extract-header 1.0.0')

KEYWORD=['PARTNER',
         'PI_NAME',
         'INSTRUME',
         'EXPTIME',
         'MJD-OBS',
         'DATE-OBS',
         'RA',
         'DEC']

from pyfits import getheader
import json

for f in ARGS['<input-file>']:
    d = {'metadata' : {}}
    d['file_name'] = f
    h = getheader(f)
    for k in KEYWORD:
        d['metadata'][k] = h[k]
    with open(f+'.json', 'w') as fp:
        json.dump(d, fp)
