// 1846: The Race for the Midwest
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

// Box dimensions
BOX_HEIGHT      = 11.5 * inch;
BOX_WIDTH       =  8.5 * inch;
BOX_DEPTH       =  3.0 * inch;

// Tile dimensions
TILE_DIAMETER   = 50.0 * mm;
TILE_THICKNESS  =  3.0 * mm;

// Inner well dimensions
WELL_DEPTH      = 1.25 * inch;
WELL_HEIGHT     = 5.50 * inch;
WELL_WIDTH      = BOX_WIDTH;

// Card dimensions
CARD_WIDTH      = 2.50 * inch;
CARD_HEIGHT     = 1.75 * inch;
CARD_THICKNESS  = 0.35 * mm;

COMPANY_CARDS   = 9;
TRAIN_CARDS     = 2 + 7 + 6 + 5 + 9;
OTHER_CARDS     = 10 + 5 + 1;

// Marker dimensions
MARK_DIAMETER   = 15 * mm;      // 9/16 * inch;
MARK_THICKNESS  = 5*mm;         // 3.0 * mm;
MARK_MAX        = 10;

// Poker chip dimensions
CHIP_DIAMETER   = 41 * mm;
CHIP_THICKNESS  = 3.31 * mm;

CARDS           = [ CARD_WIDTH, CARD_HEIGHT, MARK_DIAMETER ];
CARD_SIZES      = [ CARD_HEIGHT, CARD_WIDTH, CARD_THICKNESS ];

// ----- Functions ----------------------------------------------------------------------------------------------------

function tile_height( count ) = count * TILE_THICKNESS;
function half_box_size( count ) = [0, 0, layer_height( count*TILE_THICKNESS ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box( count=5 ) {
    hex_box_corners( hex_tile_even_rows( 3, 4 ), half_box_size( count ), TILE_DIAMETER, [ "V3", "1846" ] );
}

module tile_lid( count=5 ) {
    hex_lid_corners(  hex_tile_even_rows( 3, 4 ), half_box_size( count ), TILE_DIAMETER, false, true );
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "short-tile-tray") {            // bom: 2 | short tile tray |
    tile_box( 2 );
} else if (PART == "tall-tile-tray") {      // bom: 2 | tall tile tray |
    tile_box( 5 );
} else if (PART == "short-tile-lid") {      // bom: 2 | short tile tray lid |
    tile_lid( 2 );
} else if (PART == "tall-tile-lid") {       // bom: 2 | tall tile tray lid |
    tile_lid( 5 );
} else if (PART == "card-box") {            // bom: 8 | card box |
    card_box( CARDS );
} else if (PART == "card-lid") {            // bom: 8 | card box lid |
    card_lid( CARDS );
} else if (PART == "alt-card-box") {            // bom: 8 | card box |
    deep_card_box( CARDS );
} else if (PART == "alt-card-lid") {            // bom: 8 | card box lid |
    deep_card_lid( CARDS );
} else if (PART == "card-sleeve") {         // bom: 1 | Card sleeve for trains |
    deck_box( CARD_SIZES, TRAIN_CARDS );
} else {
    translate( [-5, -5, 0] ) rotate( [0,0,180] ) tile_box( 5 );
    translate( [-5,  5, 0] ) rotate( [0,0,180] ) tile_lid( 5 );

    translate( [ 5,  5, 0] ) rotate( [0,0,0] ) deep_card_box( CARDS );
    translate( [ 5, -5, 0] ) rotate( [0,0,0] ) deep_card_lid( CARDS );

    translate( [77, 5, 0] ) deck_box( CARD_SIZES, TRAIN_CARDS );
}
