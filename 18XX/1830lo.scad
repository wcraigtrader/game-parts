// 1830: Railways and Robber Barons (Lookout)
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
BOX_HEIGHT      = 12.125 * inch;
BOX_WIDTH       =  8.50 * inch;
BOX_DEPTH       =  2.75 * inch;

// Tile dimensions
TILE_DIAMETER   = 44.0  * mm;
TILE_THICKNESS  =  2.25 * mm;

// Part box dimensions
TOKEN_RADIUS    = 16 * mm;
TOKEN_THICKNESS = TILE_THICKNESS;
TOKEN_HEIGHT    = layer_height( 3*TILE_THICKNESS );

// Card dimensions
CARD_WIDTH      = 2.75 * inch;
CARD_HEIGHT     = 1.75 * inch;
CARD_THICKNESS  = 0.50 * mm;

// ----- Data ---------------------------------------------------------------------------------------------------------

CARDS = [ CARD_WIDTH, CARD_HEIGHT, TOKEN_RADIUS ];

// ----- Functions ----------------------------------------------------------------------------------------------------

function half_box_size( count ) = [BOX_WIDTH, BOX_HEIGHT/2, layer_height( count*TILE_THICKNESS+2*mm ) ];
function minimum_size( count ) = [0, 0, layer_height( count*TILE_THICKNESS ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box( count=4 ) {
    hex_box_2( hex_tile_even_rows( 3, 4 ), minimum_size( count ), TILE_DIAMETER, [ "V1", "LO 1830" ] );
}

module tile_lid( count=4, holes=true ) {
    hex_lid_2( hex_tile_even_rows( 3, 4 ), minimum_size( count ), TILE_DIAMETER, false,  holes );
}

module token_box() {
    cell_box( TOKEN_CELLS, TOKEN_HEIGHT );
}

module token_lid() {
    cell_lid( TOKEN_CELLS, TOKEN_HEIGHT );
}


module train_rack() {
    card_rack( 6, 6*CARD_THICKNESS, 1.5*inch, 20*mm );
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "tile-tray") {          // bom: 4 | short tile tray |
    tile_box( 4 );
} else if (PART == "tile-lid") {    // bom: 4 | tall tile tray lid |
    tile_lid( 4 );
} else if (PART == "card-box") {    // bom: 9 | card box |
    card_box( CARDS );
} else if (PART == "card-lid") {    // bom: 9 | card box lid |
    card_lid( CARDS );
} else if (PART == "card-rack") {       // bom: 2 | Rack for displaying Stock or Engine cards |
    train_rack();
} else {
    translate( [ 5,   5,0] ) tile_box();
    translate( [ 5,  -5,0] ) tile_lid();
    translate( [-5, -95,0] ) rotate( [0,0,90] ) card_box( CARDS );
    translate( [-5,   5,0] ) rotate( [0,0,90] ) card_lid( CARDS );
    translate( [-60,  3,0] ) rotate( [0,0,90] ) train_rack();
}
