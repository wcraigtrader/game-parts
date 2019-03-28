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
BOWL_FRAGMENTS = 180;

FONT_NAME = "Liberation Serif:style=Italic";
FONT_SIZE = 11.0;

LABELS = [
    [ "Cloves",   "brown"  ],
    [ "Tea",      "lime"   ],
    [ "Chili",    "red"    ],
    [ "Ginger",   "yellow" ],

    [ "Cinnamon", "brown"  ],
    [ "Cardamom", "lime"   ],
    [ "Safran",   "red"    ],
    [ "Turmeric", "yellow" ],

    [ "Saffron",  "red"    ],
];

WELL_LENGTH = 72 * mm;      // (X)
WELL_RECESS = 17 * mm;      // (X)
WELL_DEPTH  = 45 * mm;      // (Y)
WELL_EXTRA  = 35 * mm;      // (Y)
WELL_HEIGHT = 39 * mm;      // (Z)

BOX_FRAGMENTS = 30;

// ----- Assembly details -----------------------------------------------------

// ----- 3D Printer -----------------------------------------------------------

LAYER_HEIGHT = 0.20 * mm;
WALL_WIDTH = [ 0.00, 0.43, 0.86, 1.26, 1.67, 2.08, 2.49, 2.89, 3.30 ];

THIN_WALL  = WALL_WIDTH[2];
WIDE_WALL  = WALL_WIDTH[4];

function layers( count ) = count * LAYER_HEIGHT;
function layer_height( height ) = ceil( height / LAYER_HEIGHT ) * LAYER_HEIGHT;
function tile_height( count ) = /* layer_height */ ( count * TILE_THICKNESS );

THICK = false;
THIN  = true;

BOTTOM = 1 * mm;
LID    = 1 * mm;
OUTER  = WIDE_WALL;
SPACE  = 1 * mm;

GAP     = 0.25 * mm;
NOTCH   = 10.0 * mm;    // Radius of notches
NOTCH_FRAGMENTS = 60;
OVERLAP = 0.01 * mm;    // Ensures that there are no vertical artifacts leftover

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

    $fn=BOWL_FRAGMENTS;
    
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

module ew_player_box( mirrored=false, box=true  ) {
    
    orientation = mirrored ? [1,0,0] : [0,0,0];
    
    tw = WALL_WIDTH[2];
    gap = GAP;
    
    x1 = 2*tw + gap;
    x2 = WELL_LENGTH/2 - 2*tw - gap;
    x3 = WELL_LENGTH/2 + WELL_RECESS - 2*tw - gap;
    
    y1 = 2*tw + gap;
    y2 = WELL_DEPTH - 2*tw - gap;

    depth = WELL_HEIGHT - BOTTOM - LID;
    
    outline = [ [ x1, y1 ], [ x1, y2 ], [ x2, y2 ], [ x3, y1 ] ];
    
    $fn=BOX_FRAGMENTS;
    
    mirror( orientation ) {
        difference() {
            minkowski() {
                linear_extrude( BOTTOM+depth ) polygon( outline );
                sphere( r=tw );
            }
            
            if (box) {
                translate( [0, 0, BOTTOM] ) linear_extrude( depth+BOTTOM+3*OVERLAP ) polygon( outline );
            }
        }
    }
}

module ew_player_lid( mirrored=false ) {
    
    orientation = mirrored ? [1,0,0] : [0,0,0];
    
    tw = WALL_WIDTH[2];
    gap = GAP;
    
    depth = WELL_HEIGHT/2 - LID;

    $fn=BOX_FRAGMENTS;
    
    translate( [0,0,tw] ) difference() {
        minkowski() {
            minkowski() {
                difference() {
                    ew_player_box( !mirrored, false );
                    mirror( orientation ) translate( [OVERLAP-WELL_LENGTH,0,depth+LID] ) cube( [WELL_LENGTH,WELL_DEPTH,WELL_HEIGHT] );
                }
                cylinder( r=gap, h=OVERLAP );
            }
            sphere( r=tw );
        }

        // Remove insides
        translate( [0,0,LID] ) 
            minkowski() {
                ew_player_box( !mirrored, false );
                cylinder( r=gap, h=OVERLAP );
            }

        // Remove notch
        mirror( orientation ) translate( [-WELL_LENGTH/4,-2*OVERLAP,depth+NOTCH/2] ) 
            rotate( [-90,0,0] ) cylinder( r=NOTCH, h=WELL_DEPTH+4*OVERLAP, $fn=NOTCH_FRAGMENTS );        
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
        x = floor( i/4 );
        y = i%4;
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

module ew_player_plate() {
    translate( [+3,+3,0] ) ew_player_box();
    translate( [-3,+3,0] ) ew_player_lid();
    
    translate( [+3,-3,0] ) rotate( 180 ) ew_player_box( true );
    translate( [-3,-3,0] ) rotate( 180 ) ew_player_lid( true );
}    

// ----- Render Logic for makefile --------------------------------------------

if (VERBOSE) {
	echo (Part=PART);
}

if (PART == "lid-thick") {
    bowl_lid("", THICK);
} else if (PART == "lid-thin") {
    bowl_lid("", THIN);

} else if (PART == "lid-cloves") {
    bowl_lid("Cloves", THICK);
} else if (PART == "lid-tea") {
    bowl_lid("Tea", THICK);
} else if (PART == "lid-chili") {
    bowl_lid("Chili", THICK);
} else if (PART == "lid-ginger") {
    bowl_lid("Ginger", THICK);

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

} else if (PART == "multi-cloves") {
    bowl_lid("Cloves", THIN);
} else if (PART == "multi-tea") {
    bowl_lid("Tea", THIN);
} else if (PART == "multi-chili") {
    bowl_lid("Chili", THIN);
} else if (PART == "multi-ginger") {
    bowl_lid("Ginger", THIN);

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

} else if (PART == "names-cloves") {
    bowl_names("Cloves");
} else if (PART == "names-tea") {
    bowl_names("Tea");
} else if (PART == "names-chili") {
    bowl_names("Chili");
} else if (PART == "names-ginger") {
    bowl_names("Ginger");

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

} else if (PART == "ew-player-box-right") {
    ew_player_box();
} else if (PART == "ew-player-lid-right") {
    ew_player_lid();
} else if (PART == "ew-player-box-left") {
    ew_player_box( true );
} else if (PART == "ew-player-lid-left") {
    ew_player_lid( true );

} else if (PART == "ew-player-plate") {
    ew_player_plate();

} else {
    // bowl_plate_with_names();
    // bowl_lid("", THIN);
    
    ew_player_plate();
}
