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
TIMESTAMP = "2020-03-07T00:03"; // "yyyy-mm-ddThh:mm";

include <18XX.scad>;

// Game box dimensions

BOX_WIDTH       = 294 * mm;    // (X)
BOX_HEIGHT      = 219 * mm;    // (Y)  219 * mm
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
auto_fit   = [0, 0, 5*TILE_THICKNESS + TILE_EXTRA];

layout1  = hex_tile_even_rows( 1, 1 );
layout5  = hex_tile_uneven_rows( 3, 2 );
layout8  = hex_tile_uneven_rows( 3, 3 );
layout25 = hex_tile_even_rows( 5, 5 );
layout28 = hex_tile_uneven_rows( 5, 6 );
layout30 = hex_tile_even_rows( 5, 6 );
layout32 = hex_tile_uneven_rows( 7, 5 ) ;

// ----- Modules ------------------------------------------------------------------------------------------------------

module buck( wells=32, orientation=FULL, test=false, dimensions=STYRENE_30MIL ) {
    if (wells == 1) {
        hex_tray_buck( layout1, auto_fit, TILE_DIAMETER, orientation, test, dimensions );
    } else if (wells == 5) {
        hex_tray_buck( layout5, auto_fit, TILE_DIAMETER, orientation, test, dimensions );
    } else if (wells == 8) {
        hex_tray_buck( layout8, auto_fit, TILE_DIAMETER, orientation, test, dimensions );
    } else if (wells == 28) {
        hex_tray_buck( layout28, auto_fit, TILE_DIAMETER, orientation, test, dimensions );
    } else if (wells == 30) {
        hex_tray_buck( layout30, auto_fit, TILE_DIAMETER, orientation, test, dimensions );
    } else if (wells == 32) {
        hex_tray_buck( layout32, auto_fit, TILE_DIAMETER, orientation, test, dimensions );
    } else {
        hex_tray_buck( layout0, auto_fit, TILE_DIAMETER, orientation, test, dimensions );
    }
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "buck-28-full") {
    buck( 28, FULL );
} else if (PART == "buck-28-left") {
    buck( 28, LEFT );
} else if (PART == "buck-28-right") {
    buck( 28, RIGHT );
} else if (PART == "buck-30-full") {
    buck( 30, FULL );
} else if (PART == "buck-30-left") {
    buck( 30, LEFT );
} else if (PART == "buck-30-right") {
    buck( 30, RIGHT );
} else if (PART == "buck-32-full") {
    buck( 32, FULL );
} else if (PART == "buck-32-upper") {
    buck( 32, UPPER );
} else if (PART == "buck-32-lower") {
    buck( 32, LOWER );
} else {
    // buck( 28, LEFT );
    // translate( [2,0,0] ) buck( 28, RIGHT );

    // buck( 0, LOWER );
    // translate( [0,2,0] ) buck( 0, UPPER );

    // rotate( [0,0,90] ) buck( 0 );

    buck( 1, FULL, false );
    // translate( [0, 0, 0] ) buck( 8, LOWER, false );
    // translate( [0, 2, 0] ) buck( 8, UPPER, false );

    // difference() {
    //     minkowski() {
    //         buck( 1, FULL );
    //         sphere( d=0.030*inch );
    //     }
    //     buck( 1, FULL );
    // }
}