// Terraforming Mars
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.
//
// ----------------------------------------------------------------------------

include <MCAD/units.scad>;

// ----- Command Line Arguments -----------------------------------------------

PART = "other";     // Which part to output
VERBOSE = true;     // Set to true to see more data

// ----- Component measurements -----------------------------------------------

$fn=90;             // Fine-grained corners
OVERLAP = 0.1;

// 3D Printer
LAYER_HEIGHT = 0.20 * mm;
THIN_WALL    = 0.86 * mm;  	// Based on 0.20mm layer height
WIDE_WALL    = 1.67 * mm;  	// Based on 0.20mm layer height

module arrow( size=5, thickness=3 ) {
    outer = 6 * size;
    inner = 4 * size;
    arrow = 2 * size;
    
    sq2 = sqrt(2);
    
    union() {
        difference() {
            translate( [0,0,0] ) cylinder( h=thickness, d=outer );
            translate( [0,0,-OVERLAP] ) cylinder( h=thickness+2*OVERLAP, d=inner );
            translate( [0,OVERLAP,-OVERLAP] ) cube( outer/2+OVERLAP, outer/2+OVERLAP, thickness+2*OVERLAP );
        }
        translate( [arrow+size/2,-sq2*size] ) 
            difference() {
                rotate( [0,0,45] ) cube( [arrow, arrow, thickness] );
                translate( [-sq2*size,-sq2*size,-OVERLAP] ) cube( [sq2*arrow,sq2*arrow,thickness+2*OVERLAP] );
            }
    }
}

module disk( size=60, thickness=3 ) {
    translate( [0,0,1] ) minkowski() {
        cylinder( d=size-2, h=thickness-2 );
        sphere( d=2 );
    }
}

module spinner_color_1( s=45, a=5, t=3 ) {
    difference() {
        disk( s, t );
        translate( [0,0,-OVERLAP] ) arrow( a, t+2*OVERLAP );
    }
}    

module spinner_color_2( s=45, a=5, t=3 ) {
    arrow( a, t );
}

module spinner_color_3( s=45, a=5, t=3 ) {
    difference() {
        disk( s-2*THIN_WALL, t );
        translate( [0, 0, 1/6*t-OVERLAP] ) cube( [s+2*OVERLAP, s+2*OVERLAP, t/3+2*OVERLAP], center=true );
        translate( [0, 0, 5/6*t+OVERLAP] ) cube( [s+2*OVERLAP, s+2*OVERLAP, t/3+2*OVERLAP], center=true );
    }
}

module spinner_color_4( s=45, a=5, t=3 ) {
    difference() {
        spinner_color_1( s, a, t );
        spinner_color_3( s+OVERLAP, a, t );
    }
}

// ----- Render Logic for makefile --------------------------------------------

if (VERBOSE) {
	echo (Part=PART);
}

if (PART == "spinner-hollow") {
    spinner_color_1();
} else if (PART == "spinner-color1") {
    spinner_color_1();
} else if (PART == "spinner-color2") {
    spinner_color_2();
} else if (PART == "spinner-color3") {
    spinner_color_3();
} else if (PART == "spinner-color4") {
    spinner_color_4();
} else if (PART == "spinner-inset") {
    spinner_color_1( 45, 5, 3 );
    translate( [0,0,1/2] ) arrow( 5, 2 );
} else {
    color( "yellow" ) spinner_color_3( 45, 5, 3 );
    color( "red" )    spinner_color_4( 45, 5, 3 );
//    color( "red" ) translate( [0,0,1/2] ) arrow( 5, 2 );
}
