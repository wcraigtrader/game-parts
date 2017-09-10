// Outpost 20th Anniversary Edition
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Physical dimensions of a sleeved card
CARD_WIDTH = 47 * mm;
CARD_HEIGHT = 72 * mm;
CARD_THICKNESS = 0.6 * mm;

// Define sizes of tray slots
tray1 = [
    36, // Ore
    39, // Water
    12, // Mega Water
    53, // Titanium
     9, // Mega Titanium
];

tray2 = [
    23, // New Chemicals
     6, // Mega New Chemicals
    34, // Research
    16, // Microbiotics
    14, // Orbital Medicine
    12, // Ring Ore
    12, // Moon Ore
];

large_tray = concat( tray1, tray2 );

// Physical dimensions
WALL = 0.8 * mm;    // Slicing filament thickness
GAP  = 0.2 * mm;    // Size differential between box and lid, for snug fit
PADDING = 4 * mm;   // Additional space for each slot, to make 
SPACING = 10 * mm;  // Space around cards to make them easier to insert / extract
LID = 1 * mm;       // Thickness of lid top
BOTTOM = 1 * mm;    // Thickness of box bottom
OVERLAP = 0.1 * mm; // To ensure no artifacts

// Inner and Outer wall dimensions
OUTER = 2.5 * WALL;
INNER = 2.5 * WALL;

// Command Line Arguments
PART = 2;           // Which part to output
VERBOSE = 1;        // Set to non-zero to see more data

if (VERBOSE) echo (Bottom=BOTTOM, Lid=LID, InnerWall=INNER, OuterWall=OUTER);

$fn=45;

// For a given slot (1 to n), calculate the depth of the slot
function slot_size( trayz, n ) = trayz[n-1] * CARD_THICKNESS + PADDING;

// For a given slot, calculate the width of that slot, plus all previous slots
function sum_sizes( trayz, n ) = n <= 0 ? 0 : sum_sizes( trayz, n-1 ) + slot_size( trayz, n );

// ----- Render the card tray itself ------------------------------------------

module tray_bottom( trayz ) {
    slots = len( trayz );
    
    inner_x = sum_sizes( trayz, slots ) + (slots-1) * INNER;
    inner_y = CARD_HEIGHT + SPACING;
    inner_z = CARD_WIDTH;
    
    box_x = inner_x + 2 * INNER;
    box_y = inner_y + 2 * INNER;
    box_z = inner_z / 5 + BOTTOM;
    
    lip_x = inner_x + 2 * INNER;
    lip_y = inner_y + 2 * INNER;
    lip_z = inner_z / 2 + BOTTOM;
    
    div_z = 2/3 * inner_z;
    div_r = INNER / 2;
    
    if (VERBOSE) {
        echo (InnerLength=inner_x, InnerDepth=inner_y, InnerHeight=inner_z);
        echo (LipLength=lip_x, LipDepth=lip_y, LipHeight=lip_z, DividerHeight=div_z+div_r);
    }
    echo (TrayLength=box_x+2*OUTER, TrayDepth=box_y+2*OUTER, TrayHeight=box_z);
    
    union() {
        difference() {
            union() {
                minkowski() {
                    cube( [ box_x, box_y, box_z ] );
                    cylinder( r=OUTER, h=1 );
                }
                cube( [ lip_x, lip_y, lip_z ] );
            }
            
            // Remove inside of box
            translate( [ INNER, INNER, BOTTOM ] )
                cube( [ inner_x, inner_y, inner_z+OVERLAP ] );
        }
        
        for (s=[1:slots-1]) {
            sx = sum_sizes(trayz, s);
            dx = sx + s*INNER;
            
            if (VERBOSE) {
                echo (s=s, ss=trayz[s-1], sl=slot_size(trayz, s), sx=sx, dx=dx );
            }
            
            translate( [dx,INNER,BOTTOM] ) {
                cube( [INNER, inner_y, div_z] );
                translate( [div_r,0,div_z] )
                    rotate( [-90,0,0])
                        cylinder( h=inner_y, r=div_r );
            }
        }
    }
}

// ----- Render a lid for the tray --------------------------------------------

module tray_lid(trayz) {
    slots = len( trayz );
    
    inner_x = sum_sizes( trayz, slots ) + (slots-1) * INNER;
    inner_y = CARD_HEIGHT + SPACING;
    inner_z = CARD_WIDTH;
    
    lid_x = inner_x + 2 * INNER;
    lid_y = inner_y + 2 * INNER;
    lid_z = 4/5 * inner_z + LID;
    
    out_x = lid_x + 2 * OUTER;
    out_y = lid_y + 2 * OUTER;
    
    notch_r = 10 * mm;
    
    if (VERBOSE) {
        echo (InnerLength=inner_x, InnerDepth=inner_y, InnerHeight=inner_z);
    }
    echo (LidLength=out_x, LidDepth=out_y, LidHeight=lid_z);

    difference() {
        // Outside of lid
        minkowski() {
            cube( [ lid_x, lid_y, lid_z ] );
            cylinder( r=OUTER, h=OVERLAP );
        }
        
        // Remove inside of lid
        translate( [ 0, 0, LID ] )
            cube( [ lid_x, lid_y, lid_z+OVERLAP ] );
        
        // Remove notches to make it easier to remove the lid
        translate( [out_x/2-OUTER-OVERLAP,lid_y/2,lid_z] ) 
            rotate( [0,90,0] )
                cylinder( r=notch_r, h=out_x+4*OVERLAP, center=true );
    }
}

// ----- Choose which part to output ------------------------------------------
 
if (PART == 1) {
    tray_bottom(large_tray);
} else if (PART == 2) {
    tray_lid(large_tray);
} else if (PART == 3) {
    tray_bottom(tray1);
} else if (PART == 4) {
    tray_lid(tray1);
} else if (PART == 5) {
    tray_bottom(tray2);
} else if (PART == 6) {
    tray_lid(tray2);
}
