// Race for the Galaxy: Jump Drive
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <functions.scad>;

// Command Line Arguments
PART = 0;           // Which part to output
VERBOSE = 1;        // Set to non-zero to see more data

// Box

FILAMENT = 0.8 * mm; // Thickness of a line of filament

LID   = 2 * mm;
OUTER = 2.5 * FILAMENT;
INNER = 2.5 * FILAMENT;
SEP   = 2.5 * FILAMENT;

GAP = FILAMENT/4;

$fn=90; // Fine-grained corners

CW = 69 * mm;           // (X) Width of card
CH = 96 * mm;           // (Y) Height of card
CZ = 36 * mm;           // (Z) Thickness of card stack

P1 = 35 * mm;           // (Y) Space for 5's and Explore Tiles
P2 = CH - P1 - SEP;     // (Y) Space for 1's and 10's
PZ = 20 * mm;           // (Z) Inner height of chit box

LZ = PZ/2 + LID;

BX = 2*CW + 2*INNER + SEP;
BY = CH + 2*INNER;
BZ = LID + CZ + LID + PZ/2;


module card_tray() {
    difference() {
        // Outside of box
        minkowski() {
            cube( [ BX, BY, BZ ] );
            cylinder( r=OUTER, h=1 );
        }
        
        // Space for chit tray
        translate( [ 0, 0, LID+CZ ] )
            cube( [ BX, BY, PZ+1 ] );
        
        // Space for card decks
        translate( [ INNER, INNER, LID ] )
            cube( [ CW, CH, CZ+1 ] );
        translate( [ INNER+CW+SEP, INNER, LID ] )
            cube( [ CW, CH, CZ+1 ] );
        translate( [ INNER+CW-GAP, INNER, LID+CZ-3 ] )
            cube( [ SEP+2*GAP, CH, 3+1 ] );
        
        // Space for finger holes
        translate( [ INNER+CW/2, INNER+CH/2, -LID ] ) 
            cylinder( r=10,h=CZ );
        translate( [ INNER+CW+SEP+CW/2, INNER+CH/2, -LID ] ) 
            cylinder( r=10,h=CZ );
    }
}

module chit_tray() {
    difference() {
        // Outside of box
        cube( [ BX-2*GAP, BY-2*GAP, PZ ] );
        
        translate( [ INNER+GAP, INNER+GAP, LID ] )
            cube( [ CW-2*GAP, P1-GAP, PZ ] );
        translate( [ INNER+GAP+CW+SEP, INNER+GAP, LID ] )
            cube( [ CW-2*GAP, P1-GAP, PZ ] );
        translate( [ INNER+GAP, INNER+GAP+P1+SEP, LID ] )
            cube( [ CW-2*GAP, P2-GAP, PZ ] );
        translate( [ INNER+GAP+CW+SEP, INNER+GAP+P1+SEP, LID ] )
            cube( [ CW-2*GAP, P2-GAP, PZ ] );
    }
}

module box_lid() {
    difference() {
        // Outside of lid
        minkowski() {
            cube( [ BX, BY, LZ ] );
            cylinder( r=OUTER, h=1 );
        }
        
        translate( [ 0, 0, LID ] )
            cube( [ BX, BY, LZ+1 ] );
    }
}

if (PART == 1) {
    chit_tray();
} else if (PART == 2) {
    card_tray();
} else if (PART == 3) {
    box_lid();
} else if (PART == 0) {
    chit_tray();
    translate( [ 0, BY+5, 0] ) card_tray();
    translate( [ BX+5, 0, 0] ) box_lid();
}

