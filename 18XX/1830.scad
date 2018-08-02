// 1830: The Game of Railroads and Robber Barons
//
// by W. Craig Trader is dual-licensed under
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = 1;        	// Set to non-zero to see more data

// Box dimensions
BOX_HEIGHT      = 11.125 * inch;
BOX_WIDTH       =  8.0 * inch;
BOX_DEPTH       =  2.0 * inch;

// Tile dimensions
TILE_DIAMETER   = 46.0 * mm;
TILE_THICKNESS  =  0.5 * mm;
POKE_HOLE       = 35.0 * mm;    // Diameter of poke holes in bottom

include <18XX.scad>;

// ----- Rendering -------------------------------------------------------------

if (PART == "tile-tray") {
    fine_hex_tray( FULL_X, HALF_Y, 10*TILE_THICKNESS, WIDE_WALL );
} else if (PART == "tile-lid") {
    fine_hex_lid( FULL_X, HALF_Y, 4*mm, WIDE_WALL, THIN_WALL, false );
} else {
    fine_hex_tray( FULL_X, HALF_Y, 10*TILE_THICKNESS, WIDE_WALL );
    translate( [0,150,0] ) 
    fine_hex_lid( FULL_X, HALF_Y, 4*mm, WIDE_WALL, THIN_WALL, false );
}
