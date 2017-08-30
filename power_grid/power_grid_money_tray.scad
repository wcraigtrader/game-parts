// Power Grid money storage tray 
// Implementation by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.
//
// From a design by Laura Young.

include <MCAD/units.scad>;

// ----- Measurements ---------------------------------------------------------

THICKNESS = 2.25;           // Acrylic thickness for 3/32" acrylic
// THICKNESS = 2.80;	           // Cardboard

SECTIONS = 4;

BILL_LENGTH   = 90.0;       // Power Grid money size
BILL_WIDTH    = 45.0;       // Power Grid money size

BILL_HEIGHT   = 25.0;       // Vertical space for money in the tray
BILL_PADDING  = 5.0;        // Padding around the money in the tray
BILL_OVERHANG = 3.0;        // Amount that bills should extend beyond the tray

SIDE_PADDING  = 3.0;        // Padding to left and right of outer dividers
BACK_PADDING  = 3.0;        // Padding to back of back wall
BASE_PADDING  = 3.0;        // Padding under base

// ----- Calculated Dimensions ------------------------------------------------

SECTION_WIDTH = BILL_WIDTH + BILL_PADDING; 
SECTION_DEPTH = BILL_LENGTH - BILL_OVERHANG;

SLOT_WIDTH = THICKNESS;

BASE_LENGTH = SECTIONS * ( SECTION_WIDTH + SLOT_WIDTH ) + SLOT_WIDTH + 2 * SIDE_PADDING;
BASE_HEIGHT = SECTION_DEPTH + SLOT_WIDTH + BACK_PADDING;

DIVIDER_HEIGHT = BASE_HEIGHT;
DIVIDER_LENGTH = BILL_HEIGHT + SLOT_WIDTH + BASE_PADDING;

BACK_LENGTH = BASE_LENGTH;
BACK_HEIGHT = DIVIDER_LENGTH - SLOT_WIDTH - BASE_PADDING;

BASE_SLOT = BASE_HEIGHT / 2;
BACK_SLOT = BACK_HEIGHT / 2;
TAB_SLOT  = SECTION_WIDTH / 2;

epsilon = 0.02;             // padding for slots
hepsilon = epsilon / 2;

// ----- Place a part via translation and rotation ----------------------------

module place( translation=[0,0,0], angle=0, hue="" ) {
	for (i = [0 : $children-1]) {
		translate( translation ) 
			rotate( a=angle ) 
				if ( hue != "" ) {
					color( hue ) children(i);
				} else {
					children(i);
				}
	}
}

// ----- Create a straight slot in a piece, with a hairsbreadth of space for fit

module straight_slot( width, height ) {

	translate( [-hepsilon, -hepsilon, 0 ] )
		square( [ width+epsilon, height+epsilon ] );
}

// ----- Tray Base ------------------------------------------------------------

module tray_base() {
	difference() {
		// base plate
		square( [ BASE_LENGTH, BASE_HEIGHT ] );

		// remove the material for the side slots
		for ( i=[0:SECTIONS] ) {
			translate( [SIDE_PADDING + i*(SECTION_WIDTH + SLOT_WIDTH),BASE_HEIGHT-BASE_SLOT,0] )
				straight_slot( SLOT_WIDTH, BASE_SLOT );
		}

		// remove the material for the tab slots
		for (i=[0:SECTIONS-1] ) {
			translate( [
					SIDE_PADDING+SLOT_WIDTH+(SECTION_WIDTH/4)+i*(SECTION_WIDTH+SLOT_WIDTH),
					BASE_HEIGHT-BACK_PADDING-SLOT_WIDTH,0] )
				straight_slot( TAB_SLOT, SLOT_WIDTH );
				
		}
	}
}

// ----- Tray Back ------------------------------------------------------------

module tray_back() {
	difference() {
		union() {
			// back plate
			translate( [0,BASE_PADDING+SLOT_WIDTH,0] )
				square( [ BACK_LENGTH, BACK_HEIGHT ] );

			// add the tabs
			for (i=[0:SECTIONS-1] ) {
				translate( [SIDE_PADDING+SLOT_WIDTH+(SECTION_WIDTH/4)+i*(SECTION_WIDTH+SLOT_WIDTH),0,0] ) 
					square( TAB_SLOT, BASE_PADDING+SLOT_WIDTH );
			}
		}

		// remove the material for the slots
		for (i=[0:SECTIONS] ) {
			translate( [SIDE_PADDING+i*(SECTION_WIDTH+SLOT_WIDTH),BASE_PADDING+SLOT_WIDTH,0] )
				straight_slot( SLOT_WIDTH, BACK_SLOT );
		}

	}
}

// ----- Tray Dividers --------------------------------------------------------

module tray_divider() {
	difference() {
		// divider
		square( [ DIVIDER_LENGTH, DIVIDER_HEIGHT ] );

		// remove the material for the base slot
		translate( [BASE_PADDING,0,0] )
			straight_slot( SLOT_WIDTH, BASE_SLOT );

		// remove the material for the back slot
		translate( [DIVIDER_LENGTH-BACK_SLOT,DIVIDER_HEIGHT-BACK_PADDING-SLOT_WIDTH,0] )
			straight_slot( BACK_SLOT, SLOT_WIDTH );
	}
}

// ----- Assembled View -------------------------------------------------------

module assembled_view() {

	union() {
		color( "Blue" )
		translate([0,0, BASE_PADDING ]) 
			linear_extrude( height=THICKNESS )
				tray_base();

		color( "Green" )
		translate( [0,BASE_HEIGHT-BACK_PADDING,0] )
			rotate( a=[+90,0,0] )
				linear_extrude( height=THICKNESS )
					tray_back();

		color( "Red" ) 
		for (i=[0:SECTIONS] ) {
			translate( [SIDE_PADDING+i*(SECTION_WIDTH+SLOT_WIDTH)+SLOT_WIDTH,0,0] )
				rotate( a=[0,-90,0] )
					linear_extrude( height=THICKNESS )
						tray_divider();
		}

		color( "Orange" )
		for (i=[0:SECTIONS-1] ) {
			translate( [SIDE_PADDING+i*(SECTION_WIDTH+SLOT_WIDTH)+SLOT_WIDTH+BILL_PADDING/2,-BILL_OVERHANG,BASE_PADDING+SLOT_WIDTH ] )
				cube( [BILL_WIDTH, BILL_LENGTH, 6 ] );
		}
	}
}

// ----- Cut Parts View -------------------------------------------------------

module cut_parts() {
	spacing = 2.0;

	ax = BASE_LENGTH + spacing;
	ay = BASE_HEIGHT + spacing;

	bx = BACK_LENGTH + spacing;
	by = BACK_HEIGHT + BASE_PADDING + SLOT_WIDTH + spacing;

	cx = DIVIDER_LENGTH + spacing;
	cy = DIVIDER_HEIGHT + spacing;

	place( [0,0], 0, "Blue" ) tray_base();
	place( [0,ay], 0, "Green" ) tray_back();

	for (i=[0:SECTIONS] ) {
		place( [i*cx, ay+by], 0, "Red" ) tray_divider();
	}

	cut_length = max( ax, (SECTIONS+1)*cx )-spacing;
	cut_height = ay+by+cy-spacing;

	echo( str( "Cut length  = ", cut_length/inch, " in" ) );
	echo( str( "Cut height  = ", cut_height/inch, " in" ) );
}

module dimensions() {
	echo( str( "Assembled length = ", BASE_LENGTH/inch, " in" ) );
	echo( str( "Assembled heigth = ", DIVIDER_LENGTH/inch, " in" ) );
	echo( str( "Assembled depth  = ", BASE_HEIGHT/inch, " in" ) );
}

// ----------------------------------------------------------------------------
// ----- Rendered Parts -------------------------------------------------------
// ----------------------------------------------------------------------------

dimensions();
if ( 0 ) {
	assembled_view();
} else {
	cut_parts();
}
