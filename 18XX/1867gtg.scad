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

BOX_WIDTH       = 294 * mm;    // (X)
BOX_HEIGHT      = 219 * mm;    // (Y)
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

horizontal = [BOX_WIDTH, BOX_HEIGHT, 5*TILE_THICKNESS + 2*mm ];
vertical   = [BOX_HEIGHT, BOX_WIDTH, 5*TILE_THICKNESS + 2*mm ];

if (VERBOSE) {
    echo( TraySize=vertical, inches=vertical/inch );
}

// ----- Modules ------------------------------------------------------------------------------------------------------

module tray_buck( orientation=0 ) {
    layout = hex_tile_uneven_rows( 7, 5 ) ;
    hex_tray_buck( layout, vertical, 43, orientation );
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "buck-full") {
    tray_buck( FULL );
} else if (PART == "buck-upper") {
    tray_buck( UPPER );
} else if ( PART == "buck-lower") {
    tray_buck( LOWER );
} else {
    tray_buck( FULL );
}