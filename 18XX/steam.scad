// Steam / Steam Barons
// by W. Craig Trader
//
// --------------------------------------------------------------------------------------------------------------------
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
// --------------------------------------------------------------------------------------------------------------------

include <../util/units.scad>;

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

include <18XX.scad>;

// ----- Data ------------------------------------------------------------------

// ----- Functions -------------------------------------------------------------

function tray_size( count ) = [TRAY_LENGTH, TRAY_WIDTH, layer_height( count*TILE_THICKNESS ) + 2*mm ];

// ----- Modules ---------------------------------------------------------------

module tile_box( count=6 ) {
    hex_box_2( TILE_CENTERS_4X5, tray_size( count ), TILE_DIAMETER, [ "V2", "STEAM" ] );
}

module tile_lid( count=6 ) {
    hex_lid_2( TILE_CENTERS_4X5, tray_size( count ), TILE_DIAMETER, true, true );
}

// ----- Rendering -------------------------------------------------------------

if (PART == "tile-box") {
    tile_box();
} else if (PART == "tile-lid") {
    tile_lid();
} else {
    translate( [5, 5,0] ) tile_box();
    translate( [5,-5,0] ) tile_lid();
}
