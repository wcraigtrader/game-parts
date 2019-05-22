// Game Part Utilities
// by W. Craig Trader
//
// --------------------------------------------------------------------------------------------------------------------
// 
// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ 
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
// --------------------------------------------------------------------------------------------------------------------

// VERBOSE=true;

include <units.scad>;
include <printers.scad>;

// ----- Physical dimensions ------------------------------------------------------------------------------------------

NOTCH     = 10.0 * mm;  // Radius of notches

GAPZ      = 0.10 * mm;

DECK_BOX_SPACING =  1.00 * mm;
DECK_BOK_OVERLAP = 20.00 * mm;

$fa=4; $fn=30;

// ----- Card Sleeves -------------------------------------------------------------------------------------------------

/*
 * [0] = (X) width of sleeved card (mm)
 * [1] = (Z) height of sleeved card (mm)
 * [2] = (Y) average thickness of sleeved card (mm)
 */

FFS_SLEEVE = [ 66.70, 94.60, 0.625 ];

// ----- Calculated dimensions ----------------------------------------------------------------------------------------

SOLID   = 0;    // Not so much a box, as a block
HOLLOW  = 1;    // Standard box with sharp inside corners
ROUNDED = 2;    // Box with rounded inside corners

BOTTOM = 0;     // Bottom thickness
TOP    = 1;     // Top thickness
OUTER  = 2;     // Outer box walls thickness
INNER  = 3;     // Inside partition walls thickness
FILLET = 4;     // Size of inside fillet
BUMPS  = 5;     // Minimum spacing between bumps
STUBS  = 6;

REASONABLE = [ 5*LAYER_HEIGHT, 5*LAYER_HEIGHT, WALL_WIDTH[3], WALL_WIDTH[2], 1*mm, 20*mm, 2*mm ];

HORIZONTAL = [ 1, 1, 0 ];
VERTICAL   = [ 0, 0, 1 ];

// ----- Functions ----------------------------------------------------------------------------------------------------

function row_offset( cellz, space, r, c ) = (r <= 0) ? 0 : row_offset( cellz, space, r-1, c ) + cellz[r-1][c][1] + space;
function col_offset( cellz, space, r, c ) = (c <= 0) ? 0 : col_offset( cellz, space, r, c-1 ) + cellz[r][c-1][0] + space;

function row_length( cellz, space ) = col_offset( cellz, space, 0, len(cellz[0])) - space;
function col_length( cellz, space ) = row_offset( cellz, space, len(cellz), 0) - space;

function round_up( size, step ) = ceil( size / step ) * step;
function wall_sizes( borders ) = [ borders[ OUTER ]*4 + GAP*2, borders[ OUTER ]*4 + GAP*2, borders[ TOP ] + borders[ BOTTOM ] ];

// ----- Modules ------------------------------------------------------------------------------------------------------

/** hemisphere -- Create the lower half of a sphere
 *
 * r = radius of hemisphere (preferred)
 * d = diameter of hemisphere
 */
module hemisphere( r=0, d=0 ) {
    diameter = (r == 0) ? d : 2*r;

    difference() {
        sphere( d=diameter );
        translate( [0,0,diameter/2] ) cube( [diameter,diameter,diameter], true );
    }
}

/** dit -- Create a bump for a locking a lid to a box 
 *
 * r = radius of hemisphere (preferred)
 * d = diameter of hemisphere
 */
module dit( r=0, d=0 ) {
    s = (r == 0) ? d/2 : r;
    
    points = [ [0,0,s], [s,0,0], [0,s,0], [-s,0,0], [0,-s,0], [0,0,-s] ];
    triangles = [ [0,2,1], [0,3,2], [0,4,3], [0,1,4], [5,1,2], [5,2,3], [5,3,4], [5,4,1] ];

    polyhedron( points, triangles );
}

/** rounded_box -- Create an empty box with rounded corners and a lip for a lid
 * 
 * size    -- vector of sizes (X, Y, Z)
 * type    -- SOLID, HOLLOW, ROUNDED
 * borders -- vector of physical characteristics (see REASONABLE)
 */
 
module rounded_box( size, type=HOLLOW, borders=REASONABLE ) {
    outer1 = borders[OUTER];
    outer2 = borders[OUTER] + GAP;
    bottom = borders[BOTTOM];
    fillet = borders[FILLET];
    bumps  = borders[BUMPS];
    
    lip = layer_height( size.z/2 );
    
    midsize = [size.x+2*outer1, size.y+2*outer1, size.z];
    gapsize = [midsize.x+2*GAP, midsize.y+2*GAP, size.z];
    lipsize = [gapsize.x, gapsize.y, lip];
    outsize = [lipsize.x+2*outer1, lipsize.y+2*outer1, size.z+bottom];
    
    if (VERBOSE) {
        echo( RoundedBox_InSize=size, MidSize=midsize, GapSize=gapsize, LipSize=lipsize, OutSize=outsize );
    }
    
    difference() {
        union() {
            // Inner wall (full height)
            translate( [-outer1, -outer1, 0] ) cube( midsize );

            // Outer wall (lip height)
            translate( [-outer2, -outer2, 0] ) minkowski() {
                cube( lipsize );
                scale( [outer1, outer1, bottom] ) hemisphere( r=1 );
            }
        }
        
        // Remove inside, if necessary
        if (type == ROUNDED) {
            translate( [fillet, fillet, fillet] ) minkowski() {
                cube( [ size.x-2*fillet, size.y-2*fillet, size.z ] );
                hemisphere( fillet );
            }
        } else if (type == HOLLOW) {
            cube( [size.x, size.y, size.z+2*OVERLAP] );
        }
        
        if (bumps) {
            bump_count = floor( size.x / bumps );
            bdx = size.x / bump_count;
            bx  = bdx/2;
            bz  = lipsize.z + (size.z - lipsize.z) / 2;
            
            for (bump=[0:bump_count-1]) {
                translate( [bx+bdx*bump,-outer1,bz] ) dit( d=outer2 );
                translate( [bx+bdx*bump,size.y+outer1,bz] ) dit( d=outer2 );
            }
        }
    }
}

/** rounded_lid -- Create a lid for a box with rounded corners
 * 
 * size    -- vector of sizes (X, Y, Z)
 * borders -- vector of physical characteristics (see REASONABLE)
 */
module rounded_lid( size, borders=REASONABLE ) {
    outer1 = borders[OUTER];
    outer2 = borders[OUTER] + GAP;
    top    = borders[TOP];
    bumps  = borders[BUMPS];
    
    lip = size.z - layer_height( size.z/2 );
    
    midsize = [size.x+2*outer1, size.y+2*outer1, size.z];
    gapsize = [midsize.x+2*GAP, midsize.y+2*GAP, size.z];
    lipsize = [gapsize.x, gapsize.y, lip];
    outsize = [lipsize.x+2*outer1, lipsize.y+2*outer1, size.z+top];
    
    nz = (lip > NOTCH*1.5) ? lip : (lip < NOTCH/2 ? NOTCH : NOTCH/2 + lip);

    if (VERBOSE) {
        echo( RoundedLid_InSize=size, MidSize=midsize, GapSize=gapsize, LipSize=lipsize, OutSize=outsize, NotchZ=nz );
    }

    difference() {
       translate( [-outer2, -outer2, 0] ) minkowski() {
            cube( lipsize );
            scale( [outer1, outer1, top] ) hemisphere( r=1 );
        }

        difference() {
            translate( [-outer2, -outer2, 0] ) cube( gapsize );
            if (bumps) {
                bump_count = floor( size.x / bumps );
                bdx = size.x / bump_count;
                bx  = bdx/2;
                bz  = lipsize.z / 2;
                
                for (bump=[0:bump_count-1]) {
                    translate( [bx+bdx*bump,-outer2,bz] ) dit( d=outer2 );
                    translate( [bx+bdx*bump,size.y+outer2,bz] ) dit( d=outer2 );
                }
            }
        }
        
        translate( [-outer2-outer1-OVERLAP,size.y/2,nz] ) rotate( [0,90,0] ) cylinder( r=NOTCH, h=outsize.x+2*OVERLAP );
    }
}

/** cell_box -- Create a box with rows and columns of cells for storing small parts
 *
 * cells   -- Layout of cells (inside dimensions)
 * height  -- Height (Z) of cells (inside dimensions)
 * type    -- SOLID, HOLLOW, ROUNDED
 * holes   -- if true, then add finger holes to cells
 * borders -- vector of physical characteristics (see REASONABLE)
 *
 * cells is a vector of rows, each of which is a vector of cell dimensions [x,y]
 * The first row will be the top row in the resulting box, for ease of layout.
 *
 * example = [
 *     [ [10,10], [10,10], [10,10] ],
 *     [ [10,10], [21,10] ],
 *     [ [32,10] ]
 * ]
 *
 * This would create a box with 3 rows of cells, with 3 cells in the first row,
 * 2 cells in the second row, and 1 long cell in the third row. If you have
 * rows that have differing numbers of cells, you'll want to increase the size
 * of some cells to account for the walls that will be missing from in that row.
 */
module cell_box( cells, height, type=HOLLOW, holes=false, borders=REASONABLE ) {
    inner  = borders[INNER];
    bottom = borders[BOTTOM];
    fillet = borders[FILLET];

    inside = [
        row_length( cells, inner ),
        col_length( cells, inner ),
        height
    ];

    if (VERBOSE) {
        echo( CellBox_Cells=cells, Height=height, Type=type, Holes=holes, Borders=borders, Inside=inside );
    }

    difference() {
        rounded_box( inside, SOLID, borders );
        
        for ( row = [len(cells)-1:-1:0] ) {
            for ( col = [0:1:len(cells[row])-1 ] ) {
                cell = cells[row][col];
                dx = col_offset( cells, inner, row, col );
                dy = row_offset( cells, inner, row, 0 );

                if (dx==undef || dy==undef) {
                    echo( Position=[row,col], row=cells[row], dx=dx, dy=dy );
                }

                if (type == HOLLOW) {
                    translate( [ dx, dy, 0 ] )
                    cube( [ cell.x, cell.y, height+OVERLAP ] );
                } else if (type == ROUNDED) {
                    translate( [ dx, dy, fillet+OVERLAP ] ) minkowski() {
                        translate( [fillet, fillet, 0] ) cube( [ cell.x-2*fillet, cell.y-2*fillet, height+OVERLAP ] );
                        hemisphere( r=fillet );
                    }
                }
                
                if (holes) {
                    translate( [dx+cell.x/2, dy+cell.y/2, -bottom-OVERLAP] ) 
                        scale( [cell.x/2, cell.y/2, 1] ) 
                            cylinder( d=1, h=bottom+4*OVERLAP );
                }
            }
        }
    }
}

/** cell_lid -- Create a lid for a cell box
 *
 * cells   -- Layout of cells (inside dimensions)
 * height  -- Height (Z) of cells (inside dimensions)
 * borders -- vector of physical characteristics (see REASONABLE)
 */
module cell_lid( cells, height, type=HOLLOW, stubs=false, borders=REASONABLE ) {
    inner  = borders[INNER];
    top    = borders[TOP];
    fillet = borders[FILLET];
    stub   = borders[STUBS];
    
    inside = [
        row_length( cells, inner ),
        col_length( cells, inner ),
        height
    ];

    if (VERBOSE) {
        echo( CellLid_Inside=inside );
    }

    mirror( [ 1,0,0 ] ) union() {
        rounded_lid( inside, borders );
        
        if (stubs) {
            gap = [ inner/2+0.250, inner/2+0.25, 0];
            dgap = gap + gap;
            wall = [ inner, inner, 0];
            dwall = wall + wall;
            
            fillz = [ fillet, fillet, 9];
            overlap = [ 0, 0, OVERLAP ];
            
            intersection() {
                translate( wall + gap - overlap ) cube( [ inside.x, inside.y, stub] - dwall - dgap + overlap );
            
                for ( row = [len(cells)-1:-1:0] ) {
                    for ( col = [0:1:len(cells[row])-1 ] ) {
                        cell = cells[row][col];
                        hole = [ cell.x, cell.y, height+OVERLAP ];
                        delta = [ col_offset( cells, inner, row, col ), row_offset( cells, inner, row, 0 ), 0 ];

                        if (delta.x==undef || delta.y==undef) {
                            echo( Position=[row,col], row=cells[row], hole=hole, delta=delta );
                        }

                        difference() {
                            translate( delta + gap ) cube( hole - dgap );
                            translate( delta + gap + wall - overlap ) cube( hole - dgap - dwall + overlap );
                        }
                    }
                }
            }
        }
    }
}

module deck_box( sizes, quantity, wall ) {
    bottom = 1.00 * mm;
    top    = 1.00 * mm;

    inside_x = sizes[0] + DECK_BOX_SPACING;
    inside_y = sizes[2] * quantity + DECK_BOX_SPACING;
    inside_z = sizes[1] + DECK_BOX_SPACING;

    lip_x = inside_x + 2 * wall;
    lip_y = inside_y + 2 * wall;

    box_x = lip_x + 2 * GAP;
    box_y = lip_y + 2 * GAP;
    box_z = round_up( inside_z/2, LAYER_HEIGHT );
    
    lip_z = box_z + DECK_BOK_OVERLAP;

    if (VERBOSE) {
        echo( DeckBoxInside=[ inside_x, inside_y, inside_z ], DeckBoxOutside=[ box_x+wall, box_y+wall, box_z ] );
    }

    translate( [ -wall-GAP, -wall-GAP, -bottom ] ) difference() {
        union() {
            minkowski() {
                cube( [ box_x, box_y, box_z ] );
                cylinder( r=wall, h=OVERLAP );
            }
            translate( [ GAP, GAP, bottom-OVERLAP ] )
                cube( [ lip_x, lip_y, lip_z+OVERLAP ] );
        }
        
        translate( [GAP+wall, GAP+wall, bottom] )
            cube( [ inside_x, inside_y, inside_z+OVERLAP ] );
    }    
}

module deck_lid( sizes, quantity, wall ) {
    bottom = 1.00 * mm;
    top    = 1.00 * mm;

    inside_x = sizes[0] + DECK_BOX_SPACING;
    inside_y = sizes[2] * quantity + DECK_BOX_SPACING;
    inside_z = sizes[1] + DECK_BOX_SPACING;

    lip_x = inside_x + 2 * wall;
    lip_y = inside_y + 2 * wall;

    box_x = lip_x + 2 * GAP;
    box_y = lip_y + 2 * GAP;
    box_z = round_up( inside_z/2, LAYER_HEIGHT );
    
    lip_z = box_z;
    lip_r = NOTCH;

    if (VERBOSE) {
        echo( DeckLidInside=[ inside_x, inside_y, inside_z ], DeckLidOutside=[ box_x+wall, box_y+wall, lip_z ] );
    }

    translate( [ -wall-GAP, -wall-GAP, -bottom ] ) difference() {
        // Outside of lid
        minkowski() {
            cube( [ box_x, box_y, lip_z ] );
            cylinder( r=wall, h=OVERLAP );
        }

        // Remove inside of lid
        translate( [ wall+GAP, wall+GAP, top ] )
            cube( [ inside_x, inside_y, inside_z ] );

        translate( [ 0, 0, lip_z-DECK_BOK_OVERLAP ] ) 
            cube( [ lip_x, lip_y, box_z+OVERLAP ] );

        // Remove notches to make it easier to remove the lid
        translate( [-2*wall,lip_y/2+wall/2,lip_r-0+lip_z-2*wall] )
            rotate( [0,90,0] )
                cylinder( r=NOTCH, h=lip_x+4*wall );
    }
}

module thin_deck_box( sizes, quantity, wall ) {
    bottom = 0.6 * mm;

    inside_x = sizes[0] + DECK_BOX_SPACING;
    inside_y = sizes[2] * quantity + DECK_BOX_SPACING;
    inside_z = sizes[1] + DECK_BOX_SPACING;
    
    box_x = inside_x + 2 * wall;
    box_y = inside_y + 2 * wall;
    box_z = inside_z + bottom - 20 * mm;
    
    translate( [-wall, -wall, -bottom ] ) 
        difference() {
            cube( [ box_x, box_y, box_z ] );
            translate( [ wall, wall, bottom ] ) 
                cube( [ inside_x, inside_y, inside_z ] );
        }
}

// ----- Testing ---------------------------------------------------------------

/*
*/
if (0) {
    dx = 15; dy = 15;
    x1 = dx;
    x2 = dx + THIN_WALL + dx;
    x3 = dx + THIN_WALL + dx + THIN_WALL + dx;

    cell_test = [ 
        [ [x1,dy], [x3,dy] ], 
        [ [x1,dy], [x1,dy], [x2,dy] ], 
        [ [x2,dy], [x1,dy], [x1,dy] ], 
        [ [x3,dy], [x1,dy] ], 
    ];

//    translate( [ 0, 0, 0] ) rounded_box( [40, 40, 15], ROUNDED );
//    translate( [50, 0, 0] ) rounded_lid( [40, 40, 15] );

    translate( [ 5, 5, 0] ) cell_box( cell_test, 20, HOLLOW, true );
    translate( [-5, 5, 0] ) cell_lid( cell_test, 20, HOLLOW, true );
}
/*
*/
