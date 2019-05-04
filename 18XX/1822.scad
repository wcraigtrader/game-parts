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

include <../util/units.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = 1;        	// Set to non-zero to see more data

// Game box dimensions
BOX_WIDTH       = 11.500 * inch;    // (X)
BOX_HEIGHT      =  9.625 * inch;    // (Y)
BOX_DEPTH       =  2.250 * inch;    // (Z)

ALT_WIDTH       = 8.000 * inch;
ALT_HEIGHT      = 4.000 * inch;

// Tile dimensions
TILE_DIAMETER   = 25.00 * mm;
TILE_THICKNESS  =  0.65 * mm;
POKE_HOLE       = 18.00 * mm;    // Diameter of poke holes in bottom

include <18XX.scad>;

// ----- Data ---------------------------------------------------------------------------------------------------------

// ----- Functions ----------------------------------------------------------------------------------------------------

function tile_height( count ) = layer_height( count*TILE_THICKNESS+2*mm );
function half_box_size( count ) = [BOX_HEIGHT, BOX_WIDTH/2, tile_height( count ) ];
function alt_box_size( count )  = [ALT_WIDTH,  ALT_HEIGHT,  tile_height( count ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box_1( count=8 ) {
    hex_box_2( TILE_CENTERS_6X8X, half_box_size( count ), TILE_DIAMETER, [ "V1", "1822", ] );
}

module tile_lid_1( count=8, holes=true ) {
    hex_lid_2( TILE_CENTERS_6X8X, half_box_size( count ), TILE_DIAMETER, true, holes );
}

module tile_box_2( count=8 ) {
    hex_box_2( TILE_CENTERS_7X7, alt_box_size( count ), TILE_DIAMETER, [ "V2", "1822", ] );
}

module tile_lid_2( count=8, holes=true ) {
    hex_lid_2( TILE_CENTERS_7X7,  alt_box_size( count ), TILE_DIAMETER, true, holes );
}

module tile_box_3( count=8 ) {
    hex_box_2( TILE_CENTERS_4X7, [8*inch, 4*inch, tile_height( count )], TILE_DIAMETER, [ "V2", "1822", ] );
}

module tile_lid_3( count=8, holes=true ) {
    hex_lid_2( TILE_CENTERS_4X7,  [8*inch, 4*inch, tile_height( count )], TILE_DIAMETER, true, holes );
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
    tile_box_3();
}
