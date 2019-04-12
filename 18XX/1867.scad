// 1830: The Game of Railroads and Robber Barons
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = 1;        	// Set to non-zero to see more data

// Game box dimensions
BOX_WIDTH       = 11.500 * inch;    // (X)
BOX_HEIGHT      =  9.625 * inch;    // (Y)
BOX_DEPTH       =  2.250 * inch;    // (Z)

// Tokens
TOKEN_DIAMETER  = 14.0 * mm;
TOKEN_HEIGHT    =  5.0 * mm;

// Cards
CARD_WIDTH      = 2.500 * inch;
CARD_HEIGHT     = 1.625 * inch;
SHARE_THICKNESS = 5.000 * mm;
TRAIN_THICKNESS = 5.000 * mm;

// Tile dimensions
TILE_DIAMETER   = 46.00 * mm;
TILE_THICKNESS  =  0.65 * mm;
POKE_HOLE       = 35.00 * mm;    // Diameter of poke holes in bottom

include <18XX.scad>;

// ----- Data ------------------------------------------------------------------

tx3 = 3 * TOKEN_DIAMETER; 
tx5 = 5 * TOKEN_DIAMETER;
tx8 = tx5 + tx3 + THIN_WALL;
ty  = TOKEN_DIAMETER;

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

// ----- Functions -------------------------------------------------------------

// ----- Modules ---------------------------------------------------------------

module tile_box( count ) {
    hex_tray( TILE_CENTERS_3X5, BOX_HEIGHT, BOX_WIDTH/2, count*TILE_THICKNESS+STUB, WIDE_WALL, "1867", "V1" );
}

module tile_lid( holes=true ) {
    hex_lid( TILE_CENTERS_3X5, BOX_HEIGHT, BOX_WIDTH/2, 4*mm, WIDE_WALL, THIN_WALL, false, true, holes );
}

module token_box() {
    cell_box( TOKEN_CELLS, TOKEN_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
}

module token_lid() {
    cell_lid( TOKEN_CELLS, TOKEN_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
}

module card_box() {
    cell_box( CARD_CELLS, SHARE_THICKNESS, BOTTOM, TOP, THIN_WALL, THIN_WALL, true );
}

module card_lid() {
    cell_lid( CARD_CELLS, SHARE_THICKNESS, BOTTOM, TOP, THIN_WALL, THIN_WALL );
}

// ----- Rendering -------------------------------------------------------------

if (PART == "tile-lid") {
    tile_lid();
} else if (PART == "tile-tray-05") {
    tile_box(5);
} else if (PART == "tile-tray-10") {
    tile_box(10);
} else if (PART == "card-box") {
    card_box();
} else if (PART == "card-lid") {
    card_lid();
} else if (PART == "token-box") {
    token_box();
} else if (PART == "token-lid") {
    token_lid();
} else {
    translate( [-3,  -3, 0] ) rotate( [0,0,180] ) tile_box();
    translate( [-3,   3, 0] ) rotate( [0,0,180] ) tile_lid();

    translate( [ 3,   3, 0] ) token_box();
    translate( [ 3,-138, 0] ) token_lid();
    
    translate( [ 170,    3, 0] ) card_box();
    translate( [ 170, -132, 0] ) card_lid();
}
