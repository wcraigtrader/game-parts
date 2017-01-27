// Puerto Rico Anniversary Edition
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <functions.scad>;

// Box

WALL = 0.8 * mm;

BOTTOM = 1 * mm;
OUTER  = 2 * WALL;
INNER  = 2 * WALL;
SEP    = 2 * WALL;

GAP = WALL/4;

S1 = 51 * mm;
S2 = 45 * mm;
WD = 41 * mm;
H1 = 16;
H2 = 9;

$fn=50;

module box_bottom() {
    difference() {
        // Outside of box
        minkowski() {
            cube( [ 2*INNER + S1 + SEP + S2, 2*INNER + 2*WD + SEP, H1+H2 ] );
            cylinder( r=OUTER, h=1 );
        }
        
        // Remove upper lip
        translate( [ 0, 0, BOTTOM+H1 ] ) 
            cube( [ 2*INNER + S1 + SEP + S2, 2*INNER + 2*WD + SEP, H1+H2 ] );
        
        // Remove space for tiles
        translate( [ INNER, INNER, BOTTOM ] ) 
            cube( [ S1, WD, H1+H2+10 ] );
        translate( [ INNER, INNER+WD+SEP, BOTTOM ] ) 
            cube( [ S1, WD, H1+H2+10 ] );
        translate( [ INNER+S1+SEP, INNER, BOTTOM ] ) 
            cube( [ S2, WD, H1+H2+10 ] );
        translate( [ INNER+S1+SEP, INNER+WD+SEP, BOTTOM ] ) 
            cube( [ S2, WD, H1+H2+10 ] );
        
        // Remove holes in bottom, for 
        translate( [ INNER+S1/2, INNER+WD/2, -BOTTOM ] ) 
            cylinder( r=10,h=H1 );
        translate( [ INNER+S1/2, INNER+WD+SEP+WD/2, -BOTTOM ] ) 
            cylinder( r=10,h=H1 );
        translate( [ INNER+S1+SEP+S2/2, INNER+WD/2, -BOTTOM ] ) 
            cylinder( r=10,h=H1 );
        translate( [ INNER+S1+SEP+S2/2, INNER+WD+SEP+WD/2, -BOTTOM ] ) 
            cylinder( r=10,h=H1 );
    }
}

module box_top() {
    difference() {
        union() {
            minkowski() {
                cube( [ 2*INNER + S1 + SEP + S2, 2*INNER + 2*WD + SEP, BOTTOM ] );
                cylinder( r=OUTER, h=1 );
            }
            translate( [ GAP, GAP, BOTTOM ] ) 
                cube( [ 2*INNER+S1+S2+SEP-2*GAP, 2*INNER+2*WD+SEP-2*GAP, H2 ] );
        }
        translate( [ INNER+GAP, INNER+GAP, BOTTOM ] ) 
            cube( [ S1+S2+SEP-2*GAP, 2*WD+SEP-2*GAP, H2+H1 ] );
    }
}


box_bottom();

translate( [ 120, 0, 0 ] ) box_top();