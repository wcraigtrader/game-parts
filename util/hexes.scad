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

HEX_SPACING = WALL_WIDTH[6];    // aka 1.67mm
WALL_BEG = 0.20;
WALL_END = 1 - WALL_BEG;

// ----- X and Y Offsets for positioning hex corners ------------------------------------------------------------------

TILE_CORNERS = [
    [ 0, 2 ],   // 0 = North
    [ 2, 1 ],   // 1 = North East
    [ 2,-1 ],   // 2 = South East
    [ 0,-2 ],   // 3 = South
    [-2,-1 ],   // 4 = South West
    [-2, 1 ],   // 5 = North West
    [ 0, 2 ],   // 6 = North (again)
];

// ----- Functions ----------------------------------------------------------------------------------------------------

function hex_tile_pos( r, c ) = [2+c*4+2*(r%2), 2+r*3 ];
function hex_tile_row( r, cols ) = [ for( c=[0:cols-1] ) hex_tile_pos( r, c ) ];
function hex_tile_even_rows( rows, cols ) = [ for( r=[0:rows-1] ) hex_tile_row( r, cols ) ];
function hex_tile_uneven_rows( rows, cols ) = [ for( r=[0:rows-1] ) hex_tile_row( r, cols-r%2 ) ];

function hex_length( diameter ) = diameter; //  + 2*HEX_SPACING;
function hex_width( diameter ) = hex_length( diameter ) * sin(60);
function hex_edge( diameter ) = hex_length( diameter ) / 2;

function hex_config( diameter ) = [ hex_width( diameter )/4, hex_length( diameter )/4, hex_edge( diameter ) ];

function hex_rows( layout ) = len( layout );
function hex_cols( layout ) = max( len( layout[0] ), len( layout[1] ) );
function uneven_rows( layout ) = (len( layout[0] ) != len( layout[1] )) ? 0 : 0.5;
function short_row( layout ) = len( layout[0] ) > len( layout[1] ) ? 1 : 0;

function layout_size( layout, hex ) = [ (hex_cols( layout ) + uneven_rows( layout ) ) * hex_width( hex ), (hex_rows( layout ) * 3+1) / 4 * hex_length( hex ), 0 ];

// ----- Modules ------------------------------------------------------------------------------------------------------

/* hex_wall( corner, offset, width, height, size )
 *
 * This creates one wall of a hexagon, starting at a corner
 *
 * corner -- starting corner (0-5)
 * config -- vector that describes this hexagon
 * width  -- thickness of the wall
 * height -- height of the wall
 * size   -- This is how large a percentage of the wall to construct (-1 <= size < 0 || 0 < size <= 1).
 *
 * Hex walls rarely run from one corner to the next -- they either have a gap in the middle of the wall,
 * or a gaps around either end of the wall. If the size is positive, it describes how large the centered wall is;
 * If the size is negative, it describes how large the centered gap between two end walls is.
 *
 * Examples:
 * +0.60  =>   *    ------------    *
 * -0.60  =>   *----            ----*
 */

module hex_wall( corner, config, width, height, size=0.60 ) {
    diff = TILE_CORNERS[ corner+1 ] - TILE_CORNERS[ corner ];

    m0 = 0.0;
    m1 = (1 - abs( size ) ) / 2;
    m2 = 1 - m1;
    m3 = 1.0;

    if (size > 0) {
        w2l = width / config[2];

        hull() {
            translate( [diff.x*config.x*(m1+w2l), diff.y*config.y*(m1+w2l), 0] ) cylinder( d=width, h=height, $fn=6 );
            translate( [diff.x*config.x*(m2-w2l), diff.y*config.y*(m2-w2l), 0] ) cylinder( d=width, h=height, $fn=6 );
        }
    } else {
        hull() {
            translate( [diff.x*config.x*m0, diff.y*config.y*m0, 0] ) cylinder( d=width, h=height, $fn=6 );
            translate( [diff.x*config.x*m1, diff.y*config.y*m1, 0] ) cylinder( d=width, h=height, $fn=6 );
        }
        hull() {
            translate( [diff.x*config.x*m2, diff.y*config.y*m2, 0] ) cylinder( d=width, h=height, $fn=6 );
            translate( [diff.x*config.x*m3, diff.y*config.y*m3, 0] ) cylinder( d=width, h=height, $fn=6 );
        }
    }
}

/* hex_corner( corner, height )
 *
 * This creates a short segment of the corner of a hexagonal wall
 *
 * corner -- 0-5, specifying which corner of the hexagon to create, clockwise
 * height -- Height of the wall segment in millimeters
 * gap    -- Fraction of a millimeter, to tweak the width of the corner
 * size   -- width of the wall segment 
 *
 * @deprecated
 */
module hex_corner( corner, height, gap=0, size = WIDE_WALL ) {
    offset = corner * -60;
    for ( angle=[210,330] ) {
        rotate( [0, 0, angle+offset] ) translate( [ 0, -size/2-gap/2, 0 ] ) cube( [4*size, size+gap, height ] );
    }
    cylinder( d=size+2*gap, h=height );
}

/* hex_prism( height, diameter )
 *
 * Create a vertical hexagonal prism of a given height and diameter
 */
module hex_prism( height, diameter ) {
    rotate( [ 0, 0, 90 ] ) cylinder( h=height, d=diameter, $fn=6 );
}

/* hex_layout( layout, size, delta )
 *
 * This is an operation module that loops through all of the tiles in a hex layout,
 * coloring and positioning each child at the center of its hex.
 *
 * layout -- An array of tile offsets for each row/column
 * size   -- the diameter of each hexagon in the layout
 * delta  -- an optional position offset applied to each tile location
 *
 * Special variables defined for each child:
 *
 * $config -- the hex_config for this size of hex
 * $row    -- the row number for this child
 * $col    -- the column number for this child
 * $tile   -- the tile offsets for this child
 */
module hex_layout( layout, size, delta=[0,0,0] ) {
    $config = hex_config( size );
    maxRows = len( layout );
    for ($row = [0:maxRows-1] ) {
        maxCols = len( layout[$row] );
        for ($col = [0:maxCols-1] ) {
            $tile = layout[$row][$col];
            hue = [ $tile.x/(maxCols*4), $tile.y/(maxRows*3-1), 0.5, 1 ];
            position = [ $tile.x*$config.x+delta.x, $tile.y*$config.y+delta.y, delta.z ];
            color( hue ) translate( position ) children();
        }
    }
}

/* hex_corner_layout( layout, size, delta )
 *
 * This is an operation module that loops through all of the corners of all of the tiles in a hex layout,
 * coloring and positioning each child at the corner of its hex.
 *
 * layout -- An array of tile offsets for each row/column
 * size   -- the diameter of each hexagon in the layout
 * delta  -- an optional position offset applied to each tile location
 *
 * Special variables defined for each child:
 *
 * $config -- the hex_config for this size of hex
 * $row    -- the row number for this child (0-based)
 * $col    -- the column number for this child (0-based)
 * $corner -- the corner number for this child (0-5)
 * $tile   -- the tile offsets for this child
 */
module hex_corner_layout( layout, size, delta=[0,0,0] ) {
    $config = hex_config( size );
    maxRows = len( layout );
    for ($row = [0:maxRows-1] ) {
        maxCols = len( layout[$row] );
        for ($col = [0:maxCols-1] ) {
            $tile = layout[$row][$col];
            hue = [ $tile.x/(maxCols*4), $tile.y/(maxRows*3-1), 0.5, 1 ];
            for ($corner = [0:5] ) {
                tc = TILE_CORNERS[$corner];
                position = [ ($tile.x+tc.x)*$config.x+delta.x, ($tile.y+tc.y)*$config.y+delta.y, delta.z ];
                color( hue ) translate( position ) children();
            }
        }
    }
}

if (0) {
    hex_layout( hex_tile_uneven_rows( 3,3 ), 10*mm ) {
        echo (row=$row, col=$col, $tile );
        difference() {
            hex_prism( 10, 10 );
            translate( [0,0,-OVERLAP] ) hex_prism( 10+2*OVERLAP, 9 );
        }
    }
}

