// 1830: The Game of Railroads and Robber Barons
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
BOX_HEIGHT      = 11.125 * inch;
BOX_WIDTH       =  8.0 * inch;
BOX_DEPTH       =  2.0 * inch;

// Tile dimensions
TILE_DIAMETER   = 46.0 * mm;    // 1.75 * inch
TILE_THICKNESS  =  0.5 * mm;

// Part box dimensions
TOKEN_DIAMETER  = 17.5 * mm;
TOKEN_THICKNESS =  2.0 * mm;

// Cards
CARD_LENGTH     = 2.625 * inch;
CARD_WIDTH      = 1.750 * inch;
CARD_THICKNESS  = 0.300 * mm;

CARD_NUMBERS    = 6;
CARD_PRIVATES   = 6;
CARD_TRAINS     = 6 + 5 + 4 + 3 + 3 + 6;
CARD_COMPANY    = 9;

// ----- Calculated Dimensions ----------------------------------------------------------------------------------------

TOKEN_WIDTH     = 2 * TOKEN_DIAMETER;   // X
TOKEN_DEPTH     = 1 * TOKEN_DIAMETER;   // Y
TOKEN_HEIGHT    = 3 * TOKEN_THICKNESS;  // Z

CARD_SIZES      = [ CARD_WIDTH, CARD_LENGTH, CARD_THICKNESS ];

CARD_COMPANIES  = 4 * CARD_COMPANY;
CARD_OTHER      = 1 + CARD_NUMBERS + CARD_PRIVATES + CARD_TRAINS;

// ----- Data ---------------------------------------------------------------------------------------------------------

// ----- Functions ----------------------------------------------------------------------------------------------------

function half_box_size( count ) = [BOX_WIDTH, 5.25*inch, layer_height( count*TILE_THICKNESS+STUB ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box( count=12 ) {
    hex_box_corners( hex_tile_even_rows( 3, 4 ), half_box_size( count ), TILE_DIAMETER, [ "V3", "AH 1830" ] );
}

module tile_lid( count=12, holes=true ) {
    hex_lid_corners( hex_tile_even_rows( 3, 4 ), half_box_size( count ), TILE_DIAMETER, true,  holes );
}

module token_box() {
    cell_box( uniform_token_cells( 3, 3, TOKEN_WIDTH, TOKEN_DEPTH), TOKEN_HEIGHT, ROUNDED );
}

module token_lid() {
    cell_lid( uniform_token_cells( 3, 3, TOKEN_WIDTH, TOKEN_DEPTH), TOKEN_HEIGHT );
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "tile-tray") {              // bom: 4 | Tile tray |
    tile_box();
} else if (PART == "tile-lid") {        // bom: 4 | Tile tray lid |
    tile_lid();
} else if (PART == "token-box") {       // bom: 1 | Token box |
    token_box();
} else if (PART == "token-lid") {       // bom: 1 | Token box lid |
    token_lid();
} else if (PART == "company-cards") {   // bom: 2 | Card sleeve for shares for 4 companeis |
    deck_box( CARD_SIZES, CARD_COMPANIES );
} else if (PART == "other-cards") {     // bom: 1 | Card sleeve for other cards |
    deck_box( CARD_SIZES, CARD_OTHER );
} else {
    translate( [ 5,  5,0] ) tile_box();
    translate( [ 5, -5,0] ) tile_lid();
    translate( [-5, -5,0] ) rotate( [0,0,180] ) token_box();
    translate( [-5,  5,0] ) token_lid();
}
