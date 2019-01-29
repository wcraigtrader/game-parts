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
BOX_HEIGHT      = 11.125 * inch;
BOX_WIDTH       =  8.0 * inch;
BOX_DEPTH       =  2.0 * inch;

// Tile dimensions
TILE_DIAMETER   = 46.0 * mm;
TILE_THICKNESS  =  0.5 * mm;
POKE_HOLE       = 35.0 * mm;    // Diameter of poke holes in bottom

// Part box dimensions
TOKEN_WIDTH      = 35.0 * mm;   // X
TOKEN_DEPTH      = 17.5 * mm;   // Y
TOKEN_HEIGHT     = 6.00 * mm;   // Z

TILE_CENTERS = [
    [ 2, 2 ], [ 6, 2 ], [ 10, 2 ], [ 14, 2 ],
    [ 4, 5 ], [ 8, 5 ], [ 12, 5 ], [ 16, 5 ],
    [ 2, 8 ], [ 6, 8 ], [ 10, 8 ], [ 14, 8 ],
];

include <18XX.scad>;

// ----- Data ------------------------------------------------------------------

tx = TOKEN_WIDTH; ty = TOKEN_DEPTH;

TOKEN_CELLS = [
    [ [ tx, ty ], [ tx, ty ], [ tx, ty ] ],
    [ [ tx, ty ], [ tx, ty ], [ tx, ty ] ],
    [ [ tx, ty ], [ tx, ty ], [ tx, ty ] ]
];

// ----- Functions -------------------------------------------------------------

// ----- Modules ---------------------------------------------------------------

// ----- Rendering -------------------------------------------------------------

if (PART == "tile-tray") {
    hex_tray( FULL_X, HALF_Y, 12*TILE_THICKNESS+STUB, WIDE_WALL );
} else if (PART == "tile-lid") {
    hex_lid( FULL_X, HALF_Y, 4*mm, WIDE_WALL, THIN_WALL, false, true );
} else if (PART == "token-box") {
    cell_box( TOKEN_CELLS, TOKEN_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
} else if (PART == "token-box-lid") {
    cell_lid( TOKEN_CELLS, TOKEN_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
} else {
    // hex_tray( FULL_X, HALF_Y, 12*TILE_THICKNESS+STUB, WIDE_WALL );
    hex_lid( FULL_X, HALF_Y, 4*mm, WIDE_WALL, THIN_WALL, false, true );
}
