// Brass: Lancashire and Brass: Birmingham
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;
include <../util/boxes.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = 1;        	// Set to non-zero to see more data

// Game box dimensions
COMPARTMENT_HEIGHT =  2.00 * inch;  // (Z)
COMPARTMENT_WIDTH  = 10.00 * inch;  // (X)
COMPARTMENT_DEPTH  = 78.00 * mm;    // (Y)
COMPARTMENT_CORNER =  0.25 * inch;  // Corner Radius

// Tile dimensions
TILE_SIZE      = 1.00 * inch;   // 37 for Lancashire, 45 for Birmingham
TILE_THICKNESS = 1.91 * mm;

LINK_LENGTH    = 30 * mm;       // 14 canal / rail tokens
LINK_WIDTH     = 17 * mm;

CHARACTER      = 42 * mm;       // Diameter

FOREIGN_MARKET = 15 * mm;       // Height
TOKEN_DIAMETER = 15 * mm;

// Physical box dimensions
BOTTOM    = 0.60 * mm;  // Bottom plate thickness
TOP       = 0.60 * mm;  // Top plate thickness
SPACING   = 1.00 * mm;  // Additional play in compartments
OVERLAP   = 0.10 * mm;
GAP       = 0.20 * mm;  // Gap between outer and inner walls for boxes

// 3D Printer
LAYER_HEIGHT = 0.20 * mm;
THIN_WALL    = 0.86 * mm;  	// Based on 0.20mm layer height
WIDE_WALL    = 1.67 * mm;  	// Based on 0.20mm layer height

// ----- Data ------------------------------------------------------------------

LANCASHIRE_CARDS = 70;
BIRMINGHAM_CARDS = 76;

/*
 * [0] = Cotten or half Cotten
 * [1] = Coal
 * [2] = Iron
 * [3] = Manufacturers or half Cotten
 * [4] = Beer or Shipyards
 * [5] = Pottery or Ports
 */

LANCASHIRE_TILES = [  6, 7, 4,  6, 6, 8 ];
BIRMINGHAM_TILES = [ 11, 7, 4, 11, 7, 5 ];

lpx = 35; lpy = 60;
LANCASHIRE_PARTS = [ [ [ lpx, lpy ], [ lpx, lpy ], [ lpx, lpy ] ] ];

// ----- Functions -------------------------------------------------------------

function layer_height( height ) = ceil( height / LAYER_HEIGHT ) * LAYER_HEIGHT;
function tile_height( count ) = (count + 0.5) * TILE_THICKNESS;

// ----- Modules ---------------------------------------------------------------

/* brass_box( length, height, bottom, wall, hollow )
 *
 * Produces a box that is sized to fit the large Brass insert bay,
 * with corner cuts to match the insert. It will always use the full
 * depth of the space,
 */
module brass_box( length, height, bottom, wall, hollow=true ) {
    bx = length + 4*wall + 2*GAP;
    by = COMPARTMENT_DEPTH;
    bz = height/2 + bottom;
    br = COMPARTMENT_CORNER;

    lx = bx - 2*wall - 2*GAP;
    ly = by - 2*wall - 2*GAP;
    lz = height+bottom;
    lr = br + wall + GAP;

    if (VERBOSE) {
        echo( BrassBoxOut=[ bx, by, bz, br ] );
    }

    translate( [-2*wall-GAP, -2*wall-GAP, -bottom] ) difference() {
        union() {
            color( "tan" ) difference() {
                cube( [bx, by, bz] );
                translate( [ 00, 00, -OVERLAP ] ) cylinder( r=br, h=bz+2*OVERLAP );
                translate( [ bx, 00, -OVERLAP ] ) cylinder( r=br, h=bz+2*OVERLAP );
                translate( [ 00, by, -OVERLAP ] ) cylinder( r=br, h=bz+2*OVERLAP );
                translate( [ bx, by, -OVERLAP ] ) cylinder( r=br, h=bz+2*OVERLAP );
            }

            color( "plum" ) difference() {
                translate( [ wall+GAP, wall+GAP, 0 ] ) cube( [lx, ly, lz] );
                translate( [ 00, 00, -OVERLAP ] ) cylinder( r=lr, h=lz+2*OVERLAP );
                translate( [ bx, 00, -OVERLAP ] ) cylinder( r=lr, h=lz+2*OVERLAP );
                translate( [ 00, by, -OVERLAP ] ) cylinder( r=lr, h=lz+2*OVERLAP );
                translate( [ bx, by, -OVERLAP ] ) cylinder( r=lr, h=lz+2*OVERLAP );
            }
        }

        if (hollow) {
            ix = lx - 2*wall;
            iy = ly - 2*wall;
            iz = lz;
            ir = lr + wall;

            difference() {
                translate( [ 2*wall+GAP, 2*wall+GAP, bottom ] ) cube( [ix, iy, iz] );
                translate( [ 00, 00, -OVERLAP ] ) cylinder( r=ir, h=iz+2*OVERLAP );
                translate( [ bx, 00, -OVERLAP ] ) cylinder( r=ir, h=iz+2*OVERLAP );
                translate( [ 00, by, -OVERLAP ] ) cylinder( r=ir, h=iz+2*OVERLAP );
                translate( [ bx, by, -OVERLAP ] ) cylinder( r=ir, h=iz+2*OVERLAP );
            }
        }
    }
}

module brass_lid( length, height, top, wall ) {
    bx = length + 2*wall + 2*GAP;
    by = COMPARTMENT_DEPTH;
    bz = height/2+top;
    br = COMPARTMENT_CORNER;

    lx = length;
    ly = by - 2*wall - 2*GAP;
    lz = bz;
    lr = br + wall + GAP;

    if (VERBOSE) {
        echo( BrassLidOut=[ bx, by, bz, br ] );
    }

    translate( [-2*wall-GAP, -2*wall-GAP, -top] ) difference() {
        color( "tan" ) difference() {
            cube( [bx, by, bz] );
            translate( [ 00, 00, -OVERLAP ] ) cylinder( r=br, h=bz+2*OVERLAP );
            translate( [ bx, 00, -OVERLAP ] ) cylinder( r=br, h=bz+2*OVERLAP );
            translate( [ 00, by, -OVERLAP ] ) cylinder( r=br, h=bz+2*OVERLAP );
            translate( [ bx, by, -OVERLAP ] ) cylinder( r=br, h=bz+2*OVERLAP );
        }

        color( "plum" ) difference() {
            translate( [ wall, wall, top ] ) cube( [lx, ly, lz] );
            translate( [ 00, 00, -OVERLAP ] ) cylinder( r=lr, h=lz+2*OVERLAP );
            translate( [ bx, 00, -OVERLAP ] ) cylinder( r=lr, h=lz+2*OVERLAP );
            translate( [ 00, by, -OVERLAP ] ) cylinder( r=lr, h=lz+2*OVERLAP );
            translate( [ bx, by, -OVERLAP ] ) cylinder( r=lr, h=lz+2*OVERLAP );
        }
    }
}

/* tile_hole( width, depth, height )
 *
 * Produces an object that is the right size hole for a stack of tiles
 * that is width (X) x depth (Y)  x height (Z) and centered at [0,0].
 * The actual width and depth will be 2*SPACING more than asked.
 */
module tile_hole( width, depth, height ) {

    w1 = (width-SPACING) / 2;
    d1 = (depth-SPACING) / 2;
    h1 = 0;
    w2 = width / 2;
    d2 = depth / 2;
    h2 = height + OVERLAP;

    points = [
        [ -w1, -d1, h1 ],   // p0
        [ +w1, -d1, h1 ],   // p1
        [ +w1, +d1, h1 ],   // p2
        [ -w1, +d1, h1 ],   // p3
        [ -w2, -d2, h2 ],   // p4
        [ +w2, -d2, h2 ],   // p5
        [ +w2, +d2, h2 ],   // p6
        [ -w2, +d2, h2 ],   // p7
    ];

    faces = [
        [0,1,2,3],  // bottom
        [4,5,1,0],  // front
        [7,6,5,4],  // top
        [5,6,2,1],  // right
        [6,7,3,2],  // back
        [7,4,0,3],  // left
    ];

    minkowski() {
        polyhedron( points, faces );
        cylinder( r=SPACING, h=OVERLAP );
    }
}

module tile_box( tiles ) {
    tx = TILE_SIZE   + 2*SPACING;
    ty = TILE_SIZE   + 2*SPACING;
    lx = LINK_WIDTH  + 2*SPACING;
    ly = LINK_LENGTH + 2*SPACING;
    tr = (TOKEN_DIAMETER + SPACING) / 2;

    ix = 3*tx + lx + 3*THIN_WALL;
    iy = COMPARTMENT_DEPTH - 4*THIN_WALL - 2*GAP;
    iz = layer_height( tile_height( max( tiles ) ) );

    tw = THIN_WALL;
    ww = WIDE_WALL;

    cx = ix/2;
    cy = iy/2;

    hx1 = tx/2;
    hx2 = tx + tw + lx/2;
    hx3 = tx + tw + tx/2;
    hx4 = tx + tw + lx + tw + tx/2;
    hx5 = tx + tw + tx + tw + lx/2;
    hx6 = tx + tw + lx + tw + tx + tw + tx/2;

    hy1 = ty/2;
    hy2 = ly/2;
    hy3 = cy - tw - ty/2;
    hy4 = ty + tr - tw/2;
    hy5 = iy - ty - tr + tw/2;
    hy6 = cy + tw + ty/2;
    hy7 = iy - ly/2;
    hy8 = iy - ty/2;

    difference() {
        brass_box( ix, iz, BOTTOM, THIN_WALL, false );

        // Remove holes for industry tiles, removing extra space for tiles under the character tile
        translate( [hx1, hy6, iz-tile_height( tiles[0] )] )   tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[0] ) );
        translate( [hx3, hy8, iz-tile_height( tiles[1]+1 )] ) tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[1]+1 ) );
        translate( [hx6, hy6, iz-tile_height( tiles[2] )] )   tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[2] ) );
        translate( [hx6, hy3, iz-tile_height( tiles[3] )] )   tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[3] ) );
        translate( [hx4, hy1, iz-tile_height( tiles[4]+1 )] ) tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[4]+1 ) );
        translate( [hx1, hy3, iz-tile_height( tiles[5] )] )   tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[5] ) );

        // Remove holes for canal / rail links
        th8 = tile_height( 8 );
        translate( [hx5, hy7, iz-th8] ) tile_hole( LINK_WIDTH, LINK_LENGTH, th8 );
        translate( [hx2, hy2, iz-th8] ) tile_hole( LINK_WIDTH, LINK_LENGTH, th8 );

        // Remove hole for the character tile
        th1 = tile_height( 1 );
%       translate( [cx, cy, iz-th1] ) cylinder( d=CHARACTER+SPACING, h=th1+OVERLAP );

        // Remove holes for the VP and Income tokens
        th3 = tile_height( 3 );
#       translate( [hx3, hy5, iz-th3] ) cylinder( d=TOKEN_DIAMETER+SPACING, h=th3+OVERLAP );
#       translate( [hx4, hy4, iz-th3] ) cylinder( d=TOKEN_DIAMETER+SPACING, h=th3+OVERLAP, $fn=6 );
    }
}

module tile_lid( tiles ) {
    tx = TILE_SIZE   + 2*SPACING;
    ty = TILE_SIZE   + 2*SPACING;
    lx = LINK_WIDTH  + 2*SPACING;
    ly = LINK_LENGTH + 2*SPACING;
    tr = (TOKEN_DIAMETER + SPACING) / 2;

    ix = 3*tx + lx + 3*THIN_WALL;
    iy = COMPARTMENT_DEPTH - 4*THIN_WALL;
    iz = layer_height( tile_height( max( tiles ) ) );

    cx = ix/2;
    cy = iy/2;

    difference() {
        brass_lid( ix+2*THIN_WALL, iz, TOP, THIN_WALL );
        translate( [ cx, cy, -TOP-OVERLAP ] ) cylinder( d=CHARACTER-4*SPACING, h=TOP+2*OVERLAP );
    }
}

// ----- Rendering -------------------------------------------------------------

if (PART == "lancashire-tile-box") {
    tile_box( LANCASHIRE_TILES );
} else if (PART == "lancashire-tile-lid") {
    tile_lid( LANCASHIRE_TILES );
} else if (PART == "lancashire-part-box") {
    cell_box( LANCASHIRE_PARTS, FOREIGN_MARKET+SPACING, BOTTOM, TOP, THIN_WALL, WIDE_WALL );
} else if (PART == "lancashire-part-lid") {
    cell_lid( LANCASHIRE_PARTS, FOREIGN_MARKET+SPACING, BOTTOM, TOP, THIN_WALL, WIDE_WALL );
} else if (PART == "birmingham-tile-box") {
    tile_box( BIRMINGHAM_TILES );
} else if (PART == "birmingham-tile-lid") {
    tile_lid( BIRMINGHAM_TILES );
} else if (PART == "deck-box" ) {
    thin_deck_box( FFS_STANDARD, LANCASHIRE_CARDS, THIN_WALL );
} else {
    translate( [  0,  0, 0] ) tile_box( LANCASHIRE_TILES );
    translate( [  0, 90, 0] ) tile_lid( LANCASHIRE_TILES );
    translate( [110,  0, 0] ) tile_box( BIRMINGHAM_TILES );
    translate( [110, 90, 0] ) tile_lid( BIRMINGHAM_TILES );
}
