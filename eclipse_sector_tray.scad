// Eclipse sector storage tray by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

use <functions.scad>;

// ----- Measurements ---------------------------------------------------------

BOX_WIDTH = 265;        // Maximum length of the final tray
BOX_DEPTH =  85;        // Maximum height of the final tray

HEX_WIDTH  = 105.0;     // Measured long axis, plus slop
HEX_HEIGHT =  90.0;     // Measured short axis, plus slop
HEX_DEPTH  =   2.0;     // Measured thickness, plus slop

ANGLE = 60.0;           // Slot angle, in degrees.

THICKNESS = 2.30;       // Acrylic thickness for 1/8" acrylic

// ----- Calculated Dimensions ------------------------------------------------

TRAY_LENGTH = BOX_WIDTH;
TRAY_HEIGHT = sin( ANGLE ) * (HEX_HEIGHT - 10); // BOX_DEPTH;

SLOT_WIDTH  = THICKNESS;			// 

DIVIDER_HEIGHT = HEX_HEIGHT - 10;		// Full height, less 1 cm
DIVIDER_WIDTH  = HEX_WIDTH + 2*SLOT_WIDTH + 8;	// Hex + 2 slots + outside padding

SLOT_LENGTH = DIVIDER_HEIGHT / 2;               // Half divider height

// ----- Tray Sides -----------------------------------------------------------

module slot() {
	rotate( [ 0,0,-ANGLE ] ) square( [SLOT_LENGTH, SLOT_WIDTH] );
}

// Amount of space N tiles will need
function tile_spacing( n ) = n * HEX_DEPTH / sin( ANGLE );

module tray_side() {

	slot1 = 2;
	slot2 = slot1 + 2 + tile_spacing( 12 ); // (10) GCSD + 9 Homeworlds
	slot3 = slot2 + 2 + tile_spacing( 12 ); // ( 8) Ring 1 sectors
	slot4 = slot3 + 2 + tile_spacing( 12 ); // (12) Ring 2 sectors
	slot5 = slot4 + 2 + tile_spacing( 18 ); // (13) Ring 3 sectors
	slot6 = slot5 + 2 + tile_spacing( 18 ); // (11) special sectors
	slot7 = slot6 + 2 + tile_spacing( 18 ); //      spare

	difference() {
		square( [ TRAY_LENGTH, TRAY_HEIGHT ] );
		translate( [slot1, TRAY_HEIGHT] ) slot();
		translate( [slot2, TRAY_HEIGHT] ) slot();
		translate( [slot3, TRAY_HEIGHT] ) slot();
		translate( [slot4, TRAY_HEIGHT] ) slot();
		translate( [slot5, TRAY_HEIGHT] ) slot();
		translate( [slot6, TRAY_HEIGHT] ) slot();
		translate( [slot7, TRAY_HEIGHT] ) slot();
	}
}

// ----- Tray Dividers --------------------------------------------------------

module tray_divider() {
	difference() {
		square( [ DIVIDER_WIDTH, DIVIDER_HEIGHT ] );
		translate( [4,0,0] ) square( [SLOT_WIDTH, SLOT_LENGTH] );
		translate( [DIVIDER_WIDTH-SLOT_WIDTH-4,0,0] ) square( [SLOT_WIDTH, SLOT_LENGTH] );
	}
}

// ----- Assembled View -------------------------------------------------------

// ----- Cut Parts View -------------------------------------------------------

module cut_parts() {
	ty = TRAY_HEIGHT+2;
	tx = TRAY_LENGTH+2;
	dy = DIVIDER_HEIGHT+2;
	dx = DIVIDER_WIDTH+2;

	place( [0*tx, 0*ty ], 0, "Snow" ) tray_side();
	place( [0*tx, 1*ty ], 0, "Snow" ) tray_side();

	place( [0*tx+0*dx, 2*ty+0*dy ], 0, "Snow" ) tray_divider();
	place( [0*tx+1*dx, 2*ty+0*dy ], 0, "Snow" ) tray_divider();
	place( [0*tx+2*dx, 2*ty+0*dy ], 0, "Snow" ) tray_divider();
	place( [0*tx+0*dx, 2*ty+1*dy ], 0, "Snow" ) tray_divider();
	place( [0*tx+1*dx, 2*ty+1*dy ], 0, "Snow" ) tray_divider();
	place( [0*tx+2*dx, 2*ty+1*dy ], 0, "Snow" ) tray_divider();

	place( [1*tx+0*dx, 2*ty+0*dy-2 ], -90, "Snow" ) tray_divider();

	echo( str( "Cut width   = ", 3*dx-2, "mm" ));
	echo( str( "Cut height  = ", 2*ty+2*dy-2, "mm" ));
	echo( str( "Tray width  = ", DIVIDER_WIDTH, "mm" ));
	echo( str( "Tray length = ", TRAY_LENGTH, "mm" ));
}

// ----------------------------------------------------------------------------
// ----- Rendered Parts -------------------------------------------------------
// ----------------------------------------------------------------------------

cut_parts();
