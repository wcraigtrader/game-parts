// Poker Chip trays
// by W. Craig Trader
//
// ----------------------------------------------------------------------------
// 
// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ 
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
// ----------------------------------------------------------------------------

include <../util/units.scad>;
include <../util/printers.scad>;
include <../util/boxes.scad>;

// ----- Command Line Arguments -----------------------------------------------

PART = "other";     // Which part to output
VERBOSE = true;     // Set to true to see more data

// ----- Component measurements -----------------------------------------------

THICKNESS = 0;      // Chip Thickness
DIAMETER  = 1;      // Chip Diameter
CHIPS     = 2;      // Chips per Row
ROWS      = 3;      // Rows per Rack
GROUPS    = 4;      // Breaks per Row

ECLIPSE      = [ 3.30 * mm, 40.10 * mm,   25, 4, 0 ];
CUSTOM       = [ 3.35 * mm, 40.00 * mm,   25, 5, 0 ];
STANDARD_14G = [ 3.40 * mm, 41.00 * mm,   25, 4, 0 ];
MINI_250     = [ 2.60 * mm,   7/8 * inch, 50, 5, 5 ];
MINI_300     = [ 2.60 * mm,   7/8 * inch, 50, 6, 5 ];
TEST         = [ 2.60 * mm,   7/8 * inch, 20, 2, 2 ];

CHIPCASE_200 = [ 3.40*mm, 41.00*mm, 20, 2 ];
CHIPCASE_300 = [ 3.40*mm, 41.00*mm, 20, 2 ];

// ----- Physical dimensions --------------------------------------------------

SPACING =  1.0 * mm;    // Room for tiles to shift

VARIANCE   = 1.02;          // Chip sizes may vary
SPACE_SIZE = WALL_WIDTH[2]; // Size of space between rows of chips
BREAK_SIZE = WALL_WIDTH[2]; // Size of break between groups of chips

// ----- Calculated Measurements ----------------------------------------------

// BOTTOM = 3 * LAYER_HEIGHT;
// INNER = WALL_WIDTH[2];
// OUTER = WALL_WIDTH[2];

$fa=4; $fn=60;

// ----- Sizing Functions -----------------------------------------------------

function stack_size(p,n=0)  = (n==0 ? p[CHIPS] : n)*p[THICKNESS]*VARIANCE;

function rack_width(p,b)  = p[ROWS]*p[DIAMETER]*VARIANCE + (p[ROWS]-1)*SPACE_SIZE;
function rack_depth(p,b)  = stack_size(p) + (p[GROUPS]-1)*BREAK_SIZE;
function rack_height(p,b) = layer_height( p[DIAMETER]*VARIANCE );

function rack_size(p,b)   = [ rack_width(p,b), rack_depth(p,b), rack_height(p,b) ];

function cutout( diameter )  = 5/8 * diameter;
function divider( diameter ) = layer_height(3/8 * diameter);

function lip( diameter )     = layer_height(1/2 * diameter);

// ----- Components -----------------------------------------------------------

/** rack_box -- Create a box to hold poker chips
 *
 * parameters -- vector of chip characteristics
 * borders    -- vector of physical characteristics (see STURDY)
 */

module rack_box( parameters, borders=STURDY ) {
    diameter  = parameters[DIAMETER]*VARIANCE;
    chips     = parameters[CHIPS];
    rows      = parameters[ROWS];
    groups    = parameters[GROUPS];
    
    outer     = borders[ OUTER ];
    inner     = borders[ INNER ];

    size = rack_size( parameters, borders );
    
    if (VERBOSE) {
        echo( RackBox_Size=size );
    }

    union() {
        difference() {
            overlap_box( size, HOLLOW, borders );

            // Remove thumb holes for chips
            for (row=[0:rows-1]) {
                tx = row * (diameter+inner) + diameter/2;
                translate( [ tx, size.y/2-OVERLAP, size.z ] ) rotate( [90, 0, 0] ) 
                    cylinder( h=size.y+2*outer+2*OVERLAP, d=cutout(diameter), center=true );
            }
        }

        // Add dividers between rows of chips
        for (row=[1:rows-1]) {
            rx = row * (diameter + SPACE_SIZE) - SPACE_SIZE/2 - inner/2;
            translate( [rx, -OVERLAP, -OVERLAP] ) cube( [inner, size.y+2*OVERLAP, divider( size.z) + OVERLAP ] );
        }

        // Add dividers between groups of chips
        if (groups > 0) {
            group_count = chips/groups;
            gdy = stack_size( parameters, group_count ) + BREAK_SIZE;

            for (group=[1:groups-1]) {
                gy = group * gdy - BREAK_SIZE;
                translate( [-OVERLAP, gy, -OVERLAP] ) 
                    cube( [size.x+2*OVERLAP, BREAK_SIZE, layer_height( BREAK_SIZE ) + OVERLAP] );
            }
        }
    }
}

/** rack_lid -- Create a lid for a box to hold poker chips
 *
 * parameters -- vector of chip characteristics
 * borders    -- vector of physical characteristics (see STURDY)
 */

module rack_lid( parameters, borders=STURDY ) {
    size = rack_size( parameters, borders );
    
    if (VERBOSE) {
        echo( RackLid_Size=size );
    }
    
    overlap_lid( size, borders );
}

module spacer1( parameters, spacing ) {
    thickness = parameters[THICKNESS];
    diameter  = parameters[DIAMETER];
    chips     = parameters[CHIPS];
    rows      = parameters[ROWS];

    spacer = [ diameter+spacing, chips*thickness, diameter/4 ];
 
    difference() {
        cube( spacer );
        
        translate( [0, -OVERLAP, diameter/2] ) rotate( [-90,0,0] ) cylinder( d=diameter, h=spacer.y+2*OVERLAP );
        translate( [spacer.x, -OVERLAP, diameter/2] ) rotate( [-90,0,0] ) cylinder( d=diameter, h=spacer.y+2*OVERLAP );
    }
}

module spacer2( parameters, spacing ) {
    thickness = parameters[THICKNESS];
    diameter  = parameters[DIAMETER];
    chips     = parameters[CHIPS];
    rows      = parameters[ROWS];

    fillet = 10 * mm;

    spacer = [ diameter+spacing-fillet, chips*thickness-fillet, diameter/4-fillet/2 ];
 
    $fn=90;
    
    difference() {
        translate( [0,0,fillet/4] ) minkowski() {
            cube( spacer );
            sphere( d=fillet/2 );
        }
        
       translate( [0-fillet/2, -fillet-OVERLAP, diameter/2] ) rotate( [-90,0,0] ) cylinder( d=diameter, h=spacer.y+2*fillet+2*OVERLAP );
       translate( [spacer.x+fillet/2, -fillet-OVERLAP, diameter/2] ) rotate( [-90,0,0] ) cylinder( d=diameter, h=spacer.y+2*fillet+2*OVERLAP );
    }
}

// ----- Render Logic for makefile --------------------------------------------

if (PART == "14g-box") {
    rack_box( STANDARD_14G );
} else if (PART == "14g-lid") {
    rack_lid( STANDARD_14G );
} else if (PART == "eclipse-box") {
    rack_box( ECLIPSE );
} else if (PART == "eclipse-lid") {
    rack_lid( ECLIPSE );
} else if (PART == "mini-250-box") {
    rack_box( MINI_250 );
} else if (PART == "mini-250-lid") {
    rack_lid( MINI_250 );
} else if (PART == "mini-300-box") {
    rack_box( MINI_300 );
} else if (PART == "mini-300-lid") {
    rack_lid( MINI_300 );
} else {
    
    o = STURDY[ OUTER ] + GAP;
    d = rack_height( TEST, STURDY );
    
    translate( [ 5, 5, 0 ] ) rack_box( TEST );
    // translate( [ o-5, 5-o, 0 ] ) mirror( [1,0,0] ) rack_lid( TEST ); 
    # translate( [5-o, 5-o, d ] ) mirror( VERTICAL) rack_lid( TEST );
}
