// 18 New England (All Aboard Games)
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
BOX_WIDTH       = 11.500 * inch;    // (X)
BOX_HEIGHT      =  9.625 * inch;    // (Y)
BOX_DEPTH       =  2.250 * inch;    // (Z)

// Tokens
PAR_DIAMETER     = 1/2 * inch;
PAR_HEIGHT       = 7/32 * inch;
STATION_DIAMETER = 5/8 * inch;
STATION_HEIGHT   = 7/16 * inch;

// Cards
CARD_WIDTH      = 2.500 * inch;
CARD_HEIGHT     = 1.625 * inch;
CARD_THICKNESS  = 5.000 * mm;

SHARE_CARDS     = 8*9;
TRAIN_CARDS     = 10 + 7 + 4 + 4 + 3 + 9 + 1;

// Tile dimensions
TILE_DIAMETER   = 46.00 * mm;
TILE_THICKNESS  =  0.65 * mm;

// ----- Data ---------------------------------------------------------------------------------------------------------

tx3 = 2 * PAR_DIAMETER;
tx5 = 4 * STATION_DIAMETER + 1 * PAR_DIAMETER;
tx8 = tx5 + tx3 + THIN_WALL;
ty  = STATION_DIAMETER;

TOKEN_CELLS = [
    [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx8, ty ], [ tx3, ty ] ],
];

cx = CARD_WIDTH  + 1 * mm;
cy = CARD_HEIGHT + 1 * mm;

CARD_CELLS = [
    [ [ cx, cy ], [ cx, cy ], [ cx, cy ] ],
    [ [ cx, cy ], [ cx, cy ], [ cx, cy ] ],
    [ [ cx, cy ], [ cx, cy ], [ cx, cy ] ],
];

// ----- Functions ----------------------------------------------------------------------------------------------------

function half_box_size( count ) = [BOX_HEIGHT, 5.25*inch, layer_height( count*TILE_THICKNESS+2*mm ) ];
function alt_box_size( count ) = [ALT_WIDTH, ALT_HEIGHT, layer_height( count*TILE_THICKNESS+2*mm ) ];
function compact( count ) = [0, 0, layer_height( count*TILE_THICKNESS ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box( count=5 ) {
    hex_box_corners( hex_tile_even_rows( 3, 4 ), compact( count ), TILE_DIAMETER, [ "18NE", "V1" ] );
}

module tile_lid( count=5, holes=true ) {
    hex_lid_corners( hex_tile_even_rows( 3, 4 ), compact( count ), TILE_DIAMETER, true,  holes );
}

module token_box() {
    cell_box( TOKEN_CELLS, TOKEN_HEIGHT );
}

module token_lid() {
    cell_lid( TOKEN_CELLS, TOKEN_HEIGHT );
}

module card_box() {
    cell_box( CARD_CELLS, CARD_THICKNESS, HOLLOW, true );
}

module card_lid() {
    cell_lid( CARD_CELLS, CARD_THICKNESS, HOLLOW, true, true );
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "tile-lid-05") {            // bom: 2 | Lid for short tile tray |
    tile_lid(5);
} else if (PART == "tile-lid-10") {     // bom: 2 | Lid for tall tile tray |
    tile_lid(10);
} else if (PART == "tile-tray-05") {    // bom: 2 | Short tile tray |
    tile_box(5);
} else if (PART == "tile-tray-10") {    // bom: 2 | Tall tile tray |
    tile_box(10);
} else if (PART == "card-box") {        // bom: 2 | Tray for Engines or Stock Certificates |
    card_box();
} else if (PART == "card-lid") {        // bom: 2 | Lid for card tray |
    card_lid();
} else if (PART == "card-rack") {       // bom: 2 | Rack for displaying Stock or Engine cards |
    card_rack();
} else {

    translate( [ 5,  5, 0] ) tile_box(10);
    translate( [ 5, -5, 0] ) tile_lid(10);

/*
    translate( [ -5, -5, 0] ) rotate( [0,0,180] ) token_box();
    translate( [ -5,  5, 0] ) token_lid();

    translate( [ 254, 5, 0] ) card_box();
    translate( [ 254, -5, 0] ) rotate( [0,0,180] ) card_lid();
*/
}
