// 1846: The Race for the Midwest
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";           // Which part to output
VERBOSE = 1;        // Set to non-zero to see more data

// Box dimensions
BOX_HEIGHT      = 11.5 * inch;
BOX_WIDTH       =  8.5 * inch;
BOX_DEPTH       =  3.0 * inch;

// Inner well dimensions
WELL_DEPTH      = 1.25 * inch;
WELL_HEIGHT     = 5.50 * inch;
WELL_WIDTH      = BOX_WIDTH;

// Card dimensions
CARD_WIDTH      = 2.50 * inch;
CARD_HEIGHT     = 1.75 * inch;

COMPANY_CARDS   =  3.4 * mm;
TRAIN_CARDS     = 10.6 * mm; // (9) Yel, (6) Grn, (5) Brn, (9) Svr
OTHER_CARDS     =  5.9 * mm; // (10 + 5 + 1)

// Marker dimensions
MARK_DIAMETER   = 9/16 * inch;
MARK_THICKNESS  =  3.0 * mm;
MARK_MAX        = 10;

// Tile dimensions
TILE_DIAMETER   = 50.0 * mm;
TILE_THICKNESS  =  3.0 * mm;

BOARD_THICKNESS = 3.0 * mm;

// Physical dimensions
THIN_WALL = 0.86 * mm;  // Based on 0.20mm layer height
WIDE_WALL = 1.67 * mm;  // Based on 0.20mm layer height

BOTTOM = 1 * mm;
LIP    = 5 * mm;
SPACING =  1.0 * mm; // Room for tiles to shift
POKE_HOLE = 30 * mm; // Diameter of poke holes in bottom
GAP  = 0.25 * mm;     // Size differential between box and lid, for snug fit

OVERLAP = 0.01 * mm; // Ensures that there are no vertical artifacts leftover

$fa=4; $fn=45;

// Calculated dimensions

FULL_X = BOX_WIDTH;
FULL_Y = BOX_HEIGHT;
HALF_X = BOX_WIDTH / 2;
HALF_Y = BOX_HEIGHT / 2;

HEX_DIAMETER = TILE_DIAMETER + 2*WIDE_WALL; //  + SPACING;
HEX_EDGE  = HEX_DIAMETER / 2;
HEX_RADIUS = HEX_DIAMETER / 2;
HEX_WIDTH = HEX_DIAMETER * sin(60);

BORDER_X = (FULL_X - 4.5 * HEX_WIDTH) / 2;
BORDER_Y = (HALF_Y - 2.5 * HEX_DIAMETER) / 2;
GAP_X = (BORDER_X - WIDE_WALL) / 2;
GAP_Y = (BORDER_Y - WIDE_WALL) / 2;

if (VERBOSE) {
    echo( TrayLength=FULL_X, TrayWidth=HALF_Y );
    echo( HexDiameter=HEX_DIAMETER, HexEdge=HEX_EDGE, HexRadius=HEX_RADIUS, HexWidth=HEX_WIDTH );
    echo( BorderX=BORDER_X, GapX=GAP_X, BorderY=BORDER_Y, GapY=GAP_Y );
}

// Offsets for positioning hex tiles

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

function post_height( count ) = count * TILE_THICKNESS;

// ----- Modules ---------------------------------------------------------------

module hex_corner( corner, count=5 ) {
    offset = corner * -60;
    for ( angle=[210,330] ) {
        rotate( [0, 0, angle+offset] ) 
        translate( [ 0, -WIDE_WALL/2, 0 ] )
        cube( [4*WIDE_WALL, WIDE_WALL, post_height( count ) ] );
    }
    cylinder( d=WIDE_WALL, h=post_height( count ) );
}

module hex_tray( count=5 ) {
    bx = FULL_X;
    by = HALF_Y;
    bz = post_height( count );
    
    dx = WIDE_WALL;
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
                            translate( [tx, ty, 0 ] ) hex_corner( corner, count );
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
                    cylinder( h=BOTTOM+bz+OVERLAP, d=40, $fn=6 );
        }
    }
}

module hex_lid() {
    bx = FULL_X;
    by = HALF_Y;
    bz = 6 * mm;
    
    dx = WIDE_WALL;
    dy = dx;
    
    cx = THIN_WALL;
    cy = cx;
    
    ix = bx-2*dx;
    iy = by-2*dy;
        
    difference() {
        union() {
            cube( [bx, by, BOTTOM] );
            translate( [dx, dy, BOTTOM-OVERLAP] ) cube( [ix, iy, bz+OVERLAP] );
        }

        // Remove inside of lip
        translate( [dx+THIN_WALL, dy+THIN_WALL, BOTTOM] ) cube( [ix-2*THIN_WALL, iy-2*THIN_WALL, bz+OVERLAP] ); 

        // Remove corners
        translate( [cx,cy,BOTTOM] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
        translate( [ix-cx,cy,BOTTOM] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
        translate( [cx,iy-cy,BOTTOM] ) cube( [2*dx, 2*dy, bz+OVERLAP] );
        translate( [ix-cx,iy-cy,BOTTOM] ) cube( [2*dx, 2*dy, bz+OVERLAP] );

        // Remove finger holes
        for (tile=TILE_CENTERS) {
            tx = tile[0] + BORDER_X;
            ty = tile[1] + BORDER_Y;
            translate( [tx, ty, -OVERLAP] ) 
                rotate( [0,0,90] ) 
                    cylinder( h=BOTTOM+bz+2*OVERLAP, d=40, $fn=6 );
        }
    }
}

module big_card_tray() {
    bx = WELL_WIDTH;
    by = WELL_HEIGHT;
    bz = ceil( max( TRAIN_CARDS, OTHER_CARDS ) ) + MARK_THICKNESS + BOTTOM;

    ix = bx - 2 * WIDE_WALL;
    iy = by - 2 * WIDE_WALL;
    iz = bz - BOTTOM;
    
    cx = (ix - 2 * THIN_WALL) / 3;
    cy = (iy - 2 * THIN_WALL) / 3;
    
    dx = cx + THIN_WALL;
    dy = cy + THIN_WALL;
    
    if (VERBOSE) {
        echo( CardX=CARD_WIDTH, HoleX=cx, CardY=CARD_HEIGHT, HoleY=cy, CardZ=iz, Mark=MARK_DIAMETER );
    }
    
    difference() {
        // Box
        cube( [bx, by, bz] );

        // Remove card slots
        for (x=[0:2] ) {
            for (y=[0:2] ) {
                translate( [x*dx+WIDE_WALL, y*dy+WIDE_WALL, BOTTOM] ) cube( [cx, cy, iz+OVERLAP] );
            }
        }
    }
}

module card_tray() {
    x1 = ceil( MARK_DIAMETER+SPACING );
    x2 = ceil( CARD_WIDTH + 2*SPACING );

    bx = WIDE_WALL + x1 + THIN_WALL + x2 + WIDE_WALL;
    by = floor( WELL_WIDTH / 4);
    bz = ceil( max( COMPANY_CARDS, OTHER_CARDS, MARK_DIAMETER ) ); // + BOTTOM; // 

    dy = by - 2*WIDE_WALL;
    mz = x1 / 2;

    ho = 10 * mm;
    hx = x2 - 2*ho;
    hy = dy - 2*ho;

    lip = 6 * mm; // 7 * mm; // 
    
    if (VERBOSE) {
        echo( CardBoxX=bx, MinCardBoxY=CARD_HEIGHT+2*WIDE_WALL, ActCardBoxY=by, CardBoxZ=bz );
        echo( WellDepth=WELL_DEPTH, x1=x1, x2=x2, dy=dy, mz=mz );
        echo( hx=hx, hy=hy, diagonal=sqrt( hx*hx + hy*hy), CardWidth=CARD_WIDTH );
    }
    
    
    difference() {
        // Box
        cube( [bx, by, bz] );
        
        // Markers
        translate( [ WIDE_WALL+mz, 2*WIDE_WALL, BOTTOM+mz] ) rotate( [-90,0,0] ) cylinder( r=mz, h=dy-2*WIDE_WALL, center=false );
        translate( [ WIDE_WALL, WIDE_WALL, BOTTOM+mz-OVERLAP] ) cube( [x1, dy, bz] );
        
        // Cards
        translate( [ WIDE_WALL+x1+THIN_WALL, WIDE_WALL, BOTTOM] ) cube( [x2, dy, bz] );
        
        // Lip
        translate( [ WIDE_WALL, WIDE_WALL, bz-lip] ) cube( [x1+THIN_WALL+x2, WIDE_WALL, lip+OVERLAP] );
        translate( [ WIDE_WALL, by-2*WIDE_WALL, bz-lip] ) cube( [x1+THIN_WALL+x2, WIDE_WALL, lip+OVERLAP] );
        
        // Finger Hole
        translate( [ WIDE_WALL + x1 + THIN_WALL + ho, WIDE_WALL + ho, -OVERLAP] ) cube( [ hx, hy, bz+2*OVERLAP ] );
    }
}

module card_tray_lid() {    
    x1 = ceil( MARK_DIAMETER+SPACING );
    x2 = ceil( CARD_WIDTH + 2*SPACING );
    
    bx = WIDE_WALL + x1 + THIN_WALL + x2 + WIDE_WALL;
    by = floor( WELL_WIDTH / 4); // AKA CARD_HEIGHT plus something
    bz = ceil( max( COMPANY_CARDS, OTHER_CARDS, MARK_DIAMETER ) ) + BOTTOM;

    dx = bx - 2*WIDE_WALL;
    dy = by - 2*WIDE_WALL;

    ho = 10 * mm;
    hx = dx - 2*ho;
    hy = dy - 2*ho;
    
    difference() {
        union() {
            cube( [bx, by, BOTTOM] );
            translate( [ 2*WIDE_WALL, WIDE_WALL+GAP, BOTTOM-OVERLAP] ) cube( [dx-2*WIDE_WALL, THIN_WALL, LIP+OVERLAP] );
            translate( [ 2*WIDE_WALL, by-WIDE_WALL-THIN_WALL-GAP, BOTTOM-OVERLAP] ) cube( [dx-2*WIDE_WALL, THIN_WALL, LIP+OVERLAP] );
        }
        
    translate( [ WIDE_WALL + ho, WIDE_WALL + ho, -OVERLAP] ) cube( [ hx, hy, bz+2*OVERLAP ] );
    }
}

// ----- Rendering -------------------------------------------------------------

if (PART == "short-tile-tray") {
    hex_tray( 2 );
} else if (PART == "tall-tile-tray") {
    hex_tray( 5 );
} else if (PART == "tile-tray-lid") {
    hex_lid();
} else if (PART == "card-tray") {
    card_tray();
} else if (PART == "card-tray-lid") {
    card_tray_lid();
} else if (PART == "card-tray-plate") {
    translate( [ 0, 88, 0] ) rotate( [0, 0, -90] ) card_tray();
    translate( [58, 88, 0] ) rotate( [0, 0, -90] ) card_tray_lid();
} else {
    translate( [ 0, 88, 0] ) rotate( [0, 0, -90] ) card_tray();
    translate( [58, 88, 0] ) rotate( [0, 0, -90] ) card_tray_lid();
}
