// Century: Spice Road Organizer
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.
//
// ----------------------------------------------------------------------------

include <MCAD/units.scad>;

// ----- Command Line Arguments -----------------------------------------------

PART = "other";     // Which part to output
VERBOSE = true;     // Set to true to see more data

// ----- Component measurements -----------------------------------------------

BOWL_DIAMETER = 68 * mm;
LIP_HEIGHT    =  5 * mm;
NOTCH_WIDTH   = 15 * mm;

FONT_NAME = "Liberation Serif:style=Italic";
FONT_SIZE = 11.0;

// ----- Assembly details -----------------------------------------------------

FILAMENT = 0.8 * mm; // Thickness of a line of filament

BOTTOM = 2 * mm;
LID    = 2 * mm;
OUTER  = 2.5 * FILAMENT;
INNER  = 2.5 * FILAMENT;
SPACE  = 1 * mm;

GAP = FILAMENT/4;
SEP = 2 * mm;
OVERLAP = 0.1 * mm; // Ensures that there are no vertical artifacts leftover

$fn=90;             // Fine-grained corners

// ----- Calculated Measurements ----------------------------------------------

INNER_DIAMETER = BOWL_DIAMETER;
OUTER_DIAMETER = INNER_DIAMETER + 2 * OUTER;

// ----- Sub-Components -------------------------------------------------------

module dummy() {
    cube([100,100,1]);
}

module label(message) {
    mirror( [0,1,0] )
        text( message, font=FONT_NAME, size=FONT_SIZE, halign="center", valign="center" );
}

// ----- Components -----------------------------------------------------------

module bowl_lid(name="", thin=false) {
    thickness = thin ? (LID/2) : LID;

    INNER_HEIGHT = LIP_HEIGHT;
    OUTER_HEIGHT = INNER_HEIGHT + thickness;
    
    notchx = OUTER_DIAMETER + 2*OVERLAP;
    notchy = NOTCH_WIDTH;
    
    difference() {
        cylinder( d=OUTER_DIAMETER, h=OUTER_HEIGHT );
        translate( [0,0,thickness] ) 
            cylinder( d1=INNER_DIAMETER, d2=INNER_DIAMETER, h=OUTER_HEIGHT );
        
        for (angle=[-60,0,60]) {
            rotate( [0,0,angle] )
                translate( [-notchx/2, -notchy/2, thickness] )
                    cube( [notchx,notchy,OUTER_HEIGHT] );
        }
        
        if (name != "" && !thin) {
#            linear_extrude( height=LID, center=true ) 
                label(name);
        }
    }
}

// ----- Plated arrangements for long prints ----------------------------------

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

module bowl_plate(thin=false) {
    dx = OUTER_DIAMETER + 5 * mm;
    dy = OUTER_DIAMETER + 5 * mm;

    place( [0*dx,0*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [1*dx,0*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [0*dx,1*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [1*dx,1*dy,0], 0, "gray" ) bowl_lid( thin=thin );
}

module bowl_plate_with_names() {
    dx = OUTER_DIAMETER + 5 * mm;
    dy = OUTER_DIAMETER + 5 * mm;
    
    place( [0*dx,0*dy,0], 0, "brown" ) bowl_lid("Cinnamon");
    place( [1*dx,0*dy,0], 0, "green" ) bowl_lid("Cardamon");
    place( [0*dx,1*dy,0], 0, "red" ) bowl_lid("Safran");
    place( [1*dx,1*dy,0], 0, "yellow" ) bowl_lid("Tumeric");
}

module big_bowl_plate(thin=true) {
    dx = (OUTER_DIAMETER + 3 * mm) / 4;
    dy = (OUTER_DIAMETER + 3 * mm) / 3 * sin(60);

    place( [ 2*dx,2*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [ 6*dx,2*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [10*dx,2*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [ 4*dx,5*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [ 8*dx,5*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [ 2*dx,8*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [ 6*dx,8*dy,0], 0, "gray" ) bowl_lid( thin=thin );
    place( [10*dx,8*dy,0], 0, "gray" ) bowl_lid( thin=thin );
}

// ----- Render Logic for makefile --------------------------------------------

if (VERBOSE) {
	echo (Part=PART);
}

if (PART == "lid-thick") {
    bowl_lid();
} else if (PART == "lid-thin") {
    bowl_lid(thin=true);
} else if (PART == "lid-cinnamon") {
    bowl_lid("Cinnamon");
} else if (PART == "lid-cardamom") {
    bowl_lid("Cardamom");
} else if (PART == "lid-safran") {
    bowl_lid("Safran");
} else if (PART == "lid-turmeric") {
    bowl_lid("Turmeric");
} else if (PART == "named-plate") {
    bowl_plate_with_names();
} else if (PART == "thick-blank-plate") {
    bowl_plate();
} else if (PART == "thin-blank-plate") {
    bowl_plate(thin=true);
} else if (PART == "big-thin-plate") {
    big_bowl_plate();
} else {
    big_bowl_plate();
}
