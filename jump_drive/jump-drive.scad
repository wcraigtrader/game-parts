// Race for the Galaxy: Jump Drive
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";           // Which part to output
VERBOSE = 1;        // Set to non-zero to see more data

if (VERBOSE) {
	echo (Part=PART);
}

// Physical dimensions
THIN_WALL = 0.86 * mm;  // Based on 0.20mm layer height
WIDE_WALL = 1.67 * mm;  // Based on 0.20mm layer height

// Box
LID   = 1 * mm;
OUTER = THIN_WALL;
INNER = THIN_WALL;
SEP   = THIN_WALL;

GAP = THIN_WALL/4;

$fn=90; // Fine-grained corners

CW = 69 * mm;           // (X) Width of card
CH = 96 * mm;           // (Y) Height of card
CZ = 36 * mm;           // (Z) Thickness of card stack

P1 = 37 * mm;           // (Y) Space for 5's and Explore Tiles
P2 = CH - P1 - SEP;     // (Y) Space for 1's and 10's
PZ = 20 * mm;           // (Z) Inner height of chit box

LZ = PZ/2 + LID;

BX = 2*CW + 2*INNER + SEP;
BY = CH + 2*INNER;
BZ = LID + CZ + LID + PZ/2;


if (VERBOSE) {
    echo (OUTER=OUTER, INNER=INNER, SEP=SEP, GAP=GAP);
    echo (CW=CW, BX=BX, CH=CH, BY=BY, P1=P1, P2=P2);
}

module card_tray() {
    difference() {
        // Outside of box
        minkowski() {
            cube( [ BX, BY, BZ ] );
            cylinder( r=OUTER, h=1 );
        }

        // Space for chit tray
        translate( [ 0, 0, LID+CZ ] ) cube( [ BX, BY, PZ+1 ] );

        // Space for card decks
        translate( [ INNER, INNER, LID ] ) cube( [ CW, CH, CZ+1 ] );
        translate( [ INNER+CW+SEP, INNER, LID ] ) cube( [ CW, CH, CZ+1 ] );
        translate( [ INNER+CW-GAP, INNER, LID+CZ-3 ] ) cube( [ SEP+2*GAP, CH, 3+1 ] );

        // Space for finger holes
        translate( [ INNER+CW/2, INNER+CH/2, -LID ] ) cylinder( r=10,h=CZ );
        translate( [ INNER+CW+SEP+CW/2, INNER+CH/2, -LID ] ) cylinder( r=10,h=CZ );
    }
}

module chit_tray() {

    bx = BX-2*GAP; by = BY-2*GAP;
    dx1 = INNER; dx2 = INNER + CW-GAP + SEP;
    dy1 = INNER; dy2 = INNER + P1-GAP + SEP;

    hx = CW-GAP; hy1 = P1-GAP; hy2 = P2-GAP;

    if (VERBOSE) {
        echo (bx=bx, by=by);
        echo (dx1=dx1, dy1=dy1, dx2=dx2, dy2=dy2);
        echo (hx=hx, hy1=hy1, hy2=hy2);
        echo (query=by-dy2-hy2);
    }

    difference() {
        // Outside of box
        cube( [ bx, by, PZ ] );

        translate( [ dx1, dy1, LID ] ) cube( [ hx, hy1, PZ ] );
        translate( [ dx2, dy1, LID ] ) cube( [ hx, hy1, PZ ] );
        translate( [ dx1, dy2, LID ] ) cube( [ hx, hy2, PZ ] );
        translate( [ dx2, dy2, LID ] ) cube( [ hx, hy2, PZ ] );
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

if (PART == "card-tray") {
    card_tray();
} else if (PART == "chit-tray") {
    chit_tray();
} else if (PART == "box-lid") {
    box_lid();
} else {
    chit_tray();
    translate( [ 0, BY+5, 0] ) card_tray();
    translate( [ BX+5, 0, 0] ) box_lid();
}

