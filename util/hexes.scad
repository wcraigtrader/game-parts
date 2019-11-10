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

DEBUG_HEXES = is_undef( DEBUG_HEXES ) ? (is_undef( VERBOSE ) ? true : VERBOSE) : DEBUG_HEXES;

include <units.scad>;
include <printers.scad>;

assert( version_num() > 20190000, "********** Will NOT work with this version of OpenSCAD **********" );

// ----- Physical Measurements ----------------------------------------------------------------------------------------

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

// Layout offset (row, col) for the neighbor of a corner
NEIGHBORS = [
    [ [1, 0], [0, 1], [-1, 0], [-1,-1], [0,-1], [1,-1], [1, 0] ],
    [ [1, 1], [0, 1], [-1, 1], [-1, 0], [0,-1], [1, 0], [1, 1] ],
];

// ----- Functions ----------------------------------------------------------------------------------------------------

function hex_tile_pos( r, c ) = [2+c*4+2*(r%2), 2+r*3 ];
function hex_tile_row( r, cols ) = [ for( c=[0:cols-1] ) hex_tile_pos( r, c ) ];
function hex_tile_even_rows( rows, cols ) = [ for( r=[0:rows-1] ) hex_tile_row( r, cols ) ];
function hex_tile_uneven_rows( rows, cols ) = [ for( r=[0:rows-1] ) hex_tile_row( r, cols-r%2 ) ];

function hex_length( diameter ) = diameter;
function hex_width( diameter ) = hex_length( diameter ) * sin(60);
function hex_edge( diameter ) = hex_length( diameter ) / 2;

function hex_angle( corner ) = corner * -60 - 30;
function hex_tile_offset( c1, c2 ) = TILE_CORNERS[ c2 % 6 ] - TILE_CORNERS[ c1 % 6 ];
function hex_outside_wall( layout, row, col, corner ) = is_undef( layout[row+NEIGHBORS[row%2][corner][0]][col+NEIGHBORS[row%2][corner][1]] );

function hex_config( diameter ) = [ hex_width( diameter )/4, hex_length( diameter )/4, hex_edge( diameter ) ];

function hex_rows( layout ) = len( layout );
function hex_cols( layout ) = max( len( layout[0] ), len( layout[1] ) );
function uneven_rows( layout ) = (len( layout[0] ) != len( layout[1] )) ? 0 : 0.5;
function short_row( layout ) = len( layout[0] ) > len( layout[1] ) ? 1 : 0;

function layout_size( layout, hex ) = [ (hex_cols( layout ) + uneven_rows( layout ) ) * hex_width( hex ), (hex_rows( layout ) * 3+1) / 4 * hex_length( hex ), 0 ];

// ----- Modules ------------------------------------------------------------------------------------------------------

/* hex_wall( corner, config, width, height, size )
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
 * or gaps around either end of the wall. If the size is positive, it describes how large the centered wall is;
 * If the size is negative, it describes how large the centered gap between two end walls is.
 *
 * Examples:
 * +0.60  =>   *    ------------    *
 * -0.60  =>   *----            ----*
 */

module hex_wall( corner, config, width, height, size=+0.60, fn=6 ) {
    m0 = 0.0;
    m1 = (1 - abs( size ) ) / 2;
    m2 = 1 - m1;
    m3 = 1.0;

    diff = hex_tile_offset( corner, corner+1 );
    position = [ diff.x*config.x, diff.y*config.y, 0 ];

    if (size > 0) {
        w2l = width / config[2];
        hull() {
            translate( position*(m1+w2l) ) cylinder( d=width, h=height, $fn=fn );
            translate( position*(m2-w2l) ) cylinder( d=width, h=height, $fn=fn );
        }
    } else {
        hull() {
            translate( position*m0 ) cylinder( d=width, h=height, $fn=fn );
            translate( position*m1 ) cylinder( d=width, h=height, $fn=fn );
        }
        hull() {
            translate( position*m2 ) cylinder( d=width, h=height, $fn=fn );
            translate( position*m3 ) cylinder( d=width, h=height, $fn=fn );
        }
    }
}

/* hex_cube_wall( corner, config, width, height, size )
 *
 * Same as hex_wall, except with rectangular boxes instead of hulled-cylinders
 */

module hex_cube_wall( corner, config, width, height, size ) {
    m0 = 0.0;
    m1 = (1 - abs( size ) ) / 2;
    m2 = 1 - m1;
    m3 = 1.0;

    angle = corner * -60 - 30;

    diff = hex_tile_offset( corner, corner+1 );
    position = [ diff.x*config.x, diff.y*config.y, 0 ];
    center = [0,-width/2,0];

    if (size > 0) {
        translate( position*m1 ) rotate( angle ) translate( center ) cube( [config[2]*(m2-m1), width, height] );
    } else {
        translate( position*m0 ) rotate( angle ) translate( center ) cube( [config[2]*(m1-m0), width, height] );
        translate( position*m2 ) rotate( angle ) translate( center ) cube( [config[2]*(m3-m2), width, height] );
    }
}

/* hex_cube_wall( corner, config, width, height, size )
 *
 * Same as hex_wall, except with sloped walls, for thermoform bucks
 */

module hex_angle_wall( corner, config, width, height, size, zscale = 1.0 ) {
    m0 = 0.0;
    m1 = (1 - abs( size ) ) / 2;
    m2 = 1 - m1;
    m3 = 1.0;

    angle = hex_angle( corner );

    diff = hex_tile_offset( corner, corner+1 );
    position = [ diff.x*config.x, diff.y*config.y, 0 ];

    module angle_wall( size, zscale ) {
        dy0 = OVERLAP; dy1 = size.y/2;
        dx3 = size.x/2; dx2 = dx3-dy1; dx0 = -dx3; dx1 = dx0+dy1;
        translate( [size.x/2,0,0] ) linear_extrude( size.z, scale=zscale )
            polygon( [ [dx0,dy0], [dx3,dy0], [dx3,-dy1], [dx0,-dy1] ] );
    }

    if (size > 0) {
        translate( position*m1 ) rotate( angle ) angle_wall( [config[2]*(m2-m1), width, height], zscale );
    } else {
        translate( position*m0 ) rotate( angle ) angle_wall( [config[2]*(m1-m0), width, height], zscale );
        translate( position*m2 ) rotate( angle ) angle_wall( [config[2]*(m3-m2), width, height], zscale );
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

/* hex_prism( height, diameter, angle )
 *
 * Create a vertical hexagonal prism of a given height and diameter
 * If angle is not zero, the prism will be sloped, for thermform bucks
 */
module hex_prism( height, diameter, angle=0 ) {
    bot_d = diameter;
    top_d = diameter + height * sin( angle );
    rotate( [ 0, 0, 90 ] ) cylinder( h=height, d1=bot_d, d2=top_d, $fn=6 );
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
 * $config  -- the hex_config for this size of hex
 * $row     -- the row number for this child (0-based)
 * $col     -- the column number for this child (0-based)
 * $corner  -- the corner number for this child (0-5)
 * $tile    -- the tile offsets for this child
 * $outside -- true if the wall for this corner is an outside wall
 */
module hex_corner_layout( layout, size, delta=[0,0,0] ) {
    $config = hex_config( size );
    maxRows = len( layout );
    for ($row = [0:maxRows-1]) {
        maxCols = len( layout[$row] );
        for ($col = [0:maxCols-1]) {
            $tile = layout[$row][$col];
            hue = [ $tile.x/(maxCols*4), $tile.y/(maxRows*3-1), 0.5, 1 ];
            tposition = [ $tile.x*$config.x+delta.x, $tile.y*$config.y+delta.y, delta.z ];
            for ($corner = [0:5]) {
                $outside = hex_outside_wall(layout, $row, $col, $corner);
                tc = TILE_CORNERS[$corner];
                cposition = [ tc.x*$config.x, tc.y*$config.y, 0 ];
                color( hue ) translate( tposition + cposition ) children();
            }
        }
    }
}

// ----- Testing ------------------------------------------------------------------------------------------------------


