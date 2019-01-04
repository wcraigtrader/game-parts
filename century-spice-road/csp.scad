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
LIP_HEIGHT    =  3 * mm;
NOTCH_WIDTH   = 15 * mm;

FONT_NAME = "Liberation Serif:style=Italic";
FONT_SIZE = 11.0;

LABELS = [
    [ "Cinnamon", "brown"  ],
    [ "Cardamom", "lime"   ],
    [ "Safran",   "red"    ],
    [ "Turmeric", "yellow" ],
    [ "Saffron",  "red"    ],
];

// ----- Assembly details -----------------------------------------------------

// 3D Printer
LAYER_HEIGHT = 0.20 * mm;
THIN_WALL    = 0.86 * mm;  	// Based on 0.20mm layer height
WIDE_WALL    = 1.67 * mm;  	// Based on 0.20mm layer height

THICK = false;
THIN  = true;

BOTTOM = 2 * mm;
LID    = 2 * mm;
OUTER  = WIDE_WALL;
SPACE  = 1 * mm;

GAP = THIN_WALL/4;
SEP = 2 * mm;
OVERLAP = 0.01 * mm; // Ensures that there are no vertical artifacts leftover

$fn=180;             // Fine-grained corners

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

module bowl_names(name) {
    thickness = LID/2;
    translate( [0,0,thickness/2] )
        linear_extrude( height=thickness+OVERLAP, center=true ) 
            label(name);
}

module bowl_lid(name="", thin=false) {
    thickness = thin ? (LID/2) : LID;

    INNER_HEIGHT = LIP_HEIGHT;
    OUTER_HEIGHT = INNER_HEIGHT + thickness;
    
    notchx = OUTER_DIAMETER + 2*OVERLAP;
    notchy = NOTCH_WIDTH;
    
    difference() {
        cylinder( d=OUTER_DIAMETER, h=OUTER_HEIGHT );
        
        translate( [0,0,thickness] ) 
            cylinder( d1=INNER_DIAMETER, d2=INNER_DIAMETER-2*GAP, h=OUTER_HEIGHT );
        
        for (angle=[0,45,90,135]) {
            rotate( [0,0,angle] )
                translate( [-notchx/2, -notchy/2, thickness] )
                    cube( [notchx,notchy,OUTER_HEIGHT] );
        }
        
        if (name != "") {
            bowl_names( name );
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
    
    for( i = [0:len( LABELS )-1] ) {
        x = floor( i/2 );
        y = i%2;
        place( [x*dx,y*dy,0], 0, "white" ) bowl_lid( LABELS[i][0], true );
        place( [x*dx,y*dy,0], 0, LABELS[i][1] ) bowl_names( LABELS[i][0] );
    }
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
    bowl_lid("", THICK);
} else if (PART == "lid-thin") {
    bowl_lid("", THIN);

} else if (PART == "lid-cinnamon") {
    bowl_lid("Cinnamon", THICK);
} else if (PART == "lid-cardamom") {
    bowl_lid("Cardamom", THICK);
} else if (PART == "lid-safran") {
    bowl_lid("Safran", THICK);
} else if (PART == "lid-turmeric") {
    bowl_lid("Turmeric", THICK);
} else if (PART == "lid-saffron") {
    bowl_lid("Saffron", THICK);

} else if (PART == "multi-cinnamon") {
    bowl_lid("Cinnamon", THIN);
} else if (PART == "multi-cardamom") {
    bowl_lid("Cardamom", THIN);
} else if (PART == "multi-safran") {
    bowl_lid("Safran", THIN);
} else if (PART == "multi-turmeric") {
    bowl_lid("Turmeric", THIN);
} else if (PART == "multi-saffron") {
    bowl_lid("Saffron", THIN);

} else if (PART == "names-cinnamon") {
    bowl_names("Cinnamon");
} else if (PART == "names-cardamom") {
    bowl_names("Cardamom");
} else if (PART == "names-safran") {
    bowl_names("Safran");
} else if (PART == "names-turmeric") {
    bowl_names("Turmeric");
} else if (PART == "names-saffron") {
    bowl_names("Saffron");

} else {
   // bowl_plate_with_names();
    bowl_lid("", THIN);
}
