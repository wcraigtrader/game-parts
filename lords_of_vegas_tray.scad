// Lords of Vegas PART tray 
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <functions.scad>;

// ----- Measurements ---------------------------------------------------------

THICKNESS = 3.00;		// 1/8" plywood
// THICKNESS = 2.25;     // Acrylic thickness for 3/32" acrylic
// THICKNESS = 2.80;	    // Cardboard

PADDING = 3.0;

BOX_HEIGHT = 290.0;
BOX_LENGTH = 290.0;

TRAY_DEPTH = 54.0;

TILE_SIZE      = 45.0;
TILE_HOLE      = 16.5;
TILE_THICKNESS = 1/8 * inch;
TILE_STACK     = 10 * TILE_THICKNESS;
FULL_STACK     = 50 * TILE_THICKNESS + 12.5;

DECK_WIDTH     = 88.0;
DECK_HEIGHT    = 63.0;
DECK_THICKNESS = 13.0;

MONEY_WIDTH     = 100.0;
MONEY_HEIGHT    = 50.0;
MONEY_THICKNESS = 8.0 * 2;

PART_WIDTH     = 80.0;
PART_HEIGHT    = 60.0;
PART_THICKNESS = 45.0; 

BOARD_LENGTH    = 280.0;
BOARD_HEIGHT    = 280.0;
BOARD_THICKNESS = 9.0;

COLOR1 = "LightBlue";
COLOR2 = "LightGreen";

// ----- Calculated sizes -----------------------------------------------------

PARTS_WIDTH  = max( FULL_STACK, DECK_WIDTH, MONEY_WIDTH ) + PADDING;
PARTS_OFFSET = PARTS_WIDTH + THICKNESS;

echo( str( "PARTS_OFFSET  = ", PARTS_OFFSET, " mm" ) );

FINGER_WIDTH = THICKNESS;
FINGER_HEIGHT = TRAY_DEPTH / 9;
FINGER_OFFSET = FINGER_HEIGHT * 2;
FINGER_PADDING = 2.0;

echo( str( "FINGER_WIDTH  = ", FINGER_WIDTH, " mm" ) );
echo( str( "FINGER_HEIGHT = ", FINGER_HEIGHT, " mm" ) );
echo( str( "FINGER_OFFSET = ", FINGER_OFFSET, " mm" ) );

DIV0 = 0;
DIV2 = ( BOX_HEIGHT - 2*THICKNESS ) / 2 + THICKNESS;
DIV1 = DIV2 - (TILE_SIZE + THICKNESS + PADDING);
DIV3 = DIV2 + (TILE_SIZE + THICKNESS + PADDING);
DIV4 = BOX_HEIGHT - THICKNESS;

// ----- Tray Pieces ----------------------------------------------------------

module vertical_holes() {
	for( i=[0:3] ) {
		translate( [-hepsilon,i*FINGER_OFFSET+FINGER_HEIGHT-hepsilon,0] )
			square( [FINGER_WIDTH+epsilon,FINGER_HEIGHT+epsilon] );
	}
}

module horizontal_holes() {
	for( i=[0:4] ) {
		translate( [-hepsilon,i*FINGER_OFFSET-hepsilon,0] )
			square( [FINGER_WIDTH+epsilon,FINGER_HEIGHT+epsilon] );
	}
}

module finger_inner() {
	translate( [-FINGER_PADDING,-FINGER_PADDING,0] )
		difference() {
			square( [FINGER_WIDTH+FINGER_PADDING, TRAY_DEPTH+2*FINGER_PADDING] );
			translate( [FINGER_PADDING,FINGER_PADDING,0] )
				for( i=[0:3] ) {
					translate( [epsilon,i*FINGER_OFFSET+FINGER_HEIGHT+hepsilon,0] )
						square( [FINGER_WIDTH-epsilon,FINGER_HEIGHT-epsilon] );
				}
		}
}

module finger_outer() {
	translate( [-FINGER_PADDING,-FINGER_PADDING,0] )
		difference() {
			square( [FINGER_WIDTH+FINGER_PADDING, TRAY_DEPTH+2*FINGER_PADDING] );
			translate( [FINGER_PADDING,FINGER_PADDING,0] )
				for( i=[0:4] ) {
					translate( [0,i*FINGER_OFFSET,0] )
						square( [FINGER_WIDTH,FINGER_HEIGHT] );
				}
		}
}

module vertical( notches ) {
	difference() {
		square( [ BOX_HEIGHT, TRAY_DEPTH ] );

		translate( [0,0,0] )
			finger_outer();

		translate( [BOX_HEIGHT,0,0] )
			mirror( [1,0,0] )
				finger_outer();

		if ( notches ) {
			translate( [DIV1,0,0] )
				vertical_holes();
			translate( [DIV2,0,0] )
				vertical_holes();
			translate( [DIV3,0,0] )
				vertical_holes();
		}
	}
}

module horizontal() {
	difference() {
		square( [ BOX_HEIGHT, TRAY_DEPTH ] );

		translate( [0,0,0] )
			finger_inner();
		translate( [BOX_HEIGHT,0,0] )
			mirror( [1,0,0] )
				finger_inner();
		translate( [PARTS_OFFSET,0,0] )
			horizontal_holes();
	}
}

module divider() {
	difference() {
		square( [ PARTS_WIDTH + 2 * THICKNESS, TRAY_DEPTH ] );
		translate( [0,0,0] )
			finger_inner();
		translate( [PARTS_WIDTH + 2 * THICKNESS,0,0] )
			mirror( [1,0,0] )
				finger_inner();
	}
}

// ----- Mocks ----------------------------------------------------------------

module money_mock( hue="orange" ) {
	color( hue ) 
		cube( [MONEY_WIDTH, MONEY_HEIGHT, MONEY_THICKNESS] );
}

module deck_mock( hue="purple" ) {
	color( hue ) 
		cube( [DECK_WIDTH, DECK_HEIGHT, DECK_THICKNESS] );
}

module part_mock( hue="black" ) {
	color( hue )
		cube( [PART_WIDTH, PART_HEIGHT, PART_THICKNESS] );
}

module tile_mock( hue="black" ) {
	offset = ( TILE_SIZE - TILE_HOLE ) / 2;

	color( hue ) difference() {
		cube( [TILE_SIZE, TILE_SIZE, TILE_STACK] );
		translate( [offset, offset, -epsilon/2] )
			cube( [TILE_HOLE, TILE_HOLE, TILE_STACK + epsilon] );
	}
}

module stack_mock( hue="blue" ) {
	offset = ( TILE_SIZE - TILE_HOLE ) / 2;

	color( hue ) difference() {
		cube( [FULL_STACK, TILE_SIZE, TILE_SIZE] );
		translate( [-epsilon/2, offset, offset ] )
			cube( [FULL_STACK+epsilon, TILE_HOLE, TILE_HOLE] );
	}
}

module board_mock( hue="black" ) {
	color( hue ) 
		cube( [BOARD_LENGTH, BOARD_HEIGHT, BOARD_THICKNESS] );
}

// ----- Assembled View -------------------------------------------------------

module assembled_view() {

	union() {
		// Left
 		color( COLOR1 )
		translate( [0,DIV0,0] )
			rotate( a=[+90,0,+90] )
				linear_extrude( height=THICKNESS )
					vertical( true );

		// Middle
		color( COLOR1 )
		translate( [PARTS_OFFSET,DIV0,0] )
			rotate( a=[+90,0,+90] )
				linear_extrude( height=THICKNESS )
					vertical( true );

		// Right
		color( COLOR1 )
		translate( [BOX_LENGTH-THICKNESS,DIV0,0] )
			rotate( a=[+90,0,+90] )
				linear_extrude( height=THICKNESS )
					vertical( false );

		// Bottom
		color( COLOR2 )
		translate( [0,DIV0+THICKNESS,0] )
			rotate( a=[+90,0,0] )
				linear_extrude( height=THICKNESS )
					horizontal();

		// Divider 1
		color( COLOR2 )
		translate( [0,DIV1+THICKNESS,0] )
			rotate( a=[+90,0,0] )
				linear_extrude( height=THICKNESS )
					divider();

		// Divider 2
		color( COLOR2 )
		translate( [0,DIV2+THICKNESS,0] )
			rotate( a=[+90,0,0] )
				linear_extrude( height=THICKNESS )
					divider();

		// Divider 3
		color( COLOR2 )
		translate( [0,DIV3+THICKNESS,0] )
			rotate( a=[+90,0,0] )
				linear_extrude( height=THICKNESS )
					divider();

		// Top
		color( COLOR2 )
		translate( [0,DIV4+THICKNESS,0] )
			rotate( a=[+90,0,0] )
				linear_extrude( height=THICKNESS )
					horizontal();

		// Mocks
		if ( false ) {
		translate( [THICKNESS+PADDING/2,DIV0+THICKNESS+PADDING/2,0] ) 
			money_mock();
		translate( [THICKNESS+PADDING/2,DIV1+THICKNESS+PADDING/2,0] ) 
			stack_mock();
		translate( [THICKNESS+PADDING/2,DIV2+THICKNESS+PADDING/2,0] ) 
			stack_mock();
		translate( [THICKNESS+PADDING/2,DIV3+THICKNESS+PADDING/2,0] ) 
			deck_mock();
		for (i=[0:3]) 
			translate( [PARTS_OFFSET+THICKNESS+PADDING,THICKNESS+PADDING+i*(PART_HEIGHT+PADDING),0] ) 
				part_mock();
		}
	}
}

// ----- Cut Parts View -------------------------------------------------------

module cut_parts_1() {
	spacing = 2.0;

	dx = BOX_LENGTH + spacing;
	dy = TRAY_DEPTH + spacing;

	place( [0*dx,0*dy], 0, COLOR1 ) vertical( false );
	place( [0*dx,1*dy], 0, COLOR1 ) vertical( true );
	place( [0*dx,2*dy], 0, COLOR1 ) vertical( true );

	place( [0*dx,3*dy], 0, COLOR2 ) horizontal();
	place( [0*dx,4*dy], 0, COLOR2 ) horizontal();

	place( [0*dx,5*dy], 0, COLOR2 ) divider();
	place( [0*dx,6*dy], 0, COLOR2 ) divider();
	place( [0*dx,7*dy], 0, COLOR2 ) divider();

	cut_length = BOX_LENGTH;
	cut_height = 8*dy - spacing;

	echo( str( "Cut length  = ", cut_length/inch, " in" ) );
	echo( str( "Cut height  = ", cut_height/inch, " in" ) );
}

// ----- Cut Parts View -------------------------------------------------------

module cut_parts_2() {
	spacing = 2.0;

	dx = BOX_LENGTH + spacing;
	dy = TRAY_DEPTH + spacing;

	place( [0*dx,0*dy], 0, COLOR1 ) vertical( false );
	place( [0*dx,1*dy], 0, COLOR1 ) vertical( true );
	place( [0*dx,2*dy], 0, COLOR1 ) vertical( true );

	place( [0*dx,3*dy], 0, COLOR2 ) horizontal();
	place( [0*dx,4*dy], 0, COLOR2 ) horizontal();

	place( [1*dx,0*dy], 0, COLOR2 ) divider();
	place( [1*dx,1*dy], 0, COLOR2 ) divider();
	place( [1*dx,2*dy], 0, COLOR2 ) divider();

	cut_length = BOX_LENGTH + spacing + PARTS_WIDTH + 2*THICKNESS;
	cut_height = 5*dy - spacing;

	echo( str( "Cut length  = ", cut_length/inch, " in" ) );
	echo( str( "Cut height  = ", cut_height/inch, " in" ) );
}

// ----------------------------------------------------------------------------
// ----- Rendered PART -------------------------------------------------------
// ----------------------------------------------------------------------------

// assembled_view();
cut_parts_1();