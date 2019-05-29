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

include <util/units.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = true;        	// Set to non-zero to see more data

// Game box dimensions
BOX_HEIGHT      = 11.125 * inch;
BOX_WIDTH       =  8.0 * inch;
BOX_DEPTH       =  2.0 * inch;

// Tile dimensions
TILE_DIAMETER   = 46.0 * mm;
TILE_THICKNESS  =  0.5 * mm;
POKE_HOLE       = 35.0 * mm;    // Diameter of poke holes in bottom

// Part box dimensions
TOKEN_WIDTH      = 35.0 * mm;   // X
TOKEN_DEPTH      = 17.5 * mm;   // Y
TOKEN_HEIGHT     = 6.00 * mm;   // Z

include <18XX.scad>;

// ----- Data ---------------------------------------------------------------------------------------------------------

tx = TOKEN_WIDTH; ty = TOKEN_DEPTH;

TOKEN_CELLS = [
    [ [ tx, ty ], [ tx, ty ], [ tx, ty ] ],
    [ [ tx, ty ], [ tx, ty ], [ tx, ty ] ],
    [ [ tx, ty ], [ tx, ty ], [ tx, ty ] ]
];

// ----- Functions ----------------------------------------------------------------------------------------------------

function half_box_size( count ) = [BOX_WIDTH, 5.25*inch, layer_height( count*TILE_THICKNESS+2*mm ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box( count=12 ) {
    hex_box_2( hex_tile_even_rows( 3, 4 ), half_box_size( count ), TILE_DIAMETER, [ "V2", "AH 1830" ] );
}

module tile_lid( count=12, holes=true ) {
    hex_lid_2( hex_tile_even_rows( 3, 4 ), half_box_size( count ), TILE_DIAMETER, true,  holes );
}

module token_box() {
    cell_box( TOKEN_CELLS, TOKEN_HEIGHT );
}

module token_lid() {
    cell_lid( TOKEN_CELLS, TOKEN_HEIGHT );
}


// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "tile-tray") {          // bom: 4 | Tile tray |
    tile_box();
} else if (PART == "tile-lid") {    // bom: 4 | Tile tray lid |
    tile_lid();
} else if (PART == "token-box") {   // bom: 1 | Token box |
    token_box();
} else if (PART == "token-lid") {   // bom: 1 | Token box lid |
    token_lid();
} else {
    translate( [-5, -5,0] ) rotate( [0,0,180] ) tile_box();
    translate( [-5,  5,0] ) rotate( [0,0,180] ) tile_lid();
    translate( [ 5,  5,0] ) token_box();
    translate( [ 5,-59,0] ) token_lid();
}
