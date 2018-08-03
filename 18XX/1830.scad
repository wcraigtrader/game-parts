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
PART_WIDTH      = 40; // 1.25 * inch;  // X
PART_DEPTH      = 20; // 0.75 * inch;  // Y
PART_HEIGHT     = 6.00 * mm;    // Z

include <18XX.scad>;

// ----- Data ------------------------------------------------------------------

px = PART_WIDTH; py = PART_DEPTH;

PART_CELLS = [
    [ [ px, py ], [ px, py ], [ px, py ] ],
    [ [ px, py ], [ px, py ], [ px, py ] ],
    [ [ px, py ], [ px, py ], [ px, py ] ]
];

// ----- Functions -------------------------------------------------------------

// ----- Modules ---------------------------------------------------------------

// ----- Rendering -------------------------------------------------------------

if (PART == "tile-tray") {
    hex_tray( FULL_X, HALF_Y, 12*TILE_THICKNESS, WIDE_WALL );
} else if (PART == "tile-lid") {
    hex_lid( FULL_X, HALF_Y, 4*mm, WIDE_WALL, THIN_WALL, false );
} else if (PART == "part-box") {
    cell_box( PART_CELLS, PART_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
} else if (PART == "part-box-lid") {
    cell_lid( PART_CELLS, PART_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
} else {
    cell_box( PART_CELLS, PART_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
    translate( [0, 70, 0] )
    cell_lid( PART_CELLS, PART_HEIGHT, BOTTOM, TOP, THIN_WALL, THIN_WALL );
}
