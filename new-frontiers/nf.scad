// New Frontiers
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.
//
// ----------------------------------------------------------------------------

include <MCAD/units.scad>;

// ----- Command Line Arguments -----------------------------------------------

PART = "other";     // Which part to output
VERBOSE = true;     // Set to true to see more data

// ----- Component measurements -----------------------------------------------

// Game box dimensions
BOX_HEIGHT = 10.0 * cm;             // (Z)
BOX_DEPTH  = 32.4 * cm;             // (Y)
BOX_WIDTH  = 32.4 * cm;             // (X)

COMPARTMENT_HEIGHT = 52.00 * mm;    // (Z)
COMPARTMENT_DEPTH  =  8.00 * inch;  // (Y)
COMPARTMENT_WIDTH  = BOX_WIDTH;     // (X)

// Tile dimensions
TILE_THICKNESS = 2.00 * mm; 
TILE_HEIGHT    = 46.5 * mm;
TILE_OFFSET    = 14.5 * mm;
SM_TILE_LENGTH =  5.5 * cm;
LG_TILE_LENGTH = 11.0 * cm;

// Meeples aka Colonists aka Blue Robots
MEEPLE_HEIGHT = 16.25 * mm;         // (Z)
MEEPLE_DEPTH  =  9.60 * mm;         // (Y)
MEEPLE_WIDTH  =  9.75 * mm;         // (X)

// ----- 3D Printer -----------------------------------------------------------

LAYER_HEIGHT = 0.20 * mm;
WALL_WIDTH = [ 0.00, 0.43, 0.86, 1.26, 1.67, 2.08, 2.49, 2.89, 3.30 ];

THIN_WALL  = WALL_WIDTH[2];
WIDE_WALL  = WALL_WIDTH[4];

function layers( count ) = count * LAYER_HEIGHT;
function layer_height( height ) = ceil( height / LAYER_HEIGHT ) * LAYER_HEIGHT;
function tile_height( count ) = /* layer_height */ ( count * TILE_THICKNESS );

// ----- Physical Dimensions  -------------------------------------------------

$fn=60;             // Fine-grained corners
OVERLAP = 0.01;

BOTTOM = layers( 4 );
TOP    = layers( 4 );

GAP       = 0.20 * mm;  // Gap between outer and inner walls for boxes
NOTCH     = 10.0 * mm;  // Radius of notches

// ----- Modules --------------------------------------------------------------

module meeple_hole( radius, depth, size=2.75 ) {
    
    actual = sqrt(2) * size/2;
    
    difference() {
        cylinder( r=radius, h=depth );
        translate( [-radius-1, 0, -size/2] ) rotate( [45,0,0] ) cube( [2*radius+2, actual, actual] );
    }
}

module meeple_tray( rows=6, groups=5 ) {
    radius  = 7.0 * mm;                                 // Meeple hole radius == ceil( sqrt(2)/2 * meeple size )
    outer = WALL_WIDTH[4];                              // Outer space around holes

    tw = WALL_WIDTH[2];

    hole = 2*radius;                                    // (X) hole size
    hz = layer_height( ceil( MEEPLE_HEIGHT / 2 ) );     // (Z) hole depth

    sx1 = -radius;                                      // (X) offset from left side of box
    sx2 = -WALL_WIDTH[2];                               // (X) space between holes in a group
    sx3 = WALL_WIDTH[2]*2 + tw;                         // (X) space between groups

    sy1 = -radius;                                      // (Y) offset from front side of box
    sy2 = WALL_WIDTH[4];                                // (Y) space between holes in a row

    bx = 2*groups*hole + 2*sx1 + groups*sx2 + (groups-1)*sx3;
    by = (rows+0.5)*hole + 2*sy1 + (rows-0.5)*sy2;

    divider = WALL_WIDTH[3];                            // (Y) divider width

    ox1 = sx1 + radius;
    ox2 = sx1 + 3*radius + sx2;
    dx = 2*hole + sx2 + sx3;

    oy1 = sy1 + radius;
    oy2 = sy1 + 2*radius + sy2/2;
    dy = hole + sy2;

    union() {
        difference() {
            minkowski() {
                cube( [bx, by, BOTTOM + hz - OVERLAP] ) ;
                cylinder( r=outer+radius, h=OVERLAP );
            }

            // Remove meeple holes
            for (y=[0:rows-1]) {
                for (x=[0:groups-1]) {
                    translate( [ ox1+x*dx, oy1+y*dy, BOTTOM] ) meeple_hole( radius, hz+2*OVERLAP );
                    translate( [ ox2+x*dx, oy2+y*dy, BOTTOM] ) meeple_hole( radius, hz+2*OVERLAP );
                }
            }
        }

        // Add dividers
        for (x=[1:groups-1]) {
            translate( [sx1+x*dx-sx3/2, sy1, BOTTOM+hz] ) rotate( [-90,0,0] ) cylinder( d=divider, h=by-2*sy1 );
        }
    }
}

module meeple_lid( rows=6, groups=5 ) {
    radius  = 7.0 * mm;                                 // Meeple hole radius == ceil( sqrt(2)/2 * meeple size )
    outer = WALL_WIDTH[4];                              // Outer space around holes

    tw = WALL_WIDTH[2];

    hole = 2*radius;                                    // (X) hole size
    hz = layer_height( ceil( MEEPLE_HEIGHT ) );     // (Z) hole depth

    sx1 = -radius;                                      // (X) offset from left side of box
    sx2 = -WALL_WIDTH[2];                               // (X) space between holes in a group
    sx3 = WALL_WIDTH[2]*2 + tw;                         // (X) space between groups

    sy1 = -radius;                                      // (Y) offset from front side of box
    sy2 = WALL_WIDTH[4];                                // (Y) space between holes in a row

    bx = 2*groups*hole + 2*sx1 + groups*sx2 + (groups-1)*sx3;
    by = (rows+0.5)*hole + 2*sy1 + (rows-0.5)*sy2;

    ox1 = sx1 + radius;
    ox2 = sx1 + 3*radius + sx2;
    dx = 2*hole + sx2 + sx3;

    oy1 = sy1 + radius;
    oy2 = sy1 + 2*radius + sy2/2;
    dy = hole + sy2;

    difference() {
        union() {
            difference() {
                minkowski() {
                    minkowski() {
                        cube( [bx, by, TOP + hz - OVERLAP] ) ;
                        cylinder( r=outer+radius+GAP, h=OVERLAP );
                    }
                    cylinder( r=tw, h=OVERLAP );
                }

                translate( [GAP/2,GAP/2,TOP] ) minkowski() {
                    cube( [bx, by, TOP + hz - OVERLAP] ) ;
                    cylinder( r=outer+radius+GAP, h=OVERLAP );
                }
            }

            // Add steps to keep the lid from crashing the meeples
            for (x=[0:groups-1]) {
                translate( [ox2+x*dx, oy1+rows*dy+outer-tw/2, 0] ) difference() {
                    cylinder( d=radius, h=TOP+hz/2-1 );
                    translate( [-radius/2,0,-2*OVERLAP] ) cube( [radius+2*OVERLAP,radius/2+OVERLAP,TOP+hz/2-1+4*OVERLAP] );
                }
                translate( [ox1+x*dx, oy1-radius-outer-tw/2, 0] ) difference() {
                    cylinder( d=radius, h=TOP+hz/2-1 );
                    translate( [-radius/2+2*OVERLAP,-radius/2-OVERLAP,-2*OVERLAP] ) cube( [radius+2*OVERLAP,radius/2+OVERLAP,TOP+hz/2-1+4*OVERLAP] );
                }
            }
        }

        // Remove notches to make it easier to remove the lid
        color( "lime" ) translate( [bx/2,-radius-outer-tw-GAP-OVERLAP,hz+NOTCH/2] )
            rotate( [-90,0,0] ) cylinder( r=NOTCH, h=by+2*radius+2*outer+2*tw+2*GAP+4*OVERLAP );
    }
}

module tile_tray( tiles=4, tray=true ) {

    depth = tile_height( tiles );
    divider = tile_height( tiles-1 );

    tw = WALL_WIDTH[2];
    hw = tw / 2;
    gap = WALL_WIDTH[3];
    hg = gap / 2;

    x0 = 0;
    x1 = TILE_OFFSET;
    x2 = SM_TILE_LENGTH + 2*gap;
    x3 = TILE_OFFSET + SM_TILE_LENGTH + 2*gap;
    x4 = LG_TILE_LENGTH + 4*gap;
    x5 = TILE_OFFSET + LG_TILE_LENGTH + 4*gap;

    cx = x3 / 2;

    dy = TILE_HEIGHT/2 + gap;

    tile_outline = [ 
        [x1,dy*0], [x0,dy*1], [x1,dy*2], [x0,dy*3], [x1,dy*4], [x0,dy*5], [x1,dy*6], [x0,dy*7], [x1,dy*8],
        [x5,dy*8], [x4,dy*7], [x5,dy*6], [x4,dy*5], [x5,dy*4], [x4,dy*3], [x5,dy*2], [x4,dy*1], [x5,dy*0], 
    ];

    divider_outline = [
        [x3-hw,0*dy], [x2-hw,1*dy], [x3-hw,2*dy],
        [x3+hw,2*dy], [x2+hw,1*dy], [x3+hw,0*dy],
    ];

    if (VERBOSE) {
        echo( Bottom=BOTTOM, Top=TOP, Depth=depth, Divider=divider );
        echo( X=[x0, x1, x2, x3, x4, x5] );
    }

    union() {
        difference() {
            minkowski() {
                linear_extrude( BOTTOM+depth ) polygon( tile_outline );
                cylinder( r=THIN_WALL, h=OVERLAP );
            }
            
            if (tray) {
                // Remove interior
                translate( [0, 0, BOTTOM] ) linear_extrude( depth+2*OVERLAP ) polygon( tile_outline );
                
                // Remove finger holes
                translate( [x3-cx,dy*1,-OVERLAP] ) cylinder( r=NOTCH, h=BOTTOM+2*OVERLAP );
                translate( [x3-cx,dy*3,-OVERLAP] ) cylinder( r=NOTCH, h=BOTTOM+2*OVERLAP );
                translate( [x3-cx,dy*5,-OVERLAP] ) cylinder( r=NOTCH, h=BOTTOM+2*OVERLAP );
                translate( [x3-cx,dy*7,-OVERLAP] ) cylinder( r=NOTCH, h=BOTTOM+2*OVERLAP );
                translate( [x5-cx,dy*1,-OVERLAP] ) cylinder( r=NOTCH, h=BOTTOM+2*OVERLAP );
                translate( [x5-cx,dy*3,-OVERLAP] ) cylinder( r=NOTCH, h=BOTTOM+2*OVERLAP );
                translate( [x5-cx,dy*5,-OVERLAP] ) cylinder( r=NOTCH, h=BOTTOM+2*OVERLAP );
                translate( [x5-cx,dy*7,-OVERLAP] ) cylinder( r=NOTCH, h=BOTTOM+2*OVERLAP );
            }
        }

        if (tray) {
            // Add horizontal dividers
            translate( [x1-hw,dy*2-hw,0] ) cube( [x4+tw, tw, BOTTOM+depth+OVERLAP] );
            translate( [x1-hw,dy*4-hw,0] ) cube( [x4+tw, tw, BOTTOM+depth+OVERLAP] );
            translate( [x1-hw,dy*6-hw,0] ) cube( [x4+tw, tw, BOTTOM+depth+OVERLAP] );

            // Add more dividers
            translate( [0,0*dy,BOTTOM] ) linear_extrude( divider ) polygon( divider_outline );
            translate( [0,2*dy,BOTTOM] ) linear_extrude( divider ) polygon( divider_outline );
            translate( [0,4*dy,BOTTOM] ) linear_extrude( divider ) polygon( divider_outline );
            translate( [0,6*dy,BOTTOM] ) linear_extrude( divider ) polygon( divider_outline );
        }
    }
}

module tile_lid( tiles=4 ) {
    difference() {
        minkowski() {
            tile_tray( tiles, false );
            cylinder( r=THIN_WALL, h=OVERLAP );
        }
        
        // Remove contents
        translate( [0, 0, TOP] ) tile_tray( tiles, false );
        
        // Remove notch
        translate( [(TILE_OFFSET+2*SM_TILE_LENGTH+2*WALL_WIDTH[3])/2,-2*THIN_WALL-OVERLAP,3*NOTCH/2] ) rotate( [-90,0,0] ) cylinder( r=NOTCH, h=4*TILE_HEIGHT+8*WALL_WIDTH[3]+4*THIN_WALL+2*OVERLAP );
    }
}

// ----- Render Logic for makefile --------------------------------------------

if (VERBOSE) {
	echo (Part=PART);
}

if (PART == "tile-tray") {
    tile_tray();
} else if (PART == "tile-lid") {
    tile_lid();
} else if (PART == "meeple-tray") {
    meeple_tray();
} else if (PART == "meeple-lid") {
    meeple_lid();
} else {
    translate( [  0, 0, 0] ) tile_tray();
    translate( [125, 0, 0] ) tile_lid();
    translate( [280, 0, 0] ) meeple_tray();
    translate( [280, 110, 0] ) meeple_lid();
}
