// Innovation 3rd Edition
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Physical dimensions
WALL = 0.8 * mm; // Slicing filament thickness
GAP  = 0.2 * mm; // Size differential between box and lid, for snug fit
POKE_HOLE = 20 * mm; // Diameter of poke holes in bottom
BOTTOM = 1 * mm;

// Tile dimensions
CARD_WIDTH = 69 * mm;       // (X) Width of card
CARD_HEIGHT = 96 * mm;      // (Y) Height of card
DECK_THICKNESS = 30 * mm;   // (Z) Thickness of card stack

BOARD_WIDTH = 128 * mm;     // (X) Width of player board
BOARD_HEIGHT = 89 * mm;     // (Y) Height of player board

RULES_WIDTH = 117 * mm;     // (X) Width of rule book
RULES_HEIGHT = 85 * mm;     // (Y) Height of rule book

EXTRA_THICKNESS = 3 * mm;   // (Z) Thickness of rules and boards

// Wall dimensions
OUTER  = 2 * WALL;
INNER  = 2 * WALL;
SEP    = 2 * WALL;

OVERLAP = 0.1 * mm; // Ensures that there are no vertical artifacts leftover

// $fa=4;
$fn = 36;

box_height = DECK_THICKNESS;
lid_height = ceil( max( EXTRA_THICKNESS, 5 * mm ) );

SIZES = [ 10, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7 ];
STEPS = [ 0, 10, 17, 24, 31, 38, 45, 52, 59, 66, 73, 80 ];

//width = ceil( max( CARD_HEIGHT, BOARD_HEIGHT, RULES_HEIGHT ) );
//length = 2*INNER + 1*SEP + s1 + s2;
//height = 2*INNER + width;
for( dx = STEPS ) {
    translate( [ dx, 0, 0 ] )
        rotate( [0, 45, 0]) 
            cube( [ SEP, CARD_HEIGHT, CARD_WIDTH-15 ] );
}