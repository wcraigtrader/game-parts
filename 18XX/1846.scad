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

// Tile dimensions
TILE_DIAMETER   = 50.0 * mm;
TILE_THICKNESS  =  3.0 * mm;
POKE_HOLE       = 40.0 * mm;    // Diameter of poke holes in bottom

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

// Poker chip dimensions
CHIP_DIAMETER   = 41 * mm;
CHIP_THICKNESS  = 3.31 * mm;


GAP     = 0.25 * mm;    // Size differential between box and lid, for snug fit
LIP     = 5.00 * mm;
SPACING = 1.00 * mm;    // Room for tiles to shift

TILE_CENTERS = [
    [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ],
    [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ],
    [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ],
];

include <18XX.scad>;

// ----- Functions -------------------------------------------------------------

function tile_height( count ) = count * TILE_THICKNESS;

// ----- Modules ---------------------------------------------------------------

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
    bz = ceil( max( COMPANY_CARDS, OTHER_CARDS, MARK_DIAMETER ) ) + TOP;

    dx = bx - 2*WIDE_WALL;
    dy = by - 2*WIDE_WALL;

    ho = 10 * mm;
    hx = dx - 2*ho;
    hy = dy - 2*ho;

    difference() {
        union() {
            cube( [bx, by, TOP] );
            translate( [ 2*WIDE_WALL, WIDE_WALL+GAP, TOP-OVERLAP] ) cube( [dx-2*WIDE_WALL, THIN_WALL, LIP+OVERLAP] );
            translate( [ 2*WIDE_WALL, by-WIDE_WALL-THIN_WALL-GAP, TOP-OVERLAP] ) cube( [dx-2*WIDE_WALL, THIN_WALL, LIP+OVERLAP] );
        }

    translate( [ WIDE_WALL + ho, WIDE_WALL + ho, -OVERLAP] ) cube( [ hx, hy, bz+2*OVERLAP ] );
    }
}

// ----- Rendering -------------------------------------------------------------

if (PART == "short-tile-tray") {
    hex_tray( FULL_X, HALF_Y, tile_height( 2 ), WIDE_WALL );
} else if (PART == "tall-tile-tray") {
    hex_tray( FULL_X, HALF_Y, tile_height( 5 ), WIDE_WALL );
} else if (PART == "tile-tray-lid") {
    hex_lid( FULL_X, HALF_Y, 6*mm, WIDE_WALL, THIN_WALL, true );
} else if (PART == "card-tray") {
    card_tray();
} else if (PART == "card-tray-lid") {
    card_tray_lid();
} else if (PART == "card-tray-plate") {
    translate( [ 0, 88, 0] ) rotate( [0, 0, -90] ) card_tray();
    translate( [58, 88, 0] ) rotate( [0, 0, -90] ) card_tray_lid();
} else {
    // hex_tray( FULL_X, HALF_Y, tile_height( 5 ), WIDE_WALL );
    hex_lid( FULL_X, HALF_Y, 6*mm, WIDE_WALL, THIN_WALL, true );
    // card_tray();
}
