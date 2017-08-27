// Outpost 20th Anniversary Edition
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Tile dimensions
TILE_THICKNESS = 2 * mm;
TILE_WIDTH = 20 * mm;
SMALL_TILE_HEIGHT = 20 * mm;
LARGE_TILE_HEIGHT = 40 * mm;
TILE_COUNT = max( 6, 9, 10 );

// Physical dimensions
WALL = 0.8 * mm;  // Slicing filament thickness
GAP  = 0.2 * mm;  // Size differential between box and lid, for snug fit
SPACING = 1.5 * mm; // Space around tiles to make them easier to insert / extract
LID = 1 * mm;
BOTTOM = 1 * mm;

// Wall dimensions
OUTER = 2 * WALL;
INNER = 2 * WALL;

OVERLAP = 0.1 * mm; // Ensures that there are no vertical artifacts leftover

$fn=45;

/*
 * Module / Function arguments:
 *
 * tiles    Number of tiles to stack vertically
 * rows     Number of rows of tiles
 * smalls   Number of small tiles per row
 * larges   Number of large tiles per row
 * extras   Size of extra storage bin (mm) per row
 * notches  True (default) to cut notches in the inside tile walls.
 */

tw = TILE_WIDTH + SPACING;
sth = SMALL_TILE_HEIGHT + SPACING;
lth = LARGE_TILE_HEIGHT + SPACING;
    
function inside_length( smalls, larges, extras ) = extras + smalls * sth + larges * lth + (sign(extras)+smalls-1+larges) * INNER;
function inside_depth( rows ) = rows * tw + (rows-1) * INNER;
function inside_height( tiles ) = tiles * TILE_THICKNESS;

module box_dividers(tiles, rows, smalls, larges, extras=40, notched=true) {
    row_x = inside_length( smalls, larges, extras );
    col_y = inside_depth( rows );
    div_z = inside_height( tiles );
    
    echo (InsideLength=row_x, InsideDepth=col_y, InsideHeight=div_z);

    row_cuts   = [ [0,1*tw/3], [0,2*tw/3],  [div_z+OVERLAP,2*tw/3],  [div_z+OVERLAP,1*tw/3] ];
    small_cuts = [ [0,1*sth/3], [0,2*sth/3], [div_z+OVERLAP,2*sth/3], [div_z+OVERLAP,1*sth/3] ];
    large_cuts = [ [0,1*lth/6], [0,5*lth/6], [div_z+OVERLAP,5*lth/6], [div_z+OVERLAP,1*lth/6] ];

    difference() {
        union() {
            // Row walls
            for (row = [1:rows-1]) {
                dy = row * tw + (row-1) * INNER;
                translate( [0,dy,0] ) cube( [row_x, INNER, div_z ] );
            }
            
            // Extra compartments
            if (extras > 0) {
                dx = extras;
                translate( [dx,0,0] ) cube( [INNER, col_y, div_z] );
            }
            
            // Small column walls
            for (col = [1:smalls-1]) {
                dx = extras + sign(extras) * INNER + col * (tw + INNER) - INNER;
                translate( [dx,0,0] ) cube( [INNER, col_y, div_z] );
            }
            
            // Large column walls
            for (col = [0:larges-1]) {
                dx = extras + sign(extras) * INNER + smalls * (sth + INNER) + col * (lth + INNER) - INNER;
                translate( [dx,0,0] ) cube( [INNER, col_y, div_z] );
            }
        }
        
        if (notched) {
            // Row cutouts
            for (row = [1:rows]) {
                dx = extras + sign(extras) * INNER + GAP;
                dy = row * tw + (row-1) * (INNER) - tw;
                translate( [dx,dy,div_z+OVERLAP/2] ) 
                    rotate( [0,90,0] )
                        linear_extrude( height=row_x-extras-sign(extras)*INNER )
                            polygon( row_cuts );
                
            }
            
            // Small column cutouts
            for (col = [1:smalls]) {
                dx = extras + sign(extras) * INNER + col * (sth + INNER) - INNER;
                translate( [dx,0,div_z+OVERLAP/2] )
                    rotate( [0,90,90] )
                        linear_extrude( height=col_y )
                            polygon( small_cuts );
                            
            }
            
            // Large column cutouts
            for (col = [1:larges]) {
                dx = extras + sign(extras) * INNER + smalls * (sth + INNER) + col * (lth + INNER) - INNER;
                translate( [dx,0,div_z+OVERLAP/2] )
                    rotate( [0,90,90] )
                        linear_extrude( height=col_y )
                            polygon( large_cuts );
                            
            }
        }
    }
}

module box_bottom(tiles, rows, smalls, larges, extras=40, notches=true) {
    row_x = inside_length( smalls, larges, extras );
    col_y = inside_depth( rows );
    div_z = inside_height( tiles );
    
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
            box_dividers( tiles, rows, smalls, larges, extras, notches );
    }
}

module box_lid(tiles, rows, smalls, larges, extras=40) {
    row_x = inside_length( smalls, larges, extras );
    col_y = inside_depth( rows );
    div_z = inside_height( tiles );
    
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


module placement(tiles, rows, smalls, larges, extras=40, notches=true) {
    offset = inside_depth( rows );
    x1 = 1 * (offset + 4 * INNER);
    x2 = 2 * (offset + 4 * INNER) + 5 * mm;
    
    translate( [x1,0,0] ) 
        rotate( [0,0,90] ) 
            box_bottom( tiles, rows, smalls, larges, extras, notches );
    translate( [x2,0,0] ) 
        rotate( [0,0,90] ) 
            box_lid( tiles, rows, smalls, larges, extras );
}

// box_dividers(5, 3, 2, 1, notched=true);
// box_dividers(10, 5, 4, 1, extras=0);

// box_bottom( 5, 2, 2, 1, 20 );
// box_lid( 5, 3, 2, 1, 20 );

box_bottom( TILE_COUNT, 5, 4, 1, 0 );
// box_lid( TILE_COUNT, 5, 4, 1, 0 );

// placement(5,3,2,1,20);
// placement(10,5,4,1,0);
