// 1867: The Railways of Canada
// by W. Craig Trader
//
// --------------------------------------------------------------------------------------------------------------------
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
// --------------------------------------------------------------------------------------------------------------------

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = true;        	// Set to non-zero to see more data

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

include <18XX.scad>;

// ----- Data ---------------------------------------------------------------------------------------------------------

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

lx = LOAN_SIZE + 1 * mm;
ly = LOAN_SIZE + 1 * mm;

LOAN_CELLS = [
    [ [ lx, ly ], [ lx, ly ], [ lx, ly ] ]
];

// ----- Functions ----------------------------------------------------------------------------------------------------

function half_box_size( count ) = [BOX_HEIGHT, BOX_WIDTH/2, layer_height( count*TILE_THICKNESS+STUB ) ];
function alt_box_size( count ) = [ALT_WIDTH, ALT_HEIGHT, layer_height( count*TILE_THICKNESS+STUB ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box( count=5 ) {
    hex_box_2( TILE_CENTERS_3X5, half_box_size( count ), TILE_DIAMETER, [ "1867", "V3" ] );
}

module tile_lid( count=5, holes=true ) {
    hex_lid_2( TILE_CENTERS_3X5, half_box_size( count ), TILE_DIAMETER, true,  holes );
}

module alt_tile_box( count=5 ) {
    hex_box_2( TILE_CENTERS_4X4, alt_box_size( count ), TILE_DIAMETER, ["1867", "V4"] );
}

module alt_tile_lid( count=5, holes=true ) {
    hex_lid_2( TILE_CENTERS_4X4, alt_box_size( count ), TILE_DIAMETER, true, holes );
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
    cell_lid( CARD_CELLS, CARD_THICKNESS );
}

module loan_box() {
    cell_box( LOAN_CELLS, LOAN_THICKNESS, HOLLOW, true );
}

module loan_lid() {
    cell_lid( LOAN_CELLS, LOAN_THICKNESS );
}

/* card_rack( count, slot_depth, width, height )
 *
 * Create a card rack, sized for the share / engine cards
 *
 * count      -- Number of card slots
 * slot_depth -- How thick a stack of cards will fit in a slot
 * width      -- How wide should the rack be (~60% of width of cards)
 * height     -- How tall should the rack be?
 */
module card_rack( count=9, slot_depth=10*TILE_THICKNESS, width=1.5*inch, height=20*mm ) {

    rounding = 2*mm; // radius

    offset = [
        (height - 3*mm) / T60 + WALL_WIDTH[6],
        width/2 - CARD_WIDTH/2,
        3*mm
    ];

    dx = slot_depth / S60 + WALL_WIDTH[6];

    length = dx*count + offset.x;


    difference() {
        translate( [rounding, rounding, rounding] ) minkowski() {
            cube( [ length-2*rounding, width-2*rounding, height-2*rounding ] );
            sphere( r=rounding );
        }

        // Remove slots for cards
        for (x=[0:1:count-1]) { // Extra slot bevels the front of the rack
            translate( [offset.x+x*dx, offset.y, offset.z] )
                rotate( [0,-30, 0] )
                    cube( [ slot_depth, CARD_WIDTH, CARD_HEIGHT ] );
        }

        // Slope the front of the rack
        translate( [offset.x+count*dx, offset.y, offset.z] ) rotate( [0, -30, 0 ] )
            cube( [3*slot_depth, CARD_WIDTH, CARD_HEIGHT] );
    }
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "tile-lid-05") {
    tile_lid(5);
} else if (PART == "tile-lid-10") {
    tile_lid(10);
} else if (PART == "tile-tray-05") {
    tile_box(5);
} else if (PART == "tile-tray-10") {
    tile_box(10);
} else if (PART == "alt-tile-lid") {
    alt_tile_lid();
} else if (PART == "alt-tile-tray-05") {
    alt_tile_box(5);
} else if (PART == "alt-tile-tray-10") {
    alt_tile_box(10);
} else if (PART == "card-box") {
    card_box();
} else if (PART == "card-lid") {
    card_lid();
} else if (PART == "token-box") {
    token_box();
} else if (PART == "token-lid") {
    token_lid();
} else if (PART == "loan-box") {
    loan_box();
} else if (PART == "loan-lid") {
    loan_lid();
} else if (PART == "card-rack") {
    card_rack();
} else {

    // large_tile_box(5);

    translate( [ 5,  5, 0] ) alt_tile_box(10);
    translate( [ 5, -5, 0] ) alt_tile_lid(10);

/*
    translate( [ 3,   3, 0] ) token_box();
    translate( [ 3,-138, 0] ) token_lid();


    translate( [ 170,    3, 0] ) card_box();
    translate( [ 170, -132, 0] ) card_lid();
*/
}
