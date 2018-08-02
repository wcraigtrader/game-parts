// 18XX Tray Library
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// ----- Physical dimensions ---------------------------------------------------

THIN_WALL = 0.86 * mm;  // Based on 0.20mm layer height
WIDE_WALL = 1.67 * mm;  // Based on 0.20mm layer height

BOTTOM    = 1.00 * mm;  // Bottom plate thickness
TOP       = 1.00 * mm;  // Top plate thickness
OVERLAP   = 0.01 * mm;  // Ensures that there are no vertical artifacts leftover

$fa=4; $fn=90;

// ----- Calculated dimensions -------------------------------------------------

C60 = cos(60);
S60 = sin(60);

FULL_X = BOX_WIDTH;
FULL_Y = BOX_HEIGHT;
HALF_X = BOX_WIDTH / 2;
HALF_Y = BOX_HEIGHT / 2;

HEX_DIAMETER = TILE_DIAMETER + 2*WIDE_WALL;
HEX_EDGE  = HEX_DIAMETER / 2;
HEX_RADIUS = HEX_DIAMETER / 2;
HEX_WIDTH = HEX_DIAMETER * S60;

BORDER_X = (FULL_X - 4.5 * HEX_WIDTH) / 2;
BORDER_Y = (HALF_Y - 2.5 * HEX_DIAMETER) / 2;
GAP_X = (BORDER_X - WIDE_WALL) / 2;
GAP_Y = (BORDER_Y - WIDE_WALL) / 2;

if (VERBOSE) {
    echo( TrayLength=FULL_X, TrayWidth=HALF_Y );
    echo( HexDiameter=HEX_DIAMETER, HexEdge=HEX_EDGE, HexRadius=HEX_RADIUS, HexWidth=HEX_WIDTH );
    echo( BorderX=BORDER_X, GapX=GAP_X, BorderY=BORDER_Y, GapY=GAP_Y );
}


// ----- Offsets for positioning hex tiles -------------------------------------

TDX = HEX_WIDTH / 4;
TDY = HEX_DIAMETER / 4;

TILE_CORNERS = [
    [ 0*TDX, 2*TDY ], [ 2*TDX, 1*TDY ], [ 2*TDX,-1*TDY ],
    [ 0*TDX,-2*TDY ], [-2*TDX,-1*TDY ], [-2*TDX, 1*TDY ],
];

TILE_CENTERS = [
    [ 2*TDX, 2*TDY ], [ 6*TDX, 2*TDY ], [ 10*TDX, 2*TDY ], [ 14*TDX, 2*TDY ],
    [ 4*TDX, 5*TDY ], [ 8*TDX, 5*TDY ], [ 12*TDX, 5*TDY ], [ 16*TDX, 5*TDY ],
    [ 2*TDX, 8*TDY ], [ 6*TDX, 8*TDY ], [ 10*TDX, 8*TDY ], [ 14*TDX, 8*TDY ],
];

// ----- Functions -------------------------------------------------------------

// ----- Modules ---------------------------------------------------------------

module hex_corner( corner, height ) {
    offset = corner * -60;
    for ( angle=[210,330] ) {
        rotate( [0, 0, angle+offset] )
        translate( [ 0, -WIDE_WALL/2, 0 ] )
        cube( [4*WIDE_WALL, WIDE_WALL, height ] );
    }
    cylinder( d=WIDE_WALL, h=height );
}

module fine_hex_tray( width, depth, height, thick ) {
    bx = width;
    by = depth;
    bz = height;

    dx = thick;
    dy = dx;

    ix = bx-2*dx;
    iy = by-2*dy;

    cx = 10 * mm;
    cy = cx;

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
                    for (tile=TILE_CENTERS) {
                        for (corner=[0:5]) {
                            tx = tile[0] + TILE_CORNERS[corner][0] + BORDER_X;
                            ty = tile[1] + TILE_CORNERS[corner][1] + BORDER_Y;
                            translate( [tx, ty, 0 ] ) hex_corner( corner, height );
                        }
                    }
                }
            }
        }

        // Remove finger holes
        for (tile=TILE_CENTERS) {
            tx = tile[0] + BORDER_X;
            ty = tile[1] + BORDER_Y;
            translate( [tx, ty, -OVERLAP] )
                rotate( [0,0,90] )
                    cylinder( h=BOTTOM+bz+OVERLAP, d=POKE_HOLE, $fn=6 );
        }
    }
}

module fine_hex_lid( width, depth, height, thick, thin, remove_corners=true ) {
    bx = width;
    by = depth;
    bz = height;

    dx = thick;
    dy = dx;

    cx = thin;
    cy = cx;

    ix = bx-2*dx;
    iy = by-2*dy;

    difference() {
        union() {
            cube( [bx, by, TOP] );
            translate( [dx, dy, TOP-OVERLAP] ) cube( [ix, iy, bz+OVERLAP] );
        }

        // Remove inside of lip
        translate( [dx+THIN_WALL, dy+THIN_WALL, BOTTOM] ) cube( [ix-2*THIN_WALL, iy-2*THIN_WALL, bz+OVERLAP] );

        // Remove corners
		if (remove_corners) {
            translate( [cx,cy,TOP] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
            translate( [ix-cx,cy,TOP] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
            translate( [cx,iy-cy,TOP] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
            translate( [ix-cx,iy-cy,TOP] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
		}

        // Remove finger holes
        for (tile=TILE_CENTERS) {
            tx = tile[0] + BORDER_X;
            ty = tile[1] + BORDER_Y;
            translate( [tx, ty, -OVERLAP] )
                rotate( [0,0,90] )
                    cylinder( h=BOTTOM+bz+2*OVERLAP, d=POKE_HOLE, $fn=6 );
        }
    }
}


