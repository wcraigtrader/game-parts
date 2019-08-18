#! /usr/bin/env python3

import logging
import os
import re
import sys

LOG = logging.getLogger( 'scad' )

LIBRARIES = []

INCLUDE = re.compile( '^include <(.*)>;$' )


def find_dependencies( src_path ):
    dependencies = []
    canonical = os.path.abspath( src_path )
    if canonical not in LIBRARIES:
        LOG.info( "Expanding %s", canonical )
        LIBRARIES.append( canonical )
        with open( canonical, 'r' ) as src_file:
            here = os.path.curdir
            os.chdir( os.path.dirname( canonical ) )

            for count, line in enumerate( src_file ):
                match = INCLUDE.match( line )
                if match:
                    filename = match.group( 1 )
                    dependencies.append( find_dependencies( filename ) )

            os.chdir( here )


if __name__ == '__main__':
    logging.basicConfig( level=logging.WARNING, format='%(asctime)s %(message)s', datefmt='%H:%M:%S' )

    if len( sys.argv ) < 2:
        LOG.error( "usage: %s <source>", sys.argv[0] )
        sys.exit( 1 )

    src = sys.argv[1]

    if not os.path.exists( src ):
        LOG.error( "Unable to locate source: %s", src )
        sys.exit( 2 )

    find_dependencies( src )

    sys.stdout.write( '\n'.join( LIBRARIES ) + '\n' )
