// 1867: The Railways of Canada
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = 1;        	// Set to non-zero to see more data

// Game box dimensions
BOX_WIDTH       = 11.500 * inch;    // (X)
BOX_HEIGHT      =  9.625 * inch;    // (Y)
BOX_DEPTH       =  2.250 * inch;    // (Z)

ALT_WIDTH       = 8.000 * inch;
ALT_HEIGHT      = 7.000 * inch;

// Tile dimensions
TILE_DIAMETER   = 26.00 * mm;
TILE_THICKNESS  =  0.65 * mm;
POKE_HOLE       = 18.00 * mm;    // Diameter of poke holes in bottom

include <18XX.scad>;

// ----- Data ------------------------------------------------------------------

// ----- Functions -------------------------------------------------------------

// ----- Modules ---------------------------------------------------------------

module tile_box( count=5 ) {
    hex_tray( TILE_CENTERS_6X8X, BOX_HEIGHT, BOX_WIDTH/2, count*TILE_THICKNESS+STUB, WIDE_WALL, "1822", "V1" );
}

module tile_lid( holes=true ) {
    hex_lid( TILE_CENTERS_6X8X, BOX_HEIGHT, BOX_WIDTH/2, 4*mm, WIDE_WALL, THIN_WALL, false, true, holes );
}

module alt_tile_box( count=5 ) {
    hex_tray( TILE_CENTERS_7X7, ALT_WIDTH, ALT_HEIGHT, count*TILE_THICKNESS+STUB, WIDE_WALL, "1822", "V2" );
}

module alt_tile_lid( holes=true ) {
    hex_lid( TILE_CENTERS_7X7, ALT_WIDTH, ALT_HEIGHT, 4*mm, WIDE_WALL, THIN_WALL, false, true, holes );
}

// ----- Rendering -------------------------------------------------------------

if (PART == "tile-lid") {
    tile_lid();
} else if (PART == "tile-tray") {
    tile_box(8);
} else if (PART == "alt-tile-lid") {
    alt_tile_lid();
} else if (PART == "alt-tile-tray") {
    alt_tile_box(8);
} else {
    alt_tile_box(8);
    translate( [210,0,0] ) 
    tile_box(8);
}
