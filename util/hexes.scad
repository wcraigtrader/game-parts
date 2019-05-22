// Hexagon Library
// by W. Craig Trader
//
// --------------------------------------------------------------------------------------------------------------------
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
// --------------------------------------------------------------------------------------------------------------------

include <units.scad>;
include <printers.scad>;

assert( version_num() > 20190000, "********** Will NOT work with this version of OpenSCAD **********" );

// ----- Physical Measurements ----------------------------------------------------------------------------------------

HEX_SPACING = WALL_WIDTH[4];    // aka 1.67mm
WALL_BEG = 0.15;
WALL_END = 1 - WALL_BEG;

// ----- Functions ----------------------------------------------------------------------------------------------------

function hex_tile_pos( r, c ) = [2+c*4+2*(r%2), 2+r*3 ];
function hex_tile_row( r, cols ) = [ for( c=[0:cols-1] ) hex_tile_pos( r, c ) ];
function hex_tile_even_rows( rows, cols ) = [ for( r=[0:rows-1] ) hex_tile_row( r, cols ) ];
function hex_tile_uneven_rows( rows, cols ) = [ for( r=[0:rows-1] ) hex_tile_row( r, cols-r%2 ) ];

function hex_length( diameter ) = diameter + 2*HEX_SPACING;
function hex_width( diameter ) = hex_length( diameter ) * sin(60);
function hex_edge( diameter ) = hex_length( diameter ) / 2;
function hex_config( diameter ) = [ hex_width( diameter )/4, hex_length( diameter )/4, hex_edge( diameter ) ];

function hex_rows( layout ) = len( layout );
function hex_cols( layout ) = max( len( layout[0] ), len( layout[1] ) );
function uneven_rows( layout ) = (len( layout[0] ) != len( layout[1] )) ? 0 : 0.5;
function short_row( layout ) = len( layout[0] ) > len( layout[1] ) ? 1 : 0;

function layout_size( layout, hex ) = [ (hex_cols( layout ) + uneven_rows( layout ) ) * hex_width( hex ), (hex_rows( layout ) * 3+1) / 4 * hex_length( hex ), 0 ];

// ----- Offsets for positioning hex corners --------------------------------------------------------------------------

TILE_CORNERS = [ // Corners 0, 1, 2, 3, 4, 5, 6, 0
    [ 0, 2 ], [ 2, 1 ], [ 2,-1 ], [ 0,-2 ], [-2,-1 ], [-2, 1 ], [ 0, 2 ]
];

// ----- Modules ------------------------------------------------------------------------------------------------------

/* hex_corner( corner, height )
 *
 * This creates a short segment of the corner of a hexagonal wall
 *
 * corner -- 0-5, specifying which corner of the hexagon to create, clockwise
 * height -- Height of the wall segment in millimeters
 * gap    -- Fraction of a millimeter, to tweak the width of the corner
 * size   -- width of the wall segment 
 */
module hex_corner( corner, height, gap=0, size = THIN_WALL ) {
    offset = corner * -60;
    for ( angle=[210,330] ) {
        rotate( [0, 0, angle+offset] )
        translate( [ 0, -size/2-gap/2, 0 ] )
        cube( [4*size, size+gap, height ] );
    }
    cylinder( d=size+2*gap, h=height );
}

/* hex_wall( corner, offset, width, height )
 *
 * This creates one wall of a hexagon, starting at a corner
 *
 * corner -- starting corner (0-5)
 * config -- vector that describes this hexagon
 * width  -- width of the wall
 * height -- height of the wall
 */

module hex_wall( corner, config, width, height ) {
    diff = TILE_CORNERS[ corner+1 ] - TILE_CORNERS[ corner ];
    w2l = width / config[2];

    hull() {
        translate( [diff.x*config.x*(WALL_BEG+w2l), diff.y*config.y*(WALL_BEG+w2l), 0] ) cylinder( d=width, h=height, $fn=6 );
        translate( [diff.x*config.x*(WALL_END-w2l), diff.y*config.y*(WALL_END-w2l), 0] ) cylinder( d=width, h=height, $fn=6 );
    }
}

/* hex_prism( height, diameter )
 *
 * Create a vertical hexagonal prism of a given height and diameter
 */
module hex_prism( height, diameter ) {
    rotate( [ 0, 0, 90 ] ) cylinder( h=height, d=diameter, $fn=6 );
}
