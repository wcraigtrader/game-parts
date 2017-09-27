// Puerto Rico Anniversary Edition
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";           // Which part to output
VERBOSE = 1;        // Set to non-zero to see more data

// Physical dimensions
WALL = 0.8 * mm; // Slicing filament thickness
GAP  = 0.2 * mm; // Size differential between box and lid, for snug fit
POKE_HOLE = 20 * mm; // Diameter of poke holes in bottom
BOTTOM = 1 * mm;

// Tile dimensions
BASIC_THICKNESS = 7/128 * inch;
DELUXE_THICKNESS = 1/8 * inch;
TILE_WIDTH = (1 + 37/64) * inch;
SMALL_TILE_HEIGHT = 29/32 * inch;
LARGE_TILE_HEIGHT = (1 + 57/64) * inch;

// Wall dimensions
OUTER  = 2 * WALL;
INNER  = 2 * WALL;
SEP    = 2 * WALL;

OVERLAP = 0.1 * mm; // Ensures that there are no vertical artifacts leftover

$fa=4;

module basic_bottom() {
    box_height = ceil( max( SMALL_TILE_HEIGHT/2, 5*BASIC_THICKNESS) );
    lid_height = ceil( SMALL_TILE_HEIGHT ) - box_height;

    s1 = ceil( 16*BASIC_THICKNESS );
    s2 = ceil( 14*BASIC_THICKNESS );
    s3 = ceil( 14*BASIC_THICKNESS );
    s4 = ceil( LARGE_TILE_HEIGHT );

    width = ceil( TILE_WIDTH );
    length = 2*INNER + 3*SEP + s1 + s2 + s3 + s4;
    height = 2*INNER + width;

	if (VERBOSE) {
        echo( Width=width, BasicS1=s1, BasicS2=s2, BasicS3=s3, BasicS4=s4 );
        echo( BasicInsideLength=length, BasicInsideHeight=height );
        echo( BasicOutsideLength=length+2*OUTER, BasicOutsideHeight=height+2*OUTER );
	}

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
        translate( [ INNER+s1+s2+2*SEP, INNER, BOTTOM ] ) 
            cube( [ s3, width, box_height+OVERLAP ] );
        translate( [ INNER+s1+s2+s3+3*SEP, INNER, BOTTOM ] ) 
            cube( [ s4, width, box_height+OVERLAP ] );

        // Remove holes in bottom, for ease in removing tiles and parts
        translate( [ INNER+s1+s2+s3+3*SEP+s4/2, INNER+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
    }
}

module basic_top() {
    box_height = ceil( max( SMALL_TILE_HEIGHT/2, 5*BASIC_THICKNESS) );
    lid_height = ceil( SMALL_TILE_HEIGHT ) - box_height;

    s1 = ceil( 16*BASIC_THICKNESS );
    s2 = ceil( 14*BASIC_THICKNESS );
    s3 = ceil( 14*BASIC_THICKNESS );
    s4 = ceil( LARGE_TILE_HEIGHT );

    width = ceil( TILE_WIDTH );
    length = 2*INNER + 3*SEP + s1 + s2 + s3 + s4;
    height = 2*INNER + width;

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

module deluxe_bottom() {
    box_height = ceil( max( SMALL_TILE_HEIGHT/2, 5*DELUXE_THICKNESS) );
    lid_height = ceil( SMALL_TILE_HEIGHT ) - box_height;

    large = ceil( max( LARGE_TILE_HEIGHT, 16*DELUXE_THICKNESS ) );
    small = ceil( 14*DELUXE_THICKNESS );
    width = ceil( TILE_WIDTH );

    length = 2*INNER + large + SEP + small;
    height = 2*INNER + 2*width + SEP;

	if (VERBOSE) {
        echo( Width=width, DeluxeLarge=large, DeluxeSmall=small );
        echo( DeluxeInsideLength=length, DeluxeInsideHeight=height );
        echo( DeluxeOutsideLength=length+2*OUTER, DeluxeOutsideHeight=height+2*OUTER );
	}

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
            cube( [ large, width, box_height+OVERLAP ] );
        translate( [ INNER, INNER+width+SEP, BOTTOM ] ) 
            cube( [ large, width, box_height+OVERLAP ] );
        translate( [ INNER+large+SEP, INNER, BOTTOM ] ) 
            cube( [ small, width, box_height+OVERLAP ] );
        translate( [ INNER+large+SEP, INNER+width+SEP, BOTTOM ] ) 
            cube( [ small, width, box_height+OVERLAP ] );
        
        // Remove holes in bottom, for ease in removing tiles and parts
        translate( [ INNER+large/2, INNER+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
        translate( [ INNER+large/2, INNER+width+SEP+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
        translate( [ INNER+large+SEP+small/2, INNER+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
        translate( [ INNER+large+SEP+small/2, INNER+width+SEP+width/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
    }
}

module deluxe_top() {
    box_height = ceil( max( SMALL_TILE_HEIGHT/2, 5*DELUXE_THICKNESS) );
    lid_height = ceil( SMALL_TILE_HEIGHT ) - box_height;

    large = ceil( max( LARGE_TILE_HEIGHT, 16*DELUXE_THICKNESS ) );
    small = ceil( 14*DELUXE_THICKNESS );
    width = ceil( TILE_WIDTH );

    length = 2*INNER + large + SEP + small;
    height = 2*INNER + 2*width + SEP;

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

if (VERBOSE) {
	echo (Part=PART);
    echo( DELUXE_THICKNESS=DELUXE_THICKNESS, BASIC_THICKNESS=BASIC_THICKNESS );
    echo( TILE_WIDTH=TILE_WIDTH, SMALL_TILE_HEIGHT=SMALL_TILE_HEIGHT, LARGE_TILE_HEIGHT=LARGE_TILE_HEIGHT );
    echo( LARGE=16*DELUXE_THICKNESS, SMALL=14*DELUXE_THICKNESS, WIDTH=TILE_WIDTH );
    echo( 5*DELUXE_THICKNESS, SMALL_TILE_HEIGHT-5*DELUXE_THICKNESS );
}

if (PART == "limited-box") {
    deluxe_bottom();
} else if (PART == "limited-lid") {
    deluxe_top();
} else if (PART == "basic-box") {
    basic_bottom();
} else if (PART == "basic-lid") {
    basic_top();
} else {
    translate( [   0,   0, 0 ] ) deluxe_bottom();
    translate( [   0, 100, 0 ] ) deluxe_top();
    translate( [ 110,   0, 0 ] ) basic_bottom();
    translate( [ 110,  60, 0 ] ) basic_top();
}
