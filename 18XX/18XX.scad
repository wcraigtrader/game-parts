// 18XX Tray Library
// by W. Craig Trader
//
// ----------------------------------------------------------------------------
// 
// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ 
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
// ----------------------------------------------------------------------------

// if (0) {
    VERBOSE = true;
    BOX_WIDTH = 305; BOX_DEPTH = 230; BOX_HEIGHT = 80;
    TILE_DIAMETER = 46; POKE_HOLE = TILE_DIAMETER - 15;
// }

include <../util/units.scad>;
include <../util/boxes.scad>;
include <18XX-data.scad>;

// ----- Physical dimensions ---------------------------------------------------

STUB      = 2.00 * mm;  // Height of lid stubs
STUB_GAP  = 0.15 * mm;  // Separation between lid stubs and tray hex corners

FONT_NAME   = "helvetica:style=Bold";
FONT_SIZE   = 6.0;
FONT_HEIGHT = 0.6 * mm;

$fa=4; $fn=30;

// ----- Calculated dimensions -------------------------------------------------

C30 = cos(30); C60 = cos(60);
S30 = sin(30); S60 = sin(60);
T30 = tan(30); T60 = tan(60);

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

// ----- Functions -------------------------------------------------------------

function hex_rows( centerz ) = len( centerz );
function hex_cols( centerz ) = max( len( centerz[0] ), len( centerz[1] ) );
function uneven_rows( centerz ) = (len( centerz[0] ) != len( centerz[1] )) ? 0 : 0.5;
function short_row( centerz ) = len( centerz[0] ) > len( centerz[1] ) ? 1 : 0;

function border_size_x( centerz, x ) = (x - (hex_cols( centerz ) + uneven_rows( centerz ) ) * HEX_WIDTH) / 2;
function border_size_y( centerz, y ) = (y - (hex_rows( centerz ) * 3+1) / 4 * HEX_DIAMETER) / 2;

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
    size = (TILE_DIAMETER < 30) ? THIN_WALL : WIDE_WALL;
    offset = corner * -60;
    for ( angle=[210,330] ) {
        rotate( [0, 0, angle+offset] )
        translate( [ 0, -size/2-gap/2, 0 ] )
        cube( [4*size, size+gap, height ] );
    }
    cylinder( d=size+2*gap, h=height );
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
module hex_tray( tile_centers, size, labels=[], borders=REASONABLE ) {
    bottom = borders[BOTTOM];

    inside = [ size.x-4*borders[OUTER]-2*GAP, size.y-4*borders[OUTER]-2*GAP, size.z ];

    border_x = border_size_x( tile_centers, inside.x );
    border_y = border_size_y( tile_centers, inside.y );

    if (VERBOSE) {
        echo( "hex_tray: ", size=size );
    }

    difference() {
        union() {
            // Add bottom plate
            rounded_box( inside, HOLLOW );

            // Add tile corners
            translate( [0, 0, BOTTOM-OVERLAP] ) difference() {
                union() { // add corners
                    for (row=tile_centers) {
                        for (tile=row) {
                            for (corner=[0:5]) {
                                tx = tile[0]*TDX + TILE_CORNERS[corner][0]*TDX + border_x;
                                ty = tile[1]*TDY + TILE_CORNERS[corner][1]*TDY + border_y;
                                translate( [tx, ty, 0 ] ) hex_corner( corner, size.z );
                            }
                        }
                    }
                }
            }
            
            if (len(labels) > 0) {
                sr = short_row( tile_centers );

                for (l=[len(labels)-1:-1:0]) {
                    ly = tile_centers[sr+2*l][0][1]*TDY + border_y;
                    translate( [inside.x-border_x+1, ly, -OVERLAP] )
                        rotate( [0,0,-90] )
                            linear_extrude( height=FONT_HEIGHT+OVERLAP )
                                text( labels[l], font=FONT_NAME, size=FONT_SIZE, halign="center", valign="top" );
                }
            }
        }

        // Remove finger holes
        for (row=tile_centers) {
            for (tile=row) {
                tx = tile[0]*TDX + border_x;
                ty = tile[1]*TDY + border_y;
                translate( [tx, ty, -bottom-OVERLAP] )
                    rotate( [0,0,90] )
                        cylinder( h=bottom+size.z+OVERLAP, d=POKE_HOLE, $fn=6 );
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
module hex_lid( tile_centers, size, remove_corners=true, add_stubs=false, remove_holes=true, borders=REASONABLE ) {
    bx = size.x; // width;
    by = size.y; // depth;
    bz = size.z; // height;

    top = borders[TOP];

    dx = borders[OUTER]; // walls;
    dy = borders[OUTER]; // dx;

    ix = size.x-2*dx;
    iy = size.y-2*dy;

    inside = [ size.x-4*borders[OUTER]-2*GAP, size.y-4*borders[OUTER]-2*GAP, size.z ];

    cx = borders[OUTER]; // inner;
    cy = borders[OUTER]; // cx;

    border_x = border_size_x( tile_centers, inside.x );
    border_y = border_size_y( tile_centers, inside.y );

    mirror( [0,1,0] ) union() {
        difference() {
            rounded_lid( inside );

            // Remove finger holes
            if (remove_holes) {
                for (row=tile_centers) {
                    for (tile=row) {
                        tx = tile[0]*TDX + border_x;
                        ty = tile[1]*TDY + border_y;
                        translate( [tx, ty, -top-OVERLAP] )
                            rotate( [0,0,90] )
                                cylinder( h=top+bz+2*OVERLAP, d=POKE_HOLE, $fn=6 );
                    }
                }
            }
        }
        
        if (add_stubs) {
            // Add tile corners
            translate( [0, 0, -OVERLAP] ) intersection() {
                cube( [inside.x, inside.y, inside.z+OVERLAP] );
                
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
                                    translate( [tx, ty, 0 ] ) hex_corner( corner, size.z, STUB_GAP );
                                }
                            }
                        }
                    }
                }
            }
        }
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

    cell_box( PART_CELLS, PART_HEIGHT );
    translate( [0, 70, 0] )
    cell_lid( PART_CELLS, PART_HEIGHT );
}

if (1) {
    translate( [5, 5, 0] ) hex_tray( TILE_CENTERS_2X2, [5*inch, 4*inch, 6*mm], ["18XX"] );
    translate( [5,-5, 0] ) hex_lid( TILE_CENTERS_2X2, [5*inch, 4*inch, 6*mm], false, true );
}