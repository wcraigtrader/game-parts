#! /usr/bin/env python3

import logging
import os
import re
import sys

LOG = logging.getLogger( 'scad' )

LIBRARIES = []

LINE_LENGTH = 120
INCLUDE = re.compile( '^include <(.*)>;$' )
BARS = '/'*LINE_LENGTH + '\n'

def section_comment( string ):
    line = "// ===== %s %s" % ( string, '='*LINE_LENGTH)
    return line[0:LINE_LENGTH]+'\n'

def expand_path( src_path, dst_file ):
    canonical = os.path.abspath( src_path )
    if canonical not in LIBRARIES:
        LOG.info( "Expanding %s", canonical )
        LIBRARIES.append( canonical )
        with open( canonical, 'r' ) as src_file:
            dst_file.write( section_comment( 'Start ' + src_path ) )

            here = os.path.curdir
            os.chdir( os.path.dirname( canonical ) )

            for dummy_index, line in enumerate( src_file ):
                match = INCLUDE.match( line )
                if match:
                    filename = match.group( 1 )
                    expand_path( filename, dst_file )
                else:
                    dst_file.write( line )

            os.chdir( here )

            dst_file.write( section_comment( 'End ' + src_path ) )

if __name__ == '__main__':
    logging.basicConfig( level=logging.WARNING, format='%(asctime)s %(message)s', datefmt='%H:%M:%S' )

    if len( sys.argv ) < 3:
        LOG.error( "usage: %s <source> <destination>", sys.argv[0] )
        sys.exit( 1 )

    src = sys.argv[1]
    dst = sys.argv[2]

    if not os.path.exists( src ):
        LOG.error( "Unable to locate source: %s", src )
        sys.exit( 2 )

    with open( dst, 'w' ) as output:
        expand_path( src, output )
