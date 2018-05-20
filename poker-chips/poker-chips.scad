// Poker Chip trays
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

ECLIPSE = [
    3.30*mm,        // Chip Thickness
    40.10*mm,       // Chip Diameter
    25,             // Chips per Row
    4,              // Rows per Rack
];

CUSTOM = [
    3.38*mm,        // Chip Thickness
    40.00*mm,       // Chip Diameter
    25,             // Chips per Row
    4,              // Rows per Rack
];

STANDARD_14G = [
    3.40*mm,        // Chip Thickness
    41.00*mm,       // Chip Diameter
    25,             // Chips per Row
    4,              // Rows per Rack
];


// ----- Physical dimensions --------------------------------------------------

THIN_WALL = 0.86 * mm;  // Based on 0.20mm layer height (2 lines)
WIDE_WALL = 1.67 * mm;  // Based on 0.20mm layer height (4 lines)
SLICING   = 0.20 * mm;  // Preferred slicing thickness;

SPACING =  1.0 * mm;    // Room for tiles to shift
GAP  = 0.25 * mm;       // Size differential between box and lid, for snug fit

OVERLAP = 0.01 * mm;    // Ensures that there are no vertical artifacts leftover

// ----- Calculated Measurements ----------------------------------------------

BOTTOM = 4 * SLICING;
INNER = THIN_WALL;
OUTER = WIDE_WALL;

$fa=4; $fn=60;

// ----- Sizing Functions -----------------------------------------------------

function optimized_slice( thickness ) = round( thickness / SLICING ) * SLICING;
function cutout( diameter ) = 5/8 * diameter;
function divider( diameter ) = optimized_slice(3/8 * diameter);
function lip( diameter ) = optimized_slice(1/2 * diameter);

// ----- Components -----------------------------------------------------------

module chip_tray( parameters ) {
    thickness = parameters[0];
    diameter  = parameters[1];
    chips     = parameters[2];
    rows      = parameters[3];
    
    inner_x = rows * diameter + (rows-1) * SPACING;
    inner_y = chips * thickness + 2/3 * thickness;
    inner_z = optimized_slice( diameter * 3/4 );
    
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
                cylinder( r=OUTER, h=OVERLAP );
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
    thickness = parameters[0];
    diameter  = parameters[1];
    chips     = parameters[2];
    rows      = parameters[3];
    
    lip_z = lip( diameter / 2 );
    
    inner_x = rows * diameter + (rows-1) * SPACING;
    inner_y = chips * thickness + 2/3 * thickness;
    inner_z = optimized_slice( diameter * 1/4 + SPACING);
    
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
            cylinder( r=OUTER, h=OVERLAP );
        }
        
        // Remove all space above lip
        translate( [0, 0, outer_z-inner_z] ) cube( [outer_x, outer_y, outer_z] );
        
        // Remove inner space
        translate( [INNER, INNER, BOTTOM] ) cube( [inner_x, inner_y, outer_z] );
        
        // Remove thumb holes
        translate( [ outer_x/2-OVERLAP, outer_y/2-OVERLAP, cut_z ] ) rotate( [0, 90, 0] ) cylinder( h=outer_x+2*OUTER+4*OVERLAP, r=cut_r, center=true );
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

if (VERBOSE) {
	echo (Part=PART);
}

if (PART == "14g-tray") {
    chip_tray( STANDARD_14G );
} else if (PART == "14g-lid") {
    chip_lid( STANDARD_14G );
} else if (PART == "eclipse-tray") {
    chip_tray( ECLIPSE );
} else if (PART == "eclipse-lid") {
    chip_lid( ECLIPSE );
} else {
    place( [0,  0,0] ) chip_lid( STANDARD_14G );
    place( [0,100,0] ) chip_tray( STANDARD_14G );
}
