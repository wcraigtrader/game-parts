// 1822: The Railways of Great Britain
// by W. Craig Trader
//
// --------------------------------------------------------------------------------------------------------------------
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
// --------------------------------------------------------------------------------------------------------------------

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = 1;        	// Set to non-zero to see more data

include <18XX.scad>;

// Game box dimensions
BOX_WIDTH       = 11.500 * inch;    // (X)
BOX_HEIGHT      =  9.625 * inch;    // (Y)
BOX_DEPTH       =  2.250 * inch;    // (Z)

ALT_WIDTH       = 8.000 * inch;
ALT_HEIGHT      = 7.000 * inch;

// Tile dimensions
TILE_DIAMETER   = 25.00 * mm;
TILE_THICKNESS  =  0.65 * mm;

// ----- Data ---------------------------------------------------------------------------------------------------------

// ----- Functions ----------------------------------------------------------------------------------------------------

function tile_height( count ) = layer_height( count*TILE_THICKNESS+2*mm );
function box_size_1( count ) = [9.125*inch, BOX_WIDTH/2, tile_height( count ) ];
function box_size_2( count ) = [7.75*inch, 7.375*inch,  tile_height( count ) ];
function box_size_3( count ) = [8*inch, 4*inch, tile_height( count ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box_1( count=8 ) {
    hex_box_walls( hex_tile_uneven_rows( 6, 9 ), box_size_1( count ), TILE_DIAMETER, [ "V1", "1822", ] );
}

module tile_lid_1( count=8, holes=true ) {
    hex_lid_walls( hex_tile_uneven_rows( 6, 9 ), box_size_1( count ), TILE_DIAMETER, true, holes );
}

module tile_box_2( count=8 ) {
    hex_box_walls( hex_tile_even_rows( 8, 7 ), box_size_2( count ), TILE_DIAMETER, [ "V2", "1822", ] );
}

module tile_lid_2( count=8, holes=true ) {
    hex_lid_walls( hex_tile_even_rows( 8, 7 ),  box_size_2( count ), TILE_DIAMETER, true, holes );
}

module tile_box_3( count=8 ) {
    hex_box_walls(hex_tile_even_rows( 4, 7 ), box_size_3( count ), TILE_DIAMETER, [ "V3", "1822", ] );
}

module tile_lid_3( count=8, holes=true ) {
    hex_lid_walls( hex_tile_even_rows( 4, 7 ), box_size_3( count ), TILE_DIAMETER, true, holes );
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "tile-lid-1") {
    tile_lid_1();
} else if (PART == "tile-box-1") {
    tile_box_1();
} else if (PART == "tile-lid-2") {
    tile_lid_2();
} else if (PART == "tile-box-2") {
    tile_box_2();
} else if (PART == "tile-lid-3") {
    tile_lid_3();
} else if (PART == "tile-box-3") {
    tile_box_3();
} else {
    tile_box_2();
}
