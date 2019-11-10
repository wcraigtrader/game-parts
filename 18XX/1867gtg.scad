/* 1867: The Railways of Canada (Grand Trumk Games)
 * by W. Craig Trader
 *
 * --------------------------------------------------------------------------------------------------------------------
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
 * or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
 *
 * -------------------------------------------------------------------------------------------------------------------- */

// Command Line Arguments
PART = "other";         // Which part to output
VERBOSE = true;        	// Set to non-zero to see more data

include <18XX.scad>;

// Game box dimensions

BOX_WIDTH       = 290 * mm;    // (X)
BOX_HEIGHT      = 215 * mm;    // (Y)
BOX_DEPTH       =  80 * mm;    // (Z)

// Tokens
TOKEN_DIAMETER  = 14.0 * mm;
TOKEN_HEIGHT    =  5.0 * mm;

// Cards
CARD_WIDTH      = 2.500 * inch;
CARD_HEIGHT     = 1.625 * inch;
CARD_THICKNESS  = 5.000 * mm;

LOAN_SIZE       = 1.125 * inch;
LOAN_THICKNESS  = 8.000 * mm;

// Tile dimensions
TILE_DIAMETER   = 43.00 * mm;
TILE_THICKNESS  =  2.00 * mm;

// ----- Data ---------------------------------------------------------------------------------------------------------

tray_size = [BOX_WIDTH, BOX_HEIGHT, 5*TILE_THICKNESS + 2*mm ];

if (VERBOSE) {
    echo( TraySize=tray_size, inches=tray_size/inch );
}

// ----- Modules ------------------------------------------------------------------------------------------------------

module tray_buck() {
    layout = hex_tile_even_rows( 5, 6 ) ;
    hex_tray_buck( layout, tray_size, 43, false );
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "empty") {
} else {
    tray_buck();
}
