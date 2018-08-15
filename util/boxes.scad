// 18XX Tray Library
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// VERBOSE = true;

// ----- Physical dimensions ---------------------------------------------------

GAP       = 0.25 * mm;  // Gap between outer and inner walls for boxes
OVERLAP   = 0.01 * mm;  // Ensures that there are no vertical artifacts leftover
NOTCH     = 10.0 * mm;  // Radius of notches

DECK_BOX_SPACING =  1.00 * mm;
DECK_BOK_OVERLAP = 20.00 * mm;

SLICING_LAYER = 0.20 * mm;

$fa=4; $fn=90;

// ----- Card Sleeves ----------------------------------------------------------

/*
 * [0] = (X) width of sleeved card (mm)
 * [1] = (Z) height of sleeved card (mm)
 * [2] = (Y) average thickness of sleeved card (mm)
 */

FFS_STANDARD = [ 66.70, 94.60, 0.625 ];

// ----- Calculated dimensions -------------------------------------------------


// ----- Offsets for positioning hex tiles -------------------------------------


// ----- Functions -------------------------------------------------------------

function row_offset( cellz, space, r, c ) = (r <= 0) ? 0 :
    row_offset( cellz, space, r-1, c ) + cellz[r-1][c][1] + space;
function col_offset( cellz, space, r, c ) = (c <= 0) ? 0 :
    col_offset( cellz, space, r, c-1 ) + cellz[r][c-1][0] + space;

function row_length( cellz, space ) = col_offset( cellz, space, 0, len(cellz[0])) - space;
function col_length( cellz, space ) = row_offset( cellz, space, len(cellz), 0) - space;

function round_up( size, step ) = ceil( size / step ) * step;

// ----- Modules ---------------------------------------------------------------

/** rounded_box -- Create an empty box with rounded corners and a lip for a lid
 *
 * width  -- Width (X) of inside space
 * depth  -- Depth (Y) of inside space
 * height -- Height (Z) of inside space
 * bottom -- Thickness (mm) of base
 * top    -- Thickness (mm) of lid
 * outer  -- Size (mm) of outer walls
 * inner  -- Size (mm) of inner walls
 */
module rounded_box( width, depth, height, bottom, top, outer, inner ) {
    box_x = width + 2 * inner + 2 * GAP;
    box_y = depth + 2 * inner + 2 * GAP;
    box_z = height - floor( height / 2 );

    lip_x = box_x - 2 * GAP;
    lip_y = box_y - 2 * GAP;
    lip_z = height;

    out_x = box_x + 2 * outer;
    out_y = box_y + 2 * outer;
    out_z = lip_z + bottom;

    if (VERBOSE) {
        echo( RoundedBox=[ out_x, out_y, out_z ] );
    }

	translate( [ -inner-GAP, -inner-GAP, -bottom ] ) difference() {
        union() {
            minkowski() {
                cube( [ box_x, box_y, box_z ] );
                cylinder( r=outer, h=OVERLAP );
            }
            translate( [ GAP, GAP, bottom-OVERLAP ] )
                cube( [ lip_x, lip_y, lip_z+OVERLAP ] );

        }

        translate( [GAP+inner, GAP+inner, bottom] )
            cube( [ width, depth, height+OVERLAP ] );
    }
}

/** rounded_lid -- Create a lid for a box with rounded corners
 *
 * width  -- Width (X) of inside space
 * depth  -- Depth (Y) of inside space
 * height -- Height (Z) of inside space
 * bottom -- Thickness (mm) of base
 * top    -- Thickness (mm) of lid
 * outer  -- Size (mm) of outer walls
 * inner  -- Size (mm) of inner walls
 */
module rounded_lid( width, depth, height, bottom, top, outer, inner ) {
    box_x = width + 2 * inner + 2 * GAP;
    box_y = depth + 2 * inner + 2 * GAP;
    box_z = height - floor( height / 2 );

    lip_x = box_x - 2 * GAP;
    lip_y = box_y - 2 * GAP;
    lip_z = ceil( height / 2 );
    lip_r = NOTCH;

    if (VERBOSE) {
        echo( RoundedLid=[ box_x, box_y, box_z+top ] );
    }

    translate( [ -inner-GAP, -inner-GAP, -bottom ] ) difference() {
        // Outside of lid
        minkowski() {
            cube( [ box_x, box_y, lip_z ] );
            cylinder( r=outer, h=OVERLAP );
        }

        // Remove inside of lid
        translate( [ 0, 0, top ] )
            cube( [ box_x, box_y, lip_z+OVERLAP ] );

        // Remove notches to make it easier to remove the lid
        translate( [-2*outer, lip_y/2+outer/2, lip_r-0+lip_z-2*outer] )
            rotate( [0,90,0] )
                cylinder( r=lip_r, h=lip_x+4*outer );
    }
}

/** cell_box -- Create a box with rows and columns of cells for storing small parts
 *
 * cells  -- Layout of cells (inside dimensions)
 * height -- Height (Z) of cells (inside dimensions)
 * bottom -- Thickness (mm) of base
 * top    -- Thickness (mm) of lid
 * outer  -- Size (mm) of outer walls
 * inner  -- Size (mm) of inner walls
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
 * 2 cells in the second row, and 1 long cell in the third row. If you're
 * rows that have differing numbers of cells, you'll want to increase the size
 * of some cells to account for the walls that will be missing from in that row.
 */
module cell_box( cells, height, bottom, top, outer, inner ) {
    inside_x = row_length( cells, inner );
    inside_y = col_length( cells, inner );
    inside_z = height;

    if (VERBOSE) {
        echo( InsideCellBox=[ inside_x, inside_y, inside_z ] );
    }

    // Create box frame
// color( "teal" )
    rounded_box( inside_x, inside_y, inside_z, bottom, top, outer, inner );

    // Fill box
    translate( [ -OVERLAP, -OVERLAP, -OVERLAP ] ) difference() {
// color( "plum" )
        cube( [ inside_x+2*OVERLAP, inside_y+2*OVERLAP, inside_z+1*OVERLAP ] );

        // Remove inside of box
        for ( row = [len(cells)-1:-1:0] ) {
            for ( col = [0:1:len(cells[row])-1 ] ) {
                cell = cells[row][col];
                dx = col_offset( cells, inner, row, col ) + OVERLAP;
                dy = row_offset( cells, inner, row, col ) + OVERLAP;

// color( "navy" )
                    translate( [ dx, dy, OVERLAP ] )
                    cube( [ cell[0], cell[1], height+3*OVERLAP ] );
            }
        }
    }
}

/** cell_lid -- use a
 */
module cell_lid( cells, height, bottom, top, outer, inner ) {
    inside_x = row_length( cells, inner );
    inside_y = col_length( cells, inner );
    inside_z = height;

    if (VERBOSE) {
        echo( InsideCellLid=[ inside_x, inside_y, inside_z ] );
    }

    rounded_lid( inside_x, inside_y, inside_z, bottom, top, outer, inner );
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
    box_z = round_up( inside_z/2, SLICING_LAYER );
    
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
    box_z = round_up( inside_z/2, SLICING_LAYER );
    
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

TESTING=0;
// VERBOSE=1;

if (TESTING) {
    echo( Testing=TESTING );
}

if (TESTING == 1) {
    BOTTOM    = 1.00 * mm;  // Bottom plate thickness
    TOP       = 1.00 * mm;  // Top plate thickness
    THIN_WALL = 0.86 * mm;  // Based on 0.20mm layer height
    WIDE_WALL = 1.67 * mm;  // Based on 0.20mm layer height
    
    rounded_box( 40, 30, 20, 1, 1, WIDE_WALL, THIN_WALL );
    translate( [0,40,0] )
    rounded_lid( 40, 30, 20, 1, 1, WIDE_WALL, THIN_WALL );
    
} else if (TESTING == 2) {
    BOTTOM    = 1.00 * mm;  // Bottom plate thickness
    TOP       = 1.00 * mm;  // Top plate thickness
    THIN_WALL = 0.86 * mm;  // Based on 0.20mm layer height
    WIDE_WALL = 1.67 * mm;  // Based on 0.20mm layer height
    
    // Part box dimensions
    PART_WIDTH      = 35.0; // 1.25 * inch;  // X
    PART_DEPTH      = 17.5; // 0.75 * inch;  // Y
    PART_HEIGHT     = 6.00 * mm;    // Z

    px = PART_WIDTH; py = PART_DEPTH;

    PART_CELLS = [
        [ [ px, py ], [ px, py ], [ px, py ] ],
        [ [ px, py ], [ px, py ], [ px, py ] ],
        [ [ px, py ], [ px, py ], [ px, py ] ]
    ];

    TEST_CELLS = [
        [ [ 20, 20 ], [ 30, 20 ], [ 40, 20 ] ],
        [ [ 20, 15 ], [ 30, 15 ], [ 40, 15 ] ],
        [ [ 20, 10 ], [ 30, 10 ], [ 40, 10 ] ]
    ];

   cell_box( PART_CELLS, PART_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
    translate( [0, 70, 0] )
    cell_lid( PART_CELLS, PART_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
    
} else if (TESTING == 3 ) {
    THIN_WALL = 0.86 * mm;  // Based on 0.20mm layer height
    
    deck_box( FFS_STANDARD, 70, THIN_WALL );
    
%   translate( [ DECK_BOX_SPACING/2, DECK_BOX_SPACING/2, DECK_BOX_SPACING/2 ] )
    cube( [ FFS_STANDARD[0], 70*FFS_STANDARD[2], FFS_STANDARD[1] ] );
    
    
    translate( [ 0, 55, 0 ] )
    deck_lid( FFS_STANDARD, 70, THIN_WALL );
    
} else if (TESTING == 4) {
    THIN_WALL = 0.86 * mm;  // Based on 0.20mm layer height
    
    thin_deck_box( FFS_STANDARD, 70, THIN_WALL );
}
