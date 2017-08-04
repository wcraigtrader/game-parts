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

s1 = ceil( max( CARD_WIDTH, (BOARD_WIDTH-SEP)/2, (RULES_WIDTH-SEP)/2 ) );
s2 = s1;

width = ceil( max( CARD_HEIGHT, BOARD_HEIGHT, RULES_HEIGHT ) );
length = 2*INNER + 1*SEP + s1 + s2;
height = 2*INNER + width;

echo( Width=width, BasicS1=s1, BasicS2=s2 );
echo( BasicInsideLength=length, BasicInsideHeight=height );
echo( BasicOutsideLength=length+2*OUTER, BasicOutsideHeight=height+2*OUTER );
echo( BasicOutsideDepth=BOTTOM+box_height+lid_height+BOTTOM );

module i3_flat_base() {

    difference() {
        // Outside of box
        minkowski() {
            cube( [ length, height, box_height+lid_height ] );
            cylinder( r=OUTER, h=OVERLAP );
        }
        
        // Remove upper lip
        translate( [ 0, 0, BOTTOM+box_height ] ) 
            cube( [ length, height, lid_height+OVERLAP ] );
        
        // Remove space for tiles
        translate( [ INNER, INNER, BOTTOM ] ) 
            cube( [ s1, width, box_height+OVERLAP ] );
        translate( [ INNER+s1+SEP, INNER, BOTTOM ] ) 
            cube( [ s2, width, box_height+OVERLAP ] );

        // Remove holes in bottom, for ease in removing tiles and parts
        translate( [ INNER+s1/2, INNER+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
        translate( [ INNER+s1+1*SEP+s2/2, INNER+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
    }
}

module i3_flat_top() {

    difference() {
        union() {
            minkowski() {
                cube( [ length, height, BOTTOM ] );
                cylinder( r=OUTER, h=BOTTOM );
            }
            translate( [ GAP, GAP, BOTTOM ] ) 
                cube( [ length-2*GAP, height-2*GAP, lid_height ] );
        }
        translate( [ INNER+GAP, INNER+GAP, BOTTOM ] ) 
            cube( [ length-2*INNER-2*GAP, height-2*INNER-2*GAP, lid_height+OVERLAP ] );
    }
}

box_height2 = DECK_THICKNESS + EXTRA_THICKNESS;
lid_height2 = ceil( box_height2 / 4 );

echo( FancyBoxHeight=box_height2, FancyLidHeight=lid_height2 );

module i4_base() {
    difference() {
        union() {
            minkowski() {
                cube( [ length, height, box_height2-lid_height2 ] );
                cylinder( r=OUTER, h=OVERLAP );
            }
            cube( [ length, height, box_height2 ]);
        }
        
        // Remove space for rules and boards
        translate( [ INNER, INNER, BOTTOM+box_height2-EXTRA_THICKNESS ] ) 
            cube( [ length-2*INNER, height-2*INNER, EXTRA_THICKNESS+OVERLAP ] );
        
        // Remove space for cards
        translate( [ INNER, INNER, BOTTOM ] ) 
            cube( [ s1, width, box_height2+OVERLAP ] );
        translate( [ INNER+s1+SEP, INNER, BOTTOM ] ) 
            cube( [ s2, width, box_height2+OVERLAP ] );

        // Remove holes in bottom, for ease in removing tiles and parts
        translate( [ INNER+s1/2, INNER+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
        translate( [ INNER+s1+1*SEP+s2/2, INNER+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
    }
}

module i4_top() {
    difference() {
        // Outside of lid
        minkowski() {
            cube( [ length, height, lid_height2 ] );
            cylinder( r=OUTER, h=OVERLAP );
        }
        
        translate( [ 0, 0, BOTTOM ] )
            cube( [ length, height, lid_height2+OVERLAP ] );
    }
}

show=6;

if (show == 1) {
    i3_flat_base();
} else if (show == 2) {
    i3_flat_top();
} else if (show == 3) {
    translate( [ 0,   0, 0 ] ) i3_flat_base();
    translate( [ 0, height+2*OUTER+10, 0 ] ) i3_flat_top();
} else if (show == 4) {
    i4_base();
} else if (show == 5) {
    i4_top();
} else if (show == 6) {
    translate( [ 0,   0, 0 ] ) i4_base();
    translate( [ 0, height+2*OUTER+10, 0 ] ) i4_top();
}

if (0) {
    echo( DELUXE_THICKNESS=DELUXE_THICKNESS, BASIC_THICKNESS=BASIC_THICKNESS );
    echo( TILE_WIDTH=TILE_WIDTH, SMALL_TILE_HEIGHT=SMALL_TILE_HEIGHT, LARGE_TILE_HEIGHT=LARGE_TILE_HEIGHT );
    echo( LARGE=16*DELUXE_THICKNESS, SMALL=14*DELUXE_THICKNESS, WIDTH=TILE_WIDTH );
    echo( 5*DELUXE_THICKNESS, SMALL_TILE_HEIGHT-5*DELUXE_THICKNESS );
}