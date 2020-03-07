// 1867: The Railways of Canada (All Aboard Games)
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

ALT_WIDTH       = 8.000 * inch;
ALT_HEIGHT      = 7.000 * inch;

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
TILE_THICKNESS  =  0.65 * mm;
POKE_HOLE       = 30.00 * mm;    // Diameter of poke holes in bottom
TILE_EXTRA      =  3.00 * mm;

MAJOR_CHARTERS  = [ 4.2500*inch, 5.125*inch, 0.60*mm ];
MINOR_CHARTERS  = [ 3.1875*inch, 5.875*inch, 0.60*mm ];

// ----- Data ---------------------------------------------------------------------------------------------------------

tx3 = 3 * TOKEN_DIAMETER;
tx5 = 5 * TOKEN_DIAMETER;
tx8 = tx5 + tx3 + THIN_WALL;
ty  = TOKEN_DIAMETER;

TOKEN_CELLS = [
    for (i=[1:8]) [ [ tx5, ty ], [ tx3, ty ], [ tx3, ty ] ],
    [ [ tx8, ty ], [ tx3, ty ] ],
];

cx = CARD_WIDTH  + 1 * mm;
cy = CARD_HEIGHT + 1 * mm;

CARD_CELLS = [
    [ [ cx, cy ], [ cx, cy ], [ cx, cy ] ],
    [ [ cx, cy ], [ cx, cy ], [ cx, cy ] ],
    [ [ cx, cy ], [ cx, cy ], [ cx, cy ] ],
];

lx = LOAN_SIZE + 1 * mm;
ly = LOAN_SIZE + 1 * mm;

LOAN_CELLS = [
    [ [ lx, ly ], [ lx, ly ], [ lx, ly ] ]
];

// ----- Data ---------------------------------------------------------------------------------------------------------

horizontal = [BOX_WIDTH, BOX_HEIGHT, 10*TILE_THICKNESS + TILE_EXTRA ];
vertical   = [BOX_HEIGHT, BOX_WIDTH, 10*TILE_THICKNESS + TILE_EXTRA ];
auto_fit   = [0, 0, 10*TILE_THICKNESS + TILE_EXTRA];

layout0  = hex_tile_uneven_rows( 3, 3 );
layout25 = hex_tile_even_rows( 5, 5 );
layout28 = hex_tile_uneven_rows( 5, 6 );
layout30 = hex_tile_even_rows( 5, 6 );
layout32 = hex_tile_uneven_rows( 7, 5 );
layout35 = hex_tile_even_rows( 7, 5 );
layout36 = hex_tile_even_rows( 6, 6 );

if (VERBOSE) {
    echo( TraySize=vertical, inches=vertical/inch );
}

// ----- Functions ----------------------------------------------------------------------------------------------------

function half_box_size( count ) = [BOX_HEIGHT, 5.25*inch, layer_height( count*TILE_THICKNESS+STUB ) ];
function alt_box_size( count ) = [ALT_WIDTH, ALT_HEIGHT, layer_height( count*TILE_THICKNESS+STUB ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module buck( wells=32, orientation=FULL, test=false ) {
    if (wells == 28) {
        hex_tray_buck( layout28, horizontal, TILE_DIAMETER, orientation, test );
    } else if (wells == 30) {
        hex_tray_buck( layout30, auto_fit, TILE_DIAMETER, orientation, test );
    } else if (wells == 32) {
        hex_tray_buck( layout32, vertical, TILE_DIAMETER, orientation, test );
    } else if (wells == 35) {
        hex_tray_buck( layout35, vertical, TILE_DIAMETER, orientation, test );
    } else if (wells == 36) {
        hex_tray_buck( layout36, horizontal, TILE_DIAMETER, orientation, test );
    } else {
        hex_tray_buck( layout0, auto_fit, TILE_DIAMETER, orientation, test );
    }
}

module tile_box( count=5 ) {
    hex_box_corners( hex_tile_even_rows( 3, 5 ), half_box_size( count ), TILE_DIAMETER, [ "1867", "V5" ] );
}

module tile_lid( count=5, holes=true ) {
    hex_lid_corners( hex_tile_even_rows( 3, 5 ), half_box_size( count ), TILE_DIAMETER, true,  holes );
}

module alt_tile_box( count=5 ) {
    hex_box_corners( hex_tile_even_rows( 4, 4 ), alt_box_size( count ), TILE_DIAMETER, ["1867", "V6"] );
}

module alt_tile_lid( count=5, holes=true ) {
    hex_lid_corners( hex_tile_even_rows( 4, 4 ), alt_box_size( count ), TILE_DIAMETER, true, holes );
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

module loan_box() {
    cell_box( LOAN_CELLS, LOAN_THICKNESS, HOLLOW, true );
}

module loan_lid() {
    cell_lid( LOAN_CELLS, LOAN_THICKNESS, HOLLOW, true, true );
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
} else if (PART == "token-box") {       // bom: 1 | Minor and Stock Company tokens |
    token_box();
} else if (PART == "token-lid") {       // bom: 1 | Token box lid |
    token_lid();
} else if (PART == "loan-box") {        // bom: 1 | Box for Loans and Start Order |
    loan_box();
} else if (PART == "loan-lid") {        // bom: 1 | Loan box lid |
    loan_lid();
} else if (PART == "card-rack") {       // bom: 2 | Rack for displaying Stock or Engine cards |
    card_rack();
} else if (PART == "minor-charters") {  // bom: 1 | Sleeve for minor charters |
    deck_box( MINOR_CHARTERS, 16 );
} else if (PART == "major-charters") {  // bom: 1 | Sleeve for major charters |
    deck_box( MAJOR_CHARTERS, 9 );
} else if (PART == "alt-tile-lid-05") {     // bom: 2 | Lid for alternate short tile tray |
    alt_tile_lid(5);
} else if (PART == "alt-tile-lid-10") {     // bom: 2 | Lid for alternate tall tile tray |
    alt_tile_lid(10);
} else if (PART == "alt-tile-tray-05") {    // bom: 2 | Alternate short tile tray |
    alt_tile_box(5);
} else if (PART == "alt-tile-tray-10") {    // bom: 2 | Alternate tall tile tray |
    alt_tile_box(10);
} else if (0) {

    translate( [ 5,  5, 0] ) tile_box(10);
    translate( [ 5, -5, 0] ) tile_lid(10);

    translate( [ -5, -5, 0] ) rotate( [0,0,180] ) token_box();
    translate( [ -5,  5, 0] ) token_lid();

    translate( [ 254, 5, 0] ) card_box();
    translate( [ 254, -5, 0] ) rotate( [0,0,180] ) card_lid();

    translate( [ 5, 145, 0 ] ) deck_box( MINOR_CHARTERS, 16 );
    translate( [ 5, 165, 0 ] ) deck_box( MAJOR_CHARTERS, 9 );

} else {
    buck( 30, LEFT );
    translate( [2,0,0] ) buck( 30, RIGHT );
}
