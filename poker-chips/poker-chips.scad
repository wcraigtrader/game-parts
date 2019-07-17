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

ECLIPSE      = [ 3.30 * mm, 40.10 * mm,   25, 4, 1 ];
CUSTOM       = [ 3.35 * mm, 40.00 * mm,   25, 5, 1 ];
STANDARD_14G = [ 3.40 * mm, 41.00 * mm,   25, 4, 1 ];
MINI         = [ 2.60 * mm,   7/8 * inch, 50, 5, 5 ];
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

module chip_tray( parameters, borders=STURDY ) {
    thickness = parameters[THICKNESS];
    diameter  = parameters[DIAMETER];
    chips     = parameters[CHIPS];
    rows      = parameters[ROWS];
    
    inner_x = rows * diameter + (rows-1) * SPACING;
    inner_y = chips * thickness + 2/3 * thickness;
    inner_z = layer_height( diameter * 3/4 );
    
    outer_x = inner_x + 2*INNER;
    outer_y = inner_y + 2*INNER;
    outer_z = inner_z + BOTTOM;
    
    div_z = divider( diameter );
    lip_z = lip( diameter );
    cut_r = cutout( diameter/2 );
    cut_z = lip_z + cut_r;
    
    if (VERBOSE) {
        echo (TrayParameters=parameters);
        echo (TrayInnerX=inner_x, TrayInnerY=inner_y, TrayInnerZ=inner_z);
        echo (TrayOuterX=outer_x, TrayOuterY=outer_y, TrayOuterZ=outer_z);
        echo (TrayBorderX=outer_x+2*OUTER, TrayBorderY=outer_y+2*OUTER);
        echo (DividerHeight=div_z, LipHeight=lip_z, CutHeight=cut_z, CutRadius=cut_r);
    }
    
    difference() {
        // Outside of box
        union() {
            minkowski() {
                cube( [outer_x, outer_y, lip_z] );
                hemisphere( r=OUTER );
            }
            cube( [ outer_x, outer_y, outer_z] );
        }
        
        // Remove all space above dividers
        translate( [ INNER, INNER, BOTTOM+div_z ] ) cube ( [ inner_x, inner_y, inner_z+OVERLAP ] );
        
        // For each row
        for (row=[0:rows-1]) {
            sx = row * (diameter+SPACING) + INNER;
            tx = sx + (diameter+SPACING) / 2;
            
            // Remove space for chips below dividers
            translate( [ sx, INNER, BOTTOM ] ) cube( [ diameter, inner_y, inner_z+ OVERLAP ] );
            
            // Remove thumb holes for chips
            translate( [ tx, outer_y/2-OVERLAP, cut_z ] ) rotate( [90, 0, 0] ) cylinder( h=outer_y+4*OVERLAP, r=cut_r, center=true );
        }
    }
}


module chip_lid( parameters ) {
    thickness = parameters[THICKNESS];
    diameter  = parameters[DIAMETER];
    chips     = parameters[CHIPS];
    rows      = parameters[ROWS];
    
    lip_z = lip( diameter / 2 );
    
    inner_x = rows * diameter + (rows-1) * SPACING;
    inner_y = chips * thickness + 2/3 * thickness;
    inner_z = layer_height( diameter * 1/4 + SPACING);
    
    outer_x = inner_x + 2*INNER;
    outer_y = inner_y + 2*INNER;
    outer_z = inner_z + lip_z + BOTTOM; //  inner_z + BOTTOM;
    
    cut_r = cutout( diameter/2 );
    cut_z = outer_z - inner_z + cut_r;

    if (VERBOSE) {
        echo (LidParameters=parameters);
        echo (LidInnerX=inner_x, LidInnerY=inner_y, LidInnerZ=inner_z);
        echo (LidOuterX=outer_x, LidOuterY=outer_y, LidOuterZ=outer_z);
        echo (LidBorderX=outer_x+2*OUTER, LidBorderY=outer_y+2*OUTER);
        echo (LipHeight=lip_z, CutHeight=cut_z, CutRadius=cut_r);
    }
    
    difference() {
        // Outside of box
        minkowski() {
            cube( [outer_x, outer_y, outer_z] );
            hemisphere( r=OUTER );
        }
        
        // Remove all space above lip
        translate( [0, 0, outer_z-inner_z] ) cube( [outer_x, outer_y, outer_z] );
        
        // Remove inner space
        translate( [INNER, INNER, BOTTOM] ) cube( [inner_x, inner_y, outer_z] );
        
        // Remove thumb holes
        translate( [ outer_x/2-OVERLAP, outer_y/2-OVERLAP, cut_z ] ) rotate( [0, 90, 0] ) cylinder( h=outer_x+2*OUTER+4*OVERLAP, r=cut_r, center=true );
    }
}

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

    group_count = chips/groups;
    gdy = stack_size( parameters, group_count ) + BREAK_SIZE;

    size = rack_size( parameters, borders );
    
    if (VERBOSE) {
        echo( ChipBox_Size=size, x=rows*(diameter+inner)-inner, y=groups*gdy-BREAK_SIZE );
    }
    union() {
        difference() {
            overlap_box( size, HOLLOW, borders );

            // Remove thumb holes for chips
            for (row=[0:rows-1]) {
                tx = row * (diameter+inner) + diameter/2;
                echo( Row=row, TX=tx, size=cutout(diameter), diameter=diameter );
                translate( [ tx, size.y/2-OVERLAP, size.z ] ) rotate( [90, 0, 0] ) 
                    cylinder( h=size.y+2*outer+2*OVERLAP, d=cutout(diameter), center=true );
            }
        }
        
        // Add dividers between rows of chips
        for (row=[1:rows-1]) {
            rx = row * (diameter + SPACE_SIZE) - SPACE_SIZE/2 - inner/2;
            echo( Row=row, RX=rx, size=inner );
            translate( [rx, -OVERLAP, -OVERLAP] ) cube( [inner, size.y+2*OVERLAP, divider( size.z) + OVERLAP ] );
        }
        
        // Add dividers between groups of chips
        for (group=[1:groups-1]) {
            gy = group * gdy - BREAK_SIZE;
            echo( Group=group, GY=gy, size=BREAK_SIZE );
            translate( [-OVERLAP, gy, -OVERLAP] ) 
                cube( [size.x+2*OVERLAP, BREAK_SIZE, layer_height( BREAK_SIZE ) + OVERLAP] );
        }
    }

/*
        // Remove all space above dividers
        translate( [0, 0, divider( diameter ) ] ) cube( size ) ;


            // Remove space for chips below dividers
            translate( [ sx, 0, 0 ] ) cube( [ diameter, size.y, size.z + OVERLAP ] );
*/
}

/** rack_lid -- Create a lid for a box to hold poker chips
 *
 * parameters -- vector of chip characteristics
 * borders    -- vector of physical characteristics (see STURDY)
 */

module rack_lid( parameters, borders=STURDY ) {
    size = rack_size( parameters, borders );
    
    if (VERBOSE) {
        echo( ChipLid_Size=size );
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

module place( translation=[0,0,0], angle=0, hue="" ) {
	for (i = [0 : $children-1]) {
		translate( translation ) 
			rotate( a=angle ) 
				if ( hue != "" ) {
					color( hue ) children(i);
				} else {
					children(i);
				}
	}
}

if (PART == "14g-tray") {
    chip_tray( STANDARD_14G );
} else if (PART == "14g-lid") {
    chip_lid( STANDARD_14G );
} else if (PART == "eclipse-tray") {
    chip_tray( ECLIPSE );
} else if (PART == "eclipse-lid") {
    chip_lid( ECLIPSE );
} else if (PART == "mini-tray") {
    rack_box( MINI );
} else if (PART == "mini-lid") {
    rack_lid( MINI );
} else {
/*
    place( [5, 5,0] ) rounded_box( [90, 30, 16] );
    place( [5,45,0] ) rounded_lid( [90, 30, 16] );
    
    place( [ 105, 5, 0] ) spacer1( CHIPCASE_200, 1*cm );
    place( [ 160, 5, 0] ) 
*/
    
    // spacer2( CHIPCASE_300, 1*cm );
    
    // place( [0,  0,0] ) chip_tray( CHIPCASE );
//     place( [0,100,0] ) chip_lid( CHIPCASE );
    
    o = STURDY[ OUTER ] + GAP;
    d = rack_height( TEST, STURDY );
    
    translate( [ 5, 5, 0 ] ) rack_box( TEST );
    translate( [ o-5, 5-o, 0 ] ) mirror( [1,0,0] ) rack_lid( TEST ); 
    // # translate( [5-o, 5-o, d ] ) mirror( VERTICAL) rack_lid( TEST );
}
