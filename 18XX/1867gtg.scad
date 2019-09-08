// 1867: The Railways of Canada (Grand Trumk Games)
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
VERBOSE = true;        	// Set to non-zero to see more data

include <18XX.scad>;

// Game box dimensions

BOX_WIDTH       = 305 * mm;    // (X)
BOX_HEIGHT      = 230 * mm;    // (Y)
BOX_DEPTH       =  80 * mm;    // (Z)

// Tokens
TOKEN_DIAMETER  = 14.0 * mm;
TOKEN_HEIGHT    =  5.0 * mm;

// Cards
CARD_WIDTH      = 2.500 * inch;
CARD_HEIGHT     = 1.625 * inch;
CARD_THICKNESS  = 5.000 * mm;

LOAN_SIZE       = 1.125 * inch;
LOAN_THICKNESS  = 8.000 * mm;

// Tile dimensions
TILE_DIAMETER   = 46.00 * mm;
TILE_THICKNESS  =  2.00 * mm;
TILE_DIMPLE     =  0.250 * mm;

// ----- Data ---------------------------------------------------------------------------------------------------------

// ----- Modules ------------------------------------------------------------------------------------------------------

module hex_stack( count=5, angle=10 ) {
    height = layer_height( count * TILE_THICKNESS );
    radius1 = TILE_DIAMETER/2 + 2*mm;
    radius2 = radius1 + height * sin( angle );

    if (VERBOSE) {
        echo( HexStack=[ count, height, radius1, radius2] );
    }

    union() {
        cylinder( r1=radius1, r2=radius2, h=height, $fn=6 );
#        translate( [0,0,-TILE_DIMPLE] ) cylinder( r1=0, r2=radius1, h=TILE_DIMPLE+OVERLAP, $fn=6 );
    }
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "empty") {
} else {
    hex_stack();
}
