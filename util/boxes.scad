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

DEBUG = is_undef( DEBUG ) ? (is_undef( VERBOSE ) ? true : VERBOSE) : DEBUG;

include <units.scad>;
include <printers.scad>;

// ----- Physical dimensions ------------------------------------------------------------------------------------------

NOTCH               = 10.00 * mm;   // Radius of thumb notches
DECK_BOX_SPACING    =  0.50 * mm;   // Padding for cards in deck boxes

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
NOTCHED = 3;    // Hollow box with notches for easily removing tiles

BOTTOM = 0;     // Bottom thickness
TOP    = 1;     // Top thickness
OUTER  = 2;     // Outer box walls thickness
INNER  = 3;     // Inside partition walls thickness
FILLET = 4;     // Size of inside fillet
BUMPS  = 5;     // Minimum spacing between bumps
STUBS  = 6;     // Height of lid stubs that overlap cell walls

REASONABLE = [ 5*LAYER_HEIGHT, 5*LAYER_HEIGHT, WALL_WIDTH[3], WALL_WIDTH[2], 1*mm, 20*mm, 2*mm ];
STURDY     = [ 5*LAYER_HEIGHT, 5*LAYER_HEIGHT, WALL_WIDTH[4], WALL_WIDTH[3], 1*mm, 20*mm, 2*mm ];

HORIZONTAL = [ 1, 1, 0 ];
VERTICAL   = [ 0, 0, 1 ];

// ----- Functions ----------------------------------------------------------------------------------------------------

function row_offset( cellz, space, r, c ) = (r <= 0) ? 0 : row_offset( cellz, space, r-1, c ) + cellz[r-1][c][1] + space;
function col_offset( cellz, space, r, c ) = (c <= 0) ? 0 : col_offset( cellz, space, r, c-1 ) + cellz[r][c-1][0] + space;

function row_length( cellz, space ) = col_offset( cellz, space, 0, len(cellz[0])) - space;
function col_length( cellz, space ) = row_offset( cellz, space, len(cellz), 0) - space;

function round_up( size, step ) = ceil( size / step ) * step;
function wall_sizes( borders ) = [ borders[ OUTER ]*4 + GAP*2, borders[ OUTER ]*4 + GAP*2, borders[ TOP ] + borders[ BOTTOM ] ];

function uniform_cells( rows, cols, tx, ty ) = [ for( r=[0:rows-1] ) [ for( c=[0:cols-1] ) [ tx, ty ] ] ];

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
    s = (r == 0) ? d/2 : r; // dit size
    
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
    
    if (DEBUG) {
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

    if (DEBUG) {
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

/** overlap_box -- Create an empty box with rounded corners lid that can contain the box
 * 
 * size    -- vector of sizes (X, Y, Z)
 * type    -- SOLID, HOLLOW, ROUNDED
 * borders -- vector of physical characteristics (see REASONABLE)
 */
 
module overlap_box( size, type=HOLLOW, borders=REASONABLE ) {
    outer  = borders[OUTER];
    bottom = borders[BOTTOM];
    fillet = borders[FILLET];
    
    midsize =    size + [ 2*outer, 2*outer, 0 ];
    gapsize = midsize + [ 2*GAP, 2*GAP, 0 ];
    outsize = gapsize + [ 2*outer, 2*outer, 0 ];
    
    if (DEBUG) {
        echo ( OverlapBox_InSize=size, MidSize=midsize, GapSize=gapsize, OutSize=outsize );
    }
    
    difference() {
        // Inner wall (full height)
        minkowski() {
            cube( size );
            scale( [outer, outer, bottom] ) hemisphere( r=1 );
        }

        // Remove inside, if necessary
        if (type == ROUNDED) {
            translate( [fillet, fillet, fillet] ) minkowski() {
                cube( size - [2*fillet, 2*fillet, 0] );
                hemisphere( fillet );
            }
        } else if (type == HOLLOW) {
            cube( size + [0, 0, 2*OVERLAP] );
        }
    }
}

/** overlap_lid -- Create a lid that can contain its box
 * 
 * size    -- vector of sizes (X, Y, Z)
 * borders -- vector of physical characteristics (see REASONABLE)
 */
 
module overlap_lid( size, borders=REASONABLE ) {
    outer = borders[OUTER];
    top   = borders[TOP];
    
    midsize =    size + [ 2*outer, 2*outer, 0 ];
    gapsize = midsize + [ 2*GAP, 2*GAP, 0 ];
    outsize = gapsize + [ 2*outer, 2*outer, 0 ];

    nz = (size.z > NOTCH*1.5) ? size.z : (size.z < NOTCH/2 ? NOTCH : NOTCH/2 + size.z);

    
    if (DEBUG) {
        echo ( OverlapBox_InSize=size, MidSize=midsize, GapSize=gapsize, OutSize=outsize, NotchZ=nz );
    }
    
    difference() {
        // Inner wall (full height)
        translate( [0, 0, 0] ) minkowski() {
            cube( gapsize );
            scale( [outer, outer, top] ) hemisphere( r=1 );
        }

        // Remove inside
        cube( gapsize + [0, 0, 2*OVERLAP] );
        
        // Remove notch
        translate( [(gapsize.x-outsize.x)/2-OVERLAP, gapsize.y/2, nz] ) 
            rotate( [0,90,0] ) cylinder( r=NOTCH, h=outsize.x+2*OVERLAP );
    }
}

/** cell_box -- Create a box with rows and columns of cells for storing small parts
 *
 * cells   -- Layout of cells (inside dimensions)
 * height  -- Height (Z) of cells (inside dimensions)
 * type    -- SOLID, HOLLOW, ROUNDED, NOTCHED
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

    if (DEBUG) {
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

                if (type == HOLLOW || type == NOTCHED) {
                    translate( [ dx, dy, 0 ] )
                    cube( [ cell.x, cell.y, height+OVERLAP ] );
                } else if (type == ROUNDED) {
                    translate( [ dx, dy, fillet+OVERLAP ] ) minkowski() {
                        translate( [fillet, fillet, 0] ) cube( [ cell.x-2*fillet, cell.y-2*fillet, height+OVERLAP ] );
                        hemisphere( r=fillet );
                    }
                }
                
                if (type == NOTCHED) {
                    if (cell.x > cell.y) {
                        translate([dx-inner/2-OVERLAP,dy+cell.y/2,height]) 
                            scale([cell.x+inner+2*OVERLAP,cell.y/2,2*height]) 
                                rotate([0,+90,0]) cylinder( d=1, h=1 );
                    } else {
                        translate([dx+cell.x/2,dy-inner/2-OVERLAP,height]) 
                            scale([cell.x/2,cell.y+inner+2*OVERLAP,2*height]) 
                                rotate([-90,0,0]) cylinder( d=1, h=1 );
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
module cell_lid( cells, height, type=HOLLOW, stubs=false, holes=false, borders=REASONABLE ) {
    inner  = borders[INNER];
    top    = borders[TOP];
    fillet = borders[FILLET];
    stub   = borders[STUBS];
    
    inside = [
        row_length( cells, inner ),
        col_length( cells, inner ),
        height
    ];

    if (DEBUG) {
        echo( CellLid_Inside=inside );
    }

    mirror( [ 1,0,0 ] ) difference() { 
        union() {
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

        if (holes) {
            for ( row = [len(cells)-1:-1:0] ) {
                for ( col = [0:1:len(cells[row])-1 ] ) {
                    cell = cells[row][col];
                    delta = [ col_offset( cells, inner, row, col ), row_offset( cells, inner, row, 0 ), 0 ];

                    translate( [delta.x+cell.x/2, delta.y+cell.y/2, -top-OVERLAP] ) 
                        scale( [cell.x/2, cell.y/2, 1] ) 
                            cylinder( d=1, h=top+4*OVERLAP );
                }
            }
        }
    }
}

/** deck_box -- create a sleeve to hold cards
 *
 * sizes    -- Vector ( short size of card, long size of card, thickness of card )
 * quantity -- number of cards
 * wall     -- thickness of box wall
 */
module deck_box( sizes, quantity, wall=WALL_WIDTH[1] ) {

    bottom = layers( 3 );

    inside = [
        sizes[0] + DECK_BOX_SPACING,
        sizes[2] * quantity + DECK_BOX_SPACING,
        layer_height( sizes[1] + DECK_BOX_SPACING )
    ];
    
    box = inside + [ 2 * wall, 2 * wall, bottom - layer_height( sizes[1]*0.25 ) ];

    if (DEBUG) {
        echo( ThinDeckBox=sizes, Quantity=quantity, Thickness=wall, Inside=inside, Box=box );
    }

    translate( [-wall, -wall, -bottom ] ) difference() {
        cube( box );
        translate( [ wall, wall, bottom ] ) 
            cube( inside );
    }
}

module thumb_box( sizes, quantity, wall=WALL_WIDTH[1] ) {

    bottom = layers( 3 );

    inside = [
        sizes[0] + DECK_BOX_SPACING,
        sizes[2] * quantity + DECK_BOX_SPACING,
        layer_height( sizes[1] + DECK_BOX_SPACING )
    ];
    
    box = inside + [ 2 * wall, 2 * wall, bottom - DECK_BOX_SPACING ];

    if (DEBUG) {
        echo( ThinDeckBox=sizes, Quantity=quantity, Thickness=wall, Inside=inside, Box=box );
    }

    translate( [-wall, -wall, -bottom ] ) difference() {
        // Outside of box
        cube( box );
        
        // Inside of box
        translate( [ wall, wall, bottom ] ) cube( inside );
        
        // Thumb holes
        translate( [box.x/2,box.y+OVERLAP,box.z+NOTCH/4] ) rotate( [90,0,0] ) cylinder( r=NOTCH, h=box.y + 2*OVERLAP );
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

//    translate( [ 5, 5, 0] ) cell_box( cell_test, 20, HOLLOW, true );
//    translate( [-5, 5, 0] ) cell_lid( cell_test, 20, HOLLOW, true, true );
    
    o = REASONABLE[ OUTER ] + GAP;
    
    translate( [    5,   5, 0] ) overlap_box( [40, 20, 10] );
    translate( [ -5+o, 5-o, 0] ) mirror( [1,0,0] ) overlap_lid( [40, 20, 10] );
}
/*
*/

if (0) {
    thumb_box( [ 2.03*inch, 3.5*inch, 0.5 ], 25 );
}