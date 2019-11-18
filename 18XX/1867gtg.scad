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
TILE_DIAMETER   = 1.50 * inch / sin( 60 );
TILE_THICKNESS  =  2.00 * mm;
TILE_EXTRA      =  2.00 * mm;

// ----- Data ---------------------------------------------------------------------------------------------------------

horizontal = [BOX_WIDTH, BOX_HEIGHT, 5*TILE_THICKNESS + TILE_EXTRA ];
vertical   = [BOX_HEIGHT, BOX_WIDTH, 5*TILE_THICKNESS + TILE_EXTRA ];

layout28 = hex_tile_uneven_rows( 5, 6 );
layout30 = hex_tile_even_rows( 5, 6 );
layout32 = hex_tile_uneven_rows( 7, 5 ) ;

if (VERBOSE) {
    echo( TraySize=vertical, inches=vertical/inch );
}

// ----- Modules ------------------------------------------------------------------------------------------------------

module buck( wells=32, orientation=FULL ) {
    if (wells == 28) {
        hex_tray_buck( layout28, horizontal, TILE_DIAMETER, orientation );
    } else if (wells == 30) {
        hex_tray_buck( layout30, horizontal, TILE_DIAMETER, orientation );
    } else if (wells == 32) {
        hex_tray_buck( layout32, vertical, TILE_DIAMETER, orientation );
    }
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "buck-28-full") {
    buck( 28, FULL );
} else if (PART == "buck-28-upper") {
    buck( 28, UPPER );
} else if (PART == "buck-28-lower") {
    buck( 28, LOWER );
} else if (PART == "buck-30-full") {
    buck( 30, FULL );
} else if (PART == "buck-30-upper") {
    buck( 30, UPPER );
} else if (PART == "buck-30-lower") {
    buck( 30, LOWER );
} else if (PART == "buck-32-full") {
    buck( 32, FULL );
} else if (PART == "buck-32-upper") {
    buck( 32, UPPER );
} else if (PART == "buck-32-lower") {
    buck( 32, LOWER );
} else {
    buck( 28, FULL );
}