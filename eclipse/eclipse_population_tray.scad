// Eclipse population storage tray by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

// ----- Measurements ---------------------------------------------------------

HOLE = 9;       // Slightly larger than a wooden block

H_ALIGN = 10.9; // Distance from the left of one hole to the left of the next
V_ALIGN = 12.0; // Distance from the top of one home to the top of the next

H_COUNT = 12;   // Number of horizontal holes
V_COUNT = 3;    // Number of vertical holes

L_BORDER = 2;   // Size of left border
R_BORDER = 2;   // Size of right border
T_BORDER = 2;   // Size of top border
B_BORDER = 4;   // Size of bottom border

H_SIZE = L_BORDER + (H_COUNT-1) * H_ALIGN + HOLE + R_BORDER;
V_SIZE = T_BORDER + (V_COUNT-1) * V_ALIGN + HOLE + B_BORDER;

// ----------------------------------------------------------------------------
// The tray_frame comprises the outer dimensions of the tray
// ----------------------------------------------------------------------------

module tray_frame() {
	square( [H_SIZE, V_SIZE] );
}

// ----------------------------------------------------------------------------
// A tray_column contains all of the holes in a given column 
// ----------------------------------------------------------------------------

module tray_column() {
	for ( v = [0 : V_COUNT-1] ) {
		translate( [0, v*V_ALIGN] ) 
			square( [HOLE, HOLE] );
	}
}

// ----------------------------------------------------------------------------
// The tray_holes comprises all of the holes in the piece
// ----------------------------------------------------------------------------

module tray_holes() {
	for ( h = [0 : H_COUNT-1] ) {
		translate( [L_BORDER + h*H_ALIGN, B_BORDER] )
			tray_column();
	}
}

// ----------------------------------------------------------------------------
// The tray is the frame, less the holes
// ----------------------------------------------------------------------------

module tray() {
	difference() {
		tray_frame();
		tray_holes();
	}
}

// ----------------------------------------------------------------------------
// It's convenient to work with 3 trays at a time
// ----------------------------------------------------------------------------

module three_trays() {
	translate( [0, 2*(V_SIZE + T_BORDER) ] ) tray();
	translate( [0, 1*(V_SIZE + T_BORDER) ] ) tray();
	translate( [0, 0*(V_SIZE + T_BORDER) ] ) tray();
}

module six_trays() {
	translate( [0, 3*(V_SIZE + T_BORDER) ] ) three_trays();
	translate( [0, 0*(V_SIZE + T_BORDER) ] ) three_trays();
}

module nine_trays() {
	translate( [0, 6*(V_SIZE + T_BORDER) ] ) three_trays();
	translate( [0, 3*(V_SIZE + T_BORDER) ] ) three_trays();
	translate( [0, 0*(V_SIZE + T_BORDER) ] ) three_trays();
}

// ----------------------------------------------------------------------------
// ----- Rendered Parts -------------------------------------------------------
// ----------------------------------------------------------------------------

three_trays();
