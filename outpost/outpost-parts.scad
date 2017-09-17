// Outpost 20th Anniversary Edition
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Tile dimensions
TILE_THICKNESS = 2 * mm;
TILE_WIDTH = 20 * mm;
TILE_COUNT = 10;

// Physical dimensions
WALL = 0.8 * mm;  // Slicing filament thickness
GAP  = 0.2 * mm;  // Size differential between box and lid, for snug fit
SPACING = 2 * mm; // Space around tiles to make them easier to insert / extract
LID = 1 * mm;
BOTTOM = 1 * mm;

// Wall dimensions
OUTER = 2 * WALL;
INNER = 2 * WALL;

OVERLAP = 0.1 * mm; // Ensures that there are no vertical artifacts leftover

// Command Line Arguments
PART = "box";       // Which part to output
VERBOSE = 1;        // Set to non-zero to see more data

$fn=45;

function inside( cells ) = cells * (TILE_WIDTH + SPACING) + (cells - 1) * INNER;

module parts_dividers() {
    row_x = inside( 4 );
    col_y = inside( 5 );
    div_z = TILE_COUNT * TILE_THICKNESS;
    
    dy = inside( 3 );
    dx = inside( 2 );
    
    if (VERBOSE) {
        echo (InsideLength=row_x, InsideDepth=col_y, InsideHeight=div_z);
    }

    union() {
        translate( [0,dy,0] ) cube( [row_x, INNER, div_z ] );
        translate( [dx,dy+INNER,0] ) cube( [INNER, inside(2), div_z] );
    }
}

module parts_bottom() {
    row_x = inside( 4 );
    col_y = inside( 5 );
    div_z = TILE_COUNT * TILE_THICKNESS;
    
    box_x = row_x + 2 * INNER;
    box_y = col_y + 2 * INNER;
    box_z = div_z - ceil( div_z / 2 );
    
    lip_x = row_x + 2 * INNER;
    lip_y = col_y + 2 * INNER;
    lip_z = div_z;
    
    echo (BoxLength=box_x, BoxDepth=box_y, BoxHeight=box_z);
    
    union() {
        difference() {
            union() {
                minkowski() {
                    cube( [ box_x, box_y, box_z ] );
                    cylinder( r=OUTER, h=1 );
                }
                translate( [ 0, 0, BOTTOM ] )
                    cube( [ lip_x, lip_y, lip_z ] );
                
            }
            
            // Remove inside of box
            translate( [ INNER, INNER, BOTTOM ] )
                cube( [ row_x, col_y, div_z+1 ] );
        }
        
        translate( [ INNER, INNER, BOTTOM ] )
            parts_dividers();
    }
}

module parts_lid() {
    row_x = inside( 4 );
    col_y = inside( 5 );
    div_z = TILE_COUNT * TILE_THICKNESS;
    
    lid_x = row_x + 2 * INNER;
    lid_y = col_y + 2 * INNER;
    lid_z = ceil( div_z / 2 );
    
    lid_r = 10 * mm;
    
    echo (LidLength=lid_x, LidDepth=lid_y, LidHeight=lid_z);

    difference() {
        // Outside of lid
        minkowski() {
            cube( [ lid_x, lid_y, lid_z ] );
            cylinder( r=OUTER, h=LID );
        }
        
        // Remove inside of lid
        translate( [ 0, 0, LID ] )
            cube( [ lid_x, lid_y, lid_z+1 ] );
        
        // Remove notches to make it easier to remove the lid
        translate( [-2*OUTER,lid_y/2+OUTER/2,lid_r-0+lid_z-2*OUTER] ) 
            rotate( [0,90,0] )
                cylinder( r=lid_r, h=lid_x+4*OUTER );
    }
}

// ----- Choose which part to output ------------------------------------------

if (PART == "box") {
    parts_bottom();
} else if (PART == "lid") {
    parts_lid();
}
