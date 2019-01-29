// 1830: The Game of Railroads and Robber Barons
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = 1;        	// Set to non-zero to see more data

// Game box dimensions
BOX_HEIGHT      = 12.125 * inch;
BOX_WIDTH       =  8.5 * inch;
BOX_DEPTH       =  2.0 * inch;

// Tray
TRAY_LENGTH = 8.5 * inch;
TRAY_WIDTH  = 150 * mm;

// Tile dimensions
TILE_DIAMETER   = 39.0 * mm;
TILE_THICKNESS  =  2.0 * mm;
POKE_HOLE       = 30.0 * mm;    // Diameter of poke holes in bottom

// Part box dimensions
TOKEN_WIDTH      = 35.0 * mm;   // X
TOKEN_DEPTH      = 17.5 * mm;   // Y
TOKEN_HEIGHT     = 6.00 * mm;   // Z

TILE_CENTERS = [
    [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ], [18, 2],
    [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ], [20, 5],
    [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ], [18, 8],
    [ 4,11 ], [ 8,11 ], [ 12,11 ], [ 16,11 ], [20,11],
];

include <18XX.scad>;

// ----- Data ------------------------------------------------------------------

// ----- Functions -------------------------------------------------------------

// ----- Modules ---------------------------------------------------------------

// ----- Rendering -------------------------------------------------------------

if (PART == "tile-tray") {
    hex_tray( TRAY_LENGTH, TRAY_WIDTH, 6*TILE_THICKNESS+STUB, WIDE_WALL );
} else if (PART == "tile-lid") {
    hex_lid( TRAY_LENGTH, TRAY_WIDTH, 4*mm, WIDE_WALL, THIN_WALL, false, false );
} else {
    translate( [0, 5,0] ) hex_tray( TRAY_LENGTH, TRAY_WIDTH, 6*TILE_THICKNESS+STUB, WIDE_WALL );
    translate( [0,-5,0] ) hex_lid( TRAY_LENGTH, TRAY_WIDTH, 4*mm, WIDE_WALL, THIN_WALL, false, false );
}
