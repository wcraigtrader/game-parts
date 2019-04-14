// 18XX Tray Library
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// ----- Physical dimensions ---------------------------------------------------

THIN_WALL = 0.86 * mm;  	// Based on 0.20mm layer height
WIDE_WALL = 1.67 * mm;  	// Based on 0.20mm layer height
GAP       = 0.10 * mm;      // Gap between outer and inner walls for boxes

BOTTOM    = 1.00 * mm;  // Bottom plate thickness
TOP       = 1.00 * mm;  // Top plate thickness
OVERLAP   = 0.01 * mm;  // Ensures that there are no vertical artifacts leftover
THUMBS    = 10.0 * mm;  // Thumb notch for box lids
STUB      = 2.00 * mm;  // Height of lid stubs
STUB_GAP  = 0.15 * mm;  // Separation between lid stubs and tray hex corners

FONT_NAME   = "helvetica:style=Bold";
FONT_SIZE   = 7.0;
FONT_HEIGHT = 0.6 * mm;

$fa=4; $fn=90;

// ----- Calculated dimensions -------------------------------------------------

C60 = cos(60);
S60 = sin(60);

FULL_X = BOX_WIDTH;
FULL_Y = BOX_HEIGHT;
HALF_X = BOX_WIDTH / 2;
HALF_Y = BOX_HEIGHT / 2;

HEX_DIAMETER = TILE_DIAMETER + 2*WIDE_WALL;
HEX_EDGE   = HEX_DIAMETER / 2;
HEX_RADIUS = HEX_DIAMETER / 2;
HEX_WIDTH = HEX_DIAMETER * S60;

if (VERBOSE) {
    echo( TrayLength=FULL_X, TrayWidth=HALF_Y );
    echo( HexDiameter=HEX_DIAMETER, HexEdge=HEX_EDGE, HexRadius=HEX_RADIUS, HexWidth=HEX_WIDTH );
}

// ----- Offsets for positioning hex tiles -------------------------------------

TDX = HEX_WIDTH / 4;
TDY = HEX_DIAMETER / 4;

TILE_CORNERS = [
    [ 0, 2 ], [ 2, 1 ], [ 2,-1 ],
    [ 0,-2 ], [-2,-1 ], [-2, 1 ],
];

TILE_CENTERS_3X4 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ] ],
];

TILE_CENTERS_3X5 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ], [18, 2] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ], [20, 5] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ], [18, 8] ],
];

TILE_CENTERS_4X4 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ] ],
    [ [ 4,11 ], [ 8,11 ], [ 12,11 ], [ 16,11 ] ],
];

TILE_CENTERS_4X5 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ], [18, 2] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ], [20, 5] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ], [18, 8] ],
    [ [ 4,11 ], [ 8,11 ], [ 12,11 ], [ 16,11 ], [20,11] ],
];

TILE_CENTERS_5X3 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ] ],
    [ [ 4,11 ], [ 8,11 ], [ 12,11 ] ],
    [ [ 2,14 ], [ 6,14 ], [ 10,14 ] ],
];

TILE_CENTERS_5X4 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ] ],
    [ [ 4,11 ], [ 8,11 ], [ 12,11 ], [ 16,11 ] ],
    [ [ 2,14 ], [ 6,14 ], [ 10,14 ], [ 14,14 ] ],
];

TILE_CENTERS_5X5 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ], [18, 2] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ], [20, 5] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ], [18, 8] ],
    [ [ 4,11 ], [ 8,11 ], [ 12,11 ], [ 16,11 ], [20,11] ],
    [ [ 2,14 ], [ 6,14 ], [ 10,14 ], [ 14,14 ], [18,14] ],
];

TILE_CENTERS_6X3 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ] ],
    [ [ 4,11 ], [ 8,11 ], [ 12,11 ] ],
    [ [ 2,14 ], [ 6,14 ], [ 10,14 ] ],
    [ [ 4,17 ], [ 8,17 ], [ 12,17 ] ],
];

TILE_CENTERS_6X4 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ] ],
    [ [ 4,11 ], [ 8,11 ], [ 12,11 ], [ 16,11 ] ],
    [ [ 2,14 ], [ 6,14 ], [ 10,14 ], [ 14,14 ] ],
    [ [ 4,17 ], [ 8,17 ], [ 12,17 ], [ 16,17 ] ],
];

TILE_CENTERS_6X5 = [
    [ [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ], [18, 2] ],
    [ [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ], [20, 5] ],
    [ [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ], [18, 8] ],
    [ [ 4,11 ], [ 8,11 ], [ 12,11 ], [ 16,11 ], [20,11] ],
    [ [ 2,14 ], [ 6,14 ], [ 10,14 ], [ 14,14 ], [18,14] ],
    [ [ 4,17 ], [ 8,17 ], [ 12,17 ], [ 16,17 ], [20,17] ],
];

// ----- Functions -------------------------------------------------------------

function hex_rows( centerz ) = len( centerz );
function hex_cols( centerz ) = len( centerz[0] );

function border_size_x( centerz, x ) = (x - (hex_cols( centerz ) + 0.5) * HEX_WIDTH) / 2;
function border_size_y( centerz, y ) = (y - (hex_rows( centerz ) * 3+1) / 4 * HEX_DIAMETER) / 2;

function row_offset( cellz, space, r, c ) = r <= 0 ? 0 : row_offset( cellz, space, r-1, c ) + cellz[r-1][c][1] + space;
function col_offset( cellz, space, r, c ) = c <= 0 ? 0 : col_offset( cellz, space, r, c-1 ) + cellz[r][c-1][0] + space;

function row_length( cellz, space ) = col_offset( cellz, space, 0, len(cellz[0])) - space;
function col_length( cellz, space ) = row_offset( cellz, space, len(cellz), 0) - space;

// ----- Modules ---------------------------------------------------------------

/*
 * hex_corner( corner, height )
 *
 * This creates a short segment of the corner of a hexagonal wall
 *
 * corner -- 0-5, specifying which corner of the hexagon to create, clockwise
 * height -- Height of the wall segment in millimeters
 * gap    -- Fraction of a millimeter, to tweak the width of the corner
 */
module hex_corner( corner, height, gap=0 ) {
    offset = corner * -60;
    for ( angle=[210,330] ) {
        rotate( [0, 0, angle+offset] )
        translate( [ 0, -WIDE_WALL/2-gap/2, 0 ] )
        cube( [4*WIDE_WALL, WIDE_WALL+gap, height ] );
    }
    cylinder( d=WIDE_WALL+2*gap, h=height );
}

/*
 * hex_tray( width, depth, height, walls )
 *
 * Create a tray to hold hexagonal tiles
 *
 * width  -- Width (X) of the tray (outside dimensions)
 * depth  -- Depth (Y) of the tray (outside dimensions
 * height -- Height (Z) of the stack of tiles (inside dimensions)
 * walls  -- Thickness of outside walls
 */
module hex_tray( tile_centers, width, depth, height, walls, label="", version="" ) {
    bx = width;
    by = depth;
    bz = height;

    dx = walls;
    dy = dx;

    ix = bx-2*dx;
    iy = by-2*dy;

    border_x = border_size_x( tile_centers, width );
    border_y = border_size_y( tile_centers, depth );

    ly1 = tile_centers[0][0][1]*TDY + border_y;
    ly2 = tile_centers[2][0][1]*TDY + border_y;

    if (VERBOSE) {
        echo( "hex_tray: ", w=width, d=depth, h=height, w=walls );
    }

    difference() {
        union() {
            // Add bottom plate
            difference() {
                cube( [bx, by, BOTTOM+bz] );
                translate( [dx, dy, BOTTOM] ) cube( [ix, iy, bz+OVERLAP] );
            }

            // Add tile corners
            translate( [0, 0, BOTTOM-OVERLAP] ) difference() {
                union() { // add corners
                    for (row=tile_centers) {
                        for (tile=row) {
                            for (corner=[0:5]) {
                                tx = tile[0]*TDX + TILE_CORNERS[corner][0]*TDX + border_x;
                                ty = tile[1]*TDY + TILE_CORNERS[corner][1]*TDY + border_y;
                                translate( [tx, ty, 0 ] ) hex_corner( corner, height );
                            }
                        }
                    }
                }
            }
            
            // If a label was specified
            if (label != "") {
                translate( [bx-border_x+1, ly2, BOTTOM-OVERLAP] )
                    rotate( [0,0,-90] )
                        linear_extrude( height=FONT_HEIGHT+OVERLAP )
                            text( label, font=FONT_NAME, size=FONT_SIZE, halign="center", valign="top" );
            }
            
            // If a version was specified
            if (version != "") {
                translate( [bx-border_x+1, ly1, BOTTOM-OVERLAP] )
                    rotate( [0,0,-90] )
                        linear_extrude( height=FONT_HEIGHT+OVERLAP )
                            text( version, font=FONT_NAME, size=FONT_SIZE, halign="center", valign="top" );
            }
        }

        // Remove finger holes
        for (row=tile_centers) {
            for (tile=row) {
                tx = tile[0]*TDX + border_x;
                ty = tile[1]*TDY + border_y;
                translate( [tx, ty, -OVERLAP] )
                    rotate( [0,0,90] )
                        cylinder( h=BOTTOM+bz+OVERLAP, d=POKE_HOLE, $fn=6 );
            }
        }
    }
}

/*
 * hex_lid( width, depth, height, outer, inner, remove_corners, add_stubs )
 *
 * Create a lid for a hexagon tile tray
 *
 * width          -- Width (X) of the tray (outside dimensions)
 * depth          -- Depth (Y) of the tray (outside dimensions
 * height         -- Height (Z) of the stack of tiles (inside dimensions)
 * outer          -- Outer wall thickness
 * inner          -- Inner wall thickness
 * remove_corners -- True to remove the corners of the inner walls
 * add_stubs      -- True to add stubs that fit with the hex corners from the tray
 */
module hex_lid( tile_centers, width, depth, height, outer, inner, remove_corners=true, add_stubs=false, remove_holes=true, label="" ) {
    bx = width;
    by = depth;
    bz = height;

    dx = outer;
    dy = dx;

    cx = inner;
    cy = cx;

    ix = bx-2*dx;
    iy = by-2*dy;

    border_x = border_size_x( tile_centers, width );
    border_y = border_size_y( tile_centers, depth );

    mirror( [0,1,0] ) union() {
        difference() {
            union() {
                cube( [bx, by, TOP] );
                translate( [dx, dy, TOP-OVERLAP] ) cube( [ix, iy, bz+OVERLAP] );
            }

            // Remove inside of lip
            translate( [dx+inner, dy+inner, TOP] ) cube( [ix-2*inner, iy-2*inner, bz+OVERLAP] );

            // Remove corners
            if (remove_corners) {
                translate( [   cx,   cy,TOP] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
                translate( [ix-cx,   cy,TOP] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
                translate( [   cx,iy-cy,TOP] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
                translate( [ix-cx,iy-cy,TOP] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
            }

            // Remove finger holes
            if (remove_holes) {
                for (row=tile_centers) {
                    for (tile=row) {
                        tx = tile[0]*TDX + border_x;
                        ty = tile[1] *TDY+ border_y;
                        translate( [tx, ty, -OVERLAP] )
                            rotate( [0,0,90] )
                                cylinder( h=BOTTOM+bz+2*OVERLAP, d=POKE_HOLE, $fn=6 );
                    }
                }
            }
        }
        
        if (add_stubs) {
            // Add tile corners
            translate( [0, 0, TOP-OVERLAP] ) intersection() {
                translate( [dx+inner-OVERLAP, dy+inner-OVERLAP, 0] ) cube( [ix-2*inner+2*OVERLAP, iy-2*inner+2*OVERLAP, bz+OVERLAP] );
                
                difference() {
                    union() {
                        for (row=tile_centers) {
                            for (tile=row) {
                                for (corner=[0:5]) {
                                    tx = tile[0]*TDX + TILE_CORNERS[corner][0]*TDX + border_x;
                                    ty = tile[1]*TDY + TILE_CORNERS[corner][1]*TDY + border_y;
                                    translate( [tx, ty, 0] ) cylinder( d=7*WIDE_WALL, h=STUB+OVERLAP, $fn=6 );
                                }
                            }
                        }
                    }
                    
                    union() { // add corners
                        for (row=tile_centers) {
                            for (tile=row) {
                                for (corner=[0:5]) {
                                    tx = tile[0]*TDX + TILE_CORNERS[corner][0]*TDX + border_x;
                                    ty = tile[1]*TDY + TILE_CORNERS[corner][1]*TDY + border_y;
                                    translate( [tx, ty, 0 ] ) hex_corner( corner, height, STUB_GAP );
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/*
 * cell_box()
 *
 * Create a box with rows and columns of cells for storing small parts
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
module cell_box( cells, height, bottom, top, outer, inner, holes=false ) {
    inside_x = row_length( cells, inner );
    inside_y = col_length( cells, inner );
    inside_z = height;

    box_x = inside_x + 2 * inner + 2 * GAP;
    box_y = inside_y + 2 * inner + 2 * GAP;
    box_z = inside_z - floor( inside_z / 2 );

    lip_x = box_x - 2 * GAP;
    lip_y = box_y - 2 * GAP;
    lip_z = inside_z;

    if (VERBOSE) {
        echo (Inside=[inside_x, inside_y, inside_z], Box=[box_x, box_y, box_z] );
    }

    difference() {
        union() {
            minkowski() {
                cube( [ box_x, box_y, box_z ] );
                cylinder( r=outer, h=1 );
            }
            translate( [ GAP, GAP, bottom ] )
                cube( [ lip_x, lip_y, lip_z ] );

        }

        // Remove inside of box
        for ( row = [len(cells)-1:-1:0] ) {
            if (VERBOSE) {
                echo( CellRow=row, Cells=cells[row] );
            }
            for ( col = [0:1:len(cells[row])-1 ] ) {
                cell = cells[row][col];
                dx = col_offset( cells, inner, row, col ) + inner + GAP;
                dy = row_offset( cells, inner, row, col ) + inner + GAP;

                translate( [ dx, dy, bottom ] )
                    cube( [ cell[0], cell[1], height+top+OVERLAP ] );
                
                if (holes) {
                    translate( [ dx+cell[0]/4, dy+cell[1]/4, -OVERLAP ] )
                        cube( [ cell[0]/2, cell[1]/2, bottom+2*OVERLAP ] );
                }
            }
        }
    }
}

/*
 *
 */
module cell_lid( cells, height, bottom, top, outer, inner ) {
    inside_x = row_length( cells, inner );
    inside_y = col_length( cells, inner );
    inside_z = height;

    box_x = inside_x + 2 * inner + 2 * GAP;
    box_y = inside_y + 2 * inner + 2 * GAP;
    box_z = inside_z - ceil( inside_z / 2 );

    lip_x = box_x;
    lip_y = box_y;
    lip_z = ceil( inside_z / 2 );
    lip_r = 10 * mm;

    if (VERBOSE) {
        echo (Inside=[inside_x, inside_y, inside_z], Box=[box_x, box_y, box_z] );
    }

    difference() {
        // Outside of lid
        minkowski() {
            cube( [ box_x, box_y, lip_z ] );
            cylinder( r=outer, h=top );
        }

        // Remove inside of lid
        translate( [ 0, 0, top ] )
            cube( [ box_x, box_y, lip_z+OVERLAP ] );

        // Remove notches to make it easier to remove the lid
        translate( [-2*outer,lip_y/2+outer/2,lip_r-0+lip_z-2*outer] )
            rotate( [0,90,0] )
                cylinder( r=lip_r, h=lip_x+4*outer );
    }
}

// ----- Testing ---------------------------------------------------------------

if (0) {
    VERBOSE = true;

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

    cell_box( PART_CELLS, PART_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL, true );
    translate( [0, 70, 0] )
    cell_lid( PART_CELLS, PART_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
}

if (0) {
    VERBOSE = true;
    
    hex_tray( TILE_CENTERS_4X4, 8*inch, 8*inch, 6*mm, WIDE_WALL, "18XX", "V1" );
    translate( [0, 8.5*inch, 0] )
    hex_lid( TILE_CENTERS_4X4, 8*inch, 8*inch, 4*mm, WIDE_WALL, THIN_WALL, false, true );
}