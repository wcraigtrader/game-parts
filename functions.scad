// Utility functions by W. Craig Trader are dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

// ----- Measurements ---------------------------------------------------------

mm = 1.0;                   // single millimeter
cm = 10.0;                  // millimeters in a centimeter
inch = 25.4;                // millimeters in an inch
in = inch;

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

