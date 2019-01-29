// Brass: Lancashire and Brass: Birmingham
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = 1;        	// Set to non-zero to see more data

// Game box dimensions
COMPARTMENT_HEIGHT = 52.00 * mm;    // (Z)
COMPARTMENT_WIDTH  = 10.00 * inch;  // (X)
COMPARTMENT_DEPTH  = 78.00 * mm;    // (Y)
COMPARTMENT_CORNER =  0.25 * inch;  // Corner Radius
COMPARTMENT_EXTRA  = 45.00 * mm;    // (X) Space left after 2 tile boxes

// Tile dimensions
TILE_SIZE       = 1.00 * inch;   // 37 for Lancashire, 45 for Birmingham
TILE_THICKNESS  = 1.91 * mm;

LINK_LENGTH     = 30 * mm;       // 14 canal / rail tokens
LINK_WIDTH      = 17 * mm;

CHARACTER       = 42 * mm;       // Diameter
TOKEN_DIAMETER  = 15 * mm;

MARKET_HEIGHT   = 25 * mm;
MARKET_DEPTH    = 65 * mm;
MARKET_COUNT    = 12;

// Deck box dimensions
DECK_WELL_WIDTH = 65 * mm;
DECK_BOX_SPACING =  1.00 * mm;
DECK_BOK_OVERLAP = 20.00 * mm;

// Physical dimensions
BOTTOM    = 0.60 * mm;  // Bottom plate thickness
TOP       = 0.60 * mm;  // Top plate thickness
SPACING   = 1.00 * mm;  // Additional play in compartments
OVERLAP   = 0.10 * mm;
GAP       = 0.20 * mm;  // Gap between outer and inner walls for boxes
NOTCH     = 10.0 * mm;  // Radius of notches
TEXT      = 0.40 * mm;  // Depth of engraved text in tile holes

// 3D Printer
LAYER_HEIGHT = 0.20 * mm;
THIN_WALL    = 0.86 * mm;  	// Based on 0.20mm layer height
WIDE_WALL    = 1.67 * mm;  	// Based on 0.20mm layer height

// ----- Card Sleeves ----------------------------------------------------------

/*
 * [0] = (X) outside width of sleeved card (mm)
 * [1] = (Z) outside height of sleeved card (mm)
 * [2] = (Y) average thickness of sleeved card (mm)
 */

// ----- Data ------------------------------------------------------------------

FFS_STANDARD = [ 66.70, 94.60, 0.625 ];
ULP_STANDARD = [ 67.00, 95.00, 0.625 ];

// ----- Functions -------------------------------------------------------------

function layer_height( height ) = ceil( height / LAYER_HEIGHT ) * LAYER_HEIGHT;
function tile_height( count ) = (count + 0.5) * TILE_THICKNESS;
function max_tile_height( tiles ) = layer_height( tile_height( max( tiles[0][0], tiles[1][0], tiles[2][0], tiles[3][0], tiles[4][0], tiles[5][0] ) ) + TEXT );

// ----- Modules ---------------------------------------------------------------

HOLLOW = true;
SOLID  = false;

/* brass_box( length, height, bottom, wall, hollow )
 *
 * Produces a box that is sized to fit the large Brass insert well,
 * with corner cuts to match the insert. It will always use the full
 * depth of the space,
 */
module brass_box( length, height, bottom, wall, hollow=HOLLOW ) {
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

/* brass_lid( length, height, top, wall )
 *
 * Produces a matching lid for a brass box with the same parameters,
 */
module brass_lid( length, height, top, wall ) {
    bx = length + 2*wall + 2*GAP;
    by = COMPARTMENT_DEPTH;
    bz = height/2+top;
    br = COMPARTMENT_CORNER;

    lx = length + 2*GAP;
    ly = by - 2*wall;
    lz = bz;
    lr = br + wall;

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

        // Remove notches to make it easier to remove the lid
        color( "lime" ) translate( [-OVERLAP,by/2,bz+NOTCH/2] )
            rotate( [0,90,0] ) cylinder( r=NOTCH, h=bx+2*OVERLAP );

    }
}

/* tile_hole( width, depth, height )
 *
 * Produces an object that is the right size hole for a stack of tiles
 * that is width (X) x depth (Y)  x height (Z) and centered at [0,0].
 * The actual width and depth will be 2*SPACING more than asked.
 */
module tile_hole( width, depth, height, name="" ) {

    w1 = (width-SPACING) / 2;
    d1 = (depth-SPACING) / 2;
    h1 = 0;
    w2 = width / 2;
    d2 = depth / 2;
    h2 = height + OVERLAP;

    rotation = width == depth ? [0,0,45] : [0,0,90];

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

    union() {
        minkowski() {
            polyhedron( points, faces );
            cylinder( r=SPACING, h=OVERLAP );
        }
        
        translate( [0,0,-TEXT] ) rotate( rotation )
            linear_extrude( height=2*TEXT+OVERLAP, center=true )
                mirror( [0,0,0] )
                    text( name, font="Liberation Sans", size=8, halign="center", valign="center" );
    }
}

/* tile_box( tiles )
 *
 * Produces a box to hold all the tiles,
 * with adjustable tile heights for the different game variants.
 *
 * [0] = Cotton or half Cotton (L)
 * [1] = Coal
 * [2] = Iron
 * [3] = Manufacturers or half Cotton (L)
 * [4] = Beer or Shipyards
 * [5] = Pottery or Ports
 */

LANCASHIRE_TILES = [  6, 7, 4,  6, 6, 8 ];
BIRMINGHAM_TILES = [ 11, 7, 4, 11, 7, 5 ];

LANCASHIRE_TILES = [ [ 6, "Cotton"], [7, "Coal"], [4, "Iron"], [ 6, "Cotton"], [6, "Ships"], [8, "Ports"] ];
BIRMINGHAM_TILES = [ [11, "Cotton"], [7, "Coal"], [4, "Iron"], [11, "Goods" ], [7, "Beer" ], [5, "Pots" ] ]; 

module tile_box( tiles ) {
    tx = TILE_SIZE   + 2*SPACING;
    ty = TILE_SIZE   + 2*SPACING;
    lx = LINK_WIDTH  + 2*SPACING;
    ly = LINK_LENGTH + 2*SPACING;
    tr = (TOKEN_DIAMETER + SPACING) / 2;

    ix = 3*tx + lx + 3*THIN_WALL;
    iy = COMPARTMENT_DEPTH - 4*THIN_WALL - 2*GAP;

    // If the height of the box is close to half height, use that instead
    mth = max_tile_height( tiles );
    hch = COMPARTMENT_HEIGHT/2 - TOP - BOTTOM;
    iz = (hch-mth < 3) ? hch : mth;

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

    if (VERBOSE) {
        echo( TileBoxInside=[ ix, iy, iz ] );
    }

    difference() {
        brass_box( ix, iz, BOTTOM, THIN_WALL, SOLID );

        // Remove holes for industry tiles, removing extra space for tiles under the character tile
        translate( [hx1, hy6, iz-tile_height( tiles[0][0] )] )   tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[0][0] ),   tiles[0][1] );
        translate( [hx3, hy8, iz-tile_height( tiles[1][0]+1 )] ) tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[1][0]+1 ), tiles[1][1] );
        translate( [hx6, hy6, iz-tile_height( tiles[2][0] )] )   tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[2][0] ),   tiles[2][1] );
        translate( [hx6, hy3, iz-tile_height( tiles[3][0] )] )   tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[3][0] ),   tiles[3][1] );
        translate( [hx4, hy1, iz-tile_height( tiles[4][0]+1 )] ) tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[4][0]+1 ), tiles[4][1] );
        translate( [hx1, hy3, iz-tile_height( tiles[5][0] )] )   tile_hole( TILE_SIZE, TILE_SIZE, tile_height( tiles[5][0] ),   tiles[5][1] );

        // Remove holes for canal / rail links
        thl = tile_height( 7+1 );
        translate( [hx5, hy7, iz-thl] ) tile_hole( LINK_WIDTH, LINK_LENGTH, thl, "Links" );
        translate( [hx2, hy2, iz-thl] ) tile_hole( LINK_WIDTH, LINK_LENGTH, thl, "Links" );

        // Remove hole for the character tile
        th1 = tile_height( 1 );
        translate( [cx, cy, iz-th1] ) cylinder( d=CHARACTER+SPACING, h=th1+OVERLAP );

        // Remove holes for the VP and Income tokens
        th3 = tile_height( 3 );
        translate( [hx3, hy5, iz-th3] ) cylinder( d=TOKEN_DIAMETER+SPACING, h=th3+OVERLAP );
        translate( [hx4, hy4, iz-th3] ) cylinder( d=TOKEN_DIAMETER+3*SPACING, h=th3+OVERLAP, $fn=6 );
    }
}

/* tile_lid( tiles )
 *
 * Produces a lid for the matching tile_box, with a hole in the top
 * to reveal the character / color of tiles in the box.
 */
module tile_lid( tiles ) {
    tx = TILE_SIZE   + 2*SPACING;
    ty = TILE_SIZE   + 2*SPACING;
    lx = LINK_WIDTH  + 2*SPACING;
    ly = LINK_LENGTH + 2*SPACING;
    tr = (TOKEN_DIAMETER + SPACING) / 2;

    ix = 3*tx + lx + 3*THIN_WALL;
    iy = COMPARTMENT_DEPTH - 4*THIN_WALL;

    // If the height of the box is close to half height, use that instead
    mth = max_tile_height( tiles );
    hch = COMPARTMENT_HEIGHT/2 - TOP - BOTTOM;
    iz = (hch-mth < 3) ? hch : mth;

    cx = ix/2;
    cy = iy/2;

    difference() {
        brass_lid( ix+2*THIN_WALL, iz, TOP, THIN_WALL );

        // Remove viewport for character
        translate( [ cx, cy, -TOP-OVERLAP ] ) cylinder( d=CHARACTER-4*SPACING, h=TOP+2*OVERLAP );
    }
}

EMPTY      = 0;
LANCASHIRE = 1;
BIRMINGHAM = 2;
MARKETS    = 3;

module part_box( mode=EMPTY ) {
    ix = (mode == LANCASHIRE ? DECK_WELL_WIDTH : COMPARTMENT_EXTRA) - 4*THIN_WALL - 2*GAP;
    iy = COMPARTMENT_DEPTH - 4*THIN_WALL - 2*GAP;
    iz = (mode == MARKETS ? COMPARTMENT_HEIGHT : COMPARTMENT_HEIGHT/2) - TOP - BOTTOM;

    cy = iy/2;

    tw = THIN_WALL;
    hw = THIN_WALL / 2;

    union() {
        brass_box( ix, iz, BOTTOM, THIN_WALL, HOLLOW );
        if (mode == LANCASHIRE) {
            translate( [ -OVERLAP, cy-hw, -OVERLAP ] ) cube( [ix+2*OVERLAP, tw, iz+2*OVERLAP] );
        } else if (mode == BIRMINGHAM ) {
            cx = tile_height( 7 ) + hw;
            translate( [ cx-OVERLAP-hw, -OVERLAP, -OVERLAP ] ) cube( [tw, iy+2*OVERLAP, iz+2*OVERLAP] );
            translate( [ cx-OVERLAP, cy-hw, -OVERLAP ] ) cube( [ix-cx+2*OVERLAP, tw, iz+2*OVERLAP] );
        }
    }
}

module part_lid( mode=EMPTY ) {
    ix = (mode == LANCASHIRE ? DECK_WELL_WIDTH : COMPARTMENT_EXTRA) - 2*THIN_WALL - 2*GAP;
    iz = (mode == MARKETS ? COMPARTMENT_HEIGHT : COMPARTMENT_HEIGHT/2) - TOP - BOTTOM;

    brass_lid( ix, iz, TOP, THIN_WALL, true );
}

LANCASHIRE_CARDS = 70;
BIRMINGHAM_CARDS = 76;

module thin_deck_box( sizes, quantity, wall ) {
    bottom = 3 * LAYER_HEIGHT;

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


// ----- Rendering -------------------------------------------------------------

if (PART == "lancashire-tile-box") {
    tile_box( LANCASHIRE_TILES );
} else if (PART == "lancashire-tile-lid") {
    tile_lid( LANCASHIRE_TILES );
} else if (PART == "lancashire-tile-plate") {
    translate( [0, 0,0] ) tile_box( LANCASHIRE_TILES );
    translate( [0,90,0] ) tile_lid( LANCASHIRE_TILES );

} else if (PART == "lancashire-goods-box") {
    part_box( LANCASHIRE );
} else if (PART == "lancashire-goods-lid") {
    part_lid( LANCASHIRE);
} else if (PART == "lancashire-markets-box") {
    part_box( MARKETS );
} else if (PART == "lancashire-markets-lid") {
    part_lid( MARKETS);
} else if (PART == "lancashire-parts-plate") {
    translate( [ 0, 0,0] ) part_box( MARKETS );
    translate( [ 0,90,0] ) part_lid( MARKETS );
    translate( [50, 0,0] ) part_box( LANCASHIRE );
    translate( [50,90,0] ) part_lid( LANCASHIRE );

} else if (PART == "birmingham-tile-box") {
    tile_box( BIRMINGHAM_TILES );
} else if (PART == "birmingham-tile-lid") {
    tile_lid( BIRMINGHAM_TILES );
} else if (PART == "birmingham-tile-plate") {
    translate( [0, 0,0] ) tile_box( BIRMINGHAM_TILES );
    translate( [0,90,0] ) tile_lid( BIRMINGHAM_TILES );

} else if (PART == "birmingham-goods-box") {
    part_box( BIRMINGHAM );
} else if (PART == "birmingham-goods-lid") {
    part_lid();
} else if (PART == "birmingham-beer-box") {
    part_box();
} else if (PART == "birmingham-beer-lid") {
    part_lid();
} else if (PART == "birmingham-parts-plate" ) {
    translate( [ 0, 0,0] ) part_box( BIRMINGHAM );
    translate( [ 0,90,0] ) part_lid( BIRMINGHAM );
    translate( [50, 0,0] ) part_box( EMPTY );
    translate( [50,90,0] ) part_lid( EMPTY );

} else if (PART == "deck-box-ffs" ) {
    thin_deck_box( FFS_STANDARD, LANCASHIRE_CARDS, THIN_WALL );
} else if (PART == "deck-box-ulp" ) {
    thin_deck_box( ULP_STANDARD, LANCASHIRE_CARDS, THIN_WALL );
    
} else {
    translate( [0, 0,0] ) tile_box( BIRMINGHAM_TILES );
    translate( [0,90,0] ) tile_lid( BIRMINGHAM_TILES );
    /*
    translate( [  0, 0,0] ) part_box( BIRMINGHAM );
    translate( [  0,90,0] ) part_lid( BIRMINGHAM );
    translate( [ 50, 0,0] ) part_box( EMPTY );
    translate( [ 50,90,0] ) part_lid( EMPTY );
    translate( [100, 0,0] ) part_box( MARKETS );
    translate( [100,90,0] ) part_lid( MARKETS );
    translate( [150, 0,0] ) part_box( LANCASHIRE );
    translate( [150,90,0] ) part_lid( LANCASHIRE );}
    */
}