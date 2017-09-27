// Splendor Organizer
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

CARD_WIDTH  = 69 * mm;          // (X) Width of sleeved card
CARD_HEIGHT = 96 * mm;          // (Y) Height of sleeved card
CARD_STACK  = 35 * mm;          // (Z) Thickness of card stack

TOKEN_RADIUS = 22 * mm;         // (R) Radius of token (chip)
TOKEN_THICKNESS = 3.35 * mm;    // (X) Thickness of token (chip)

NOBEL_WIDTH  = 60 * mm;         // (X) Width of nobel tile
NOBEL_HEIGHT = 60 * mm;         // (Y) Height of nobel tile
CITY_WIDTH  = 120.5 * mm;       // (X) Width of city tile
CITY_HEIGHT = 60.5 * mm;        // (Y) Height of city tile
TILE_THICKNESS = 1.9 * mm;      // (Z) Thickness of nobel / city tiles
TRADING_POSTS = 4.5 * mm;       // (Z) Thickness of folded trading post board

STRONG_DIAMETER  = 21 * mm;     // Diameter of a stronghold

LID_OFFSET   = 8 * mm;
NOTCH_RADIUS = 10 * mm;
POKE_HOLE    = 20 * mm;         // Diameter of poke holes in bottom

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

token_diameter = 2 * TOKEN_RADIUS;
extra_box_wall = BOTTOM + LID;
tiles = 7 * TILE_THICKNESS;

// parts = max( tiles, STRONG_DIAMETER );

// Inner height of full-height box
FULL_HEIGHT = max( 
    token_diameter, 
    CARD_STACK, 
    tiles + STRONG_DIAMETER + extra_box_wall + TRADING_POSTS
);

// Inner height of half-height boxes
PART_HEIGHT = STRONG_DIAMETER;
TILE_HEIGHT = FULL_HEIGHT - extra_box_wall - PART_HEIGHT - TRADING_POSTS;

// Inner radius for tile tray
FULL_RADIUS = FULL_HEIGHT / 2;

if (VERBOSE) {
    echo( TokenDiameter=token_diameter, CardStack=CARD_STACK, Tiles=tiles, Parts=STRONG_DIAMETER);
    echo( FullHeight=FULL_HEIGHT, FullRadius=FULL_RADIUS, PartHeight=PART_HEIGHT, TileHeight=TILE_HEIGHT);
}

CELL_SIZE = max( NOBEL_WIDTH, NOBEL_HEIGHT, CITY_HEIGHT ) + SPACE;
BOX_DEPTH = 2 * CELL_SIZE + SEP;
BOX_WIDTH = BOX_DEPTH;

// ----- Sub-Components -------------------------------------------------------

module dummy() {
    cube([100,100,1]);
}

function token_size(n) = (n + 1) * TOKEN_THICKNESS;

module token_stack(n) {
    rotate( [0,90,0] )
        cylinder( r=FULL_RADIUS, h=token_size(n), $fn=180 );
}

// ----- Components -----------------------------------------------------------

module card_tray() {
    box_height = FULL_HEIGHT + BOTTOM;
    lid_height = LID_OFFSET;

    length = 2*INNER + 1*SEP + 2*CARD_WIDTH;
    depth = 2*INNER + CARD_HEIGHT;

    if (VERBOSE) {
        echo( BasicInsideLength=length, BasicInsideDepth=depth );
        echo( BasicOutsideLength=length+2*OUTER, BasicOutsideDepth=depth+2*OUTER );
        echo( BasicOutsideHeight=box_height+LID );
    }

    difference() {
        // Outside of box
        union() {
            minkowski() {
                cube( [ length, depth, box_height-lid_height ] );
                cylinder( r=OUTER, h=OVERLAP );
            }
            cube( [ length, depth, box_height ] );
        }
        
        // Remove space for tiles
        translate( [ INNER, INNER, BOTTOM ] ) 
            cube( [ CARD_WIDTH, CARD_HEIGHT, box_height+OVERLAP ] );
        translate( [ INNER+CARD_WIDTH+SEP, INNER, BOTTOM ] ) 
            cube( [ CARD_WIDTH, CARD_HEIGHT, box_height+OVERLAP ] );

        // Remove holes in bottom, for ease in removing tiles and parts
        translate( [ INNER+CARD_WIDTH/2, INNER+CARD_HEIGHT/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
        translate( [ INNER+CARD_WIDTH+1*SEP+CARD_WIDTH/2, INNER+CARD_HEIGHT/2, -OVERLAP ] ) 
            cylinder( d=POKE_HOLE, h=BOTTOM+2*OVERLAP );
    }
}

module card_lid() {
    lid_height = LID + LID_OFFSET;

    width = CARD_HEIGHT;
    length = 2*INNER + 1*SEP + 2*CARD_WIDTH;
    height = 2*INNER + width;

    if (VERBOSE) {
        echo( Width=width );
        echo( BasicInsideLength=length, BasicInsideHeight=height );
        echo( BasicOutsideLength=length+2*OUTER, BasicOutsideHeight=height+2*OUTER );
    }
    
    difference() {
        // Outside of lid
        minkowski() {
            cube( [ length, height, lid_height ] );
            cylinder( r=OUTER, h=1 );
        }
        
        // Remove inside of lid
        translate( [ 0, 0, LID ] )
            cube( [ length, height, lid_height+1 ] );

        // Remove notches to make it easier to remove the lid
        translate( [-2*OUTER,height/2+OUTER/2,NOTCH_RADIUS+lid_height-2*OUTER] ) 
            rotate( [0,90,0] )
                cylinder( r=NOTCH_RADIUS, h=length+4*OUTER );
    }
}

module nobel_city_tray() {
    box_height = PART_HEIGHT + BOTTOM;
    lid_height = LID_OFFSET;

    length = 2*INNER + BOX_WIDTH;
    depth = 2*INNER + BOX_DEPTH;

    if (VERBOSE) {
        echo( BasicInsideLength=length, BasicInsideDepth=depth );
        echo( BasicOutsideLength=length+2*OUTER, BasicOutsideDepth=depth+2*OUTER );
        echo( BasicOutsideHeight=box_height+LID );
    }

    difference() {
        // Outside of box
        union() {
            minkowski() {
                cube( [ length, depth, box_height-lid_height ] );
                cylinder( r=OUTER, h=OVERLAP );
            }
            cube( [ length, depth, box_height ] );
        }
        
        // Remove space for tiles
        translate( [ INNER, INNER, BOTTOM ] ) 
            cube( [ CELL_SIZE, CELL_SIZE, box_height+OVERLAP ] );
        translate( [ INNER, INNER+CELL_SIZE+SEP, BOTTOM ] ) 
            cube( [ CELL_SIZE, CELL_SIZE, box_height+OVERLAP ] );
        translate( [ INNER+CELL_SIZE+SEP, INNER, BOTTOM ] ) 
            cube( [ CELL_SIZE, 2*CELL_SIZE+SEP, box_height+OVERLAP ] );
    }
}

module nobel_city_lid() {
    lid_height = LID + LID_OFFSET;

    length = 2*INNER + BOX_WIDTH;
    depth = 2*INNER + BOX_DEPTH;

    if (VERBOSE) {
        echo( BasicInsideLength=length, BasicInsideHeight=height );
        echo( BasicOutsideLength=length+2*OUTER, BasicOutsideHeight=height+2*OUTER );
    }
    
    difference() {
        // Outside of lid
        minkowski() {
            cube( [ length, depth, lid_height ] );
            cylinder( r=OUTER, h=1 );
        }
        
        // Remove inside of lid
        translate( [ 0, 0, LID ] )
            cube( [ length, depth, lid_height+1 ] );

        // Remove notches to make it easier to remove the lid
        translate( [-2*OUTER,depth/2+OUTER/2,NOTCH_RADIUS+lid_height-2*OUTER] ) 
            rotate( [0,90,0] )
                cylinder( r=NOTCH_RADIUS, h=length+4*OUTER );
    }
}

module strongholds_tray() {
    box_height = PART_HEIGHT + BOTTOM;
    lid_height = LID_OFFSET;

    length = 2*INNER + BOX_WIDTH;
    depth = 2*INNER + BOX_DEPTH;

    if (VERBOSE) {
        echo( BasicInsideLength=length, BasicInsideDepth=depth );
        echo( BasicOutsideLength=length+2*OUTER, BasicOutsideDepth=depth+2*OUTER );
        echo( BasicOutsideHeight=box_height+LID );
    }

    difference() {
        // Outside of box
        union() {
            minkowski() {
                cube( [ length, depth, box_height-lid_height ] );
                cylinder( r=OUTER, h=OVERLAP );
            }
            cube( [ length, depth, box_height ] );
        }
        
        // Remove space for tiles
        translate( [ INNER, INNER, BOTTOM ] ) 
            cube( [ CELL_SIZE, CELL_SIZE, box_height+OVERLAP ] );
        translate( [ INNER+CELL_SIZE+SEP, INNER, BOTTOM ] ) 
            cube( [ CELL_SIZE, CELL_SIZE, box_height+OVERLAP ] );
        translate( [ INNER, INNER+CELL_SIZE+SEP, BOTTOM ] ) 
            cube( [ CELL_SIZE, CELL_SIZE, box_height+OVERLAP ] );
        translate( [ INNER+CELL_SIZE+SEP, INNER+CELL_SIZE+SEP, BOTTOM ] ) 
            cube( [ CELL_SIZE, CELL_SIZE, box_height+OVERLAP ] );
    }
}

module strongholds_lid() {
    lid_height = LID + LID_OFFSET;

    length = 2*INNER + BOX_WIDTH;
    depth = 2*INNER + BOX_DEPTH;

    if (VERBOSE) {
        echo( BasicInsideLength=length, BasicInsideHeight=height );
        echo( BasicOutsideLength=length+2*OUTER, BasicOutsideHeight=height+2*OUTER );
    }
    
    difference() {
        // Outside of lid
        minkowski() {
            cube( [ length, depth, lid_height ] );
            cylinder( r=OUTER, h=1 );
        }
        
        // Remove inside of lid
        translate( [ 0, 0, LID ] )
            cube( [ length, depth, lid_height+1 ] );

        // Remove notches to make it easier to remove the lid
        translate( [-2*OUTER,depth/2+OUTER/2,NOTCH_RADIUS+lid_height-2*OUTER] ) 
            rotate( [0,90,0] )
                cylinder( r=NOTCH_RADIUS, h=length+4*OUTER );
    }
}

module token_tray() {
    length = 7*INNER + 5*token_size(7) + token_size(5);
    height = BOTTOM + FULL_RADIUS;
    depth = 2*INNER + 2 * FULL_RADIUS;
    
    dx = token_size( 7 ) + INNER;
    dy = FULL_RADIUS + INNER;
    dz = FULL_RADIUS + BOTTOM;
    
    difference() {
        // Outside of box
        union() {
            minkowski() {
                cube( [length, depth, height-LID_OFFSET] );
                cylinder( r=OUTER, h=OVERLAP );
            }
            cube( [ length, depth, height ] );
        }
        
        // Remove slots for stacks of tokens
        translate( [0*dx+INNER,dy,dz] ) token_stack(7);
        translate( [1*dx+INNER,dy,dz] ) token_stack(7);
        translate( [2*dx+INNER,dy,dz] ) token_stack(7);
        translate( [3*dx+INNER,dy,dz] ) token_stack(7);
        translate( [4*dx+INNER,dy,dz] ) token_stack(7);
        translate( [5*dx+INNER,dy,dz] ) token_stack(5); // Only 5 Gold tokens
    }
}

module token_lid() {
    length = 7*INNER + 5*token_size(7) + token_size(5);
    height = LID + FULL_RADIUS + LID_OFFSET;
    depth = 2*INNER + 2 * FULL_RADIUS;
    
    difference() {
        // Outside of lid
        minkowski() {
            cube( [ length, depth, height ] );
            cylinder( r=OUTER, h=OVERLAP );
        }
        
        // Remove inside of lid
        translate( [0,0,height-LID_OFFSET] )
            cube( [length, depth, height] );
        translate( [INNER,INNER,LID] )
            cube( [length-2*INNER, depth-2*INNER, height] );

        // Remove slot to view tokens
        translate( [4*INNER,4*INNER,-BOTTOM] )
            cube ( [length-8*INNER, depth-8*INNER, height] );

        // Remove notches to make it easier to remove the lid
        translate( [-2*OUTER,depth/2+OUTER/2,NOTCH_RADIUS+height-2*OUTER] ) 
            rotate( [0,90,0] )
                cylinder( r=NOTCH_RADIUS, h=length+4*OUTER );
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

module token_plate() {
    place( [0, 0,0] ) token_tray();
    place( [0,60,0] ) token_lid();    
}    

module card_plate() {
    place( [  0,0,0], 90 ) card_tray();
    place( [110,0,0], 90 ) card_lid();
}

module nobel_city_plate() {
    place( [   0,0,0] ) nobel_city_tray();
    place( [ 140,0,0] ) nobel_city_lid();
}

module strongholds_plate() {
    place( [   0,0,0] ) strongholds_tray();
    place( [ 140,0,0] ) strongholds_lid();
}

// ----- Render Logic for makefile --------------------------------------------

if (VERBOSE) {
	echo (Part=PART);
}

if (PART == "card-tray") {
    card_tray();
} else if (PART == "card-lid") {
    card_lid();
} else if (PART == "token-tray") {
    token_tray();
} else if (PART == "token-lid") {
    token_lid();
} else if (PART == "nobel-city-tray") {
    nobel_city_tray();
} else if (PART == "nobel-city-lid") {
    nobel_city_lid();
} else if (PART == "strongholds-tray") {
    strongholds_tray();
} else if (PART == "strongholds-lid") {
    strongholds_lid();
} else if (PART == "token-plate") {
    token_plate();
} else if (PART == "card-plate") {
    card_plate();
} else if (PART == "nobel-city-plate") {
    nobel_city_plate();
} else if (PART == "strongholds-plate") {
    strongholds_plate();
} else {
    place( [0,0,0] ) nobel_city_plate();
    place( [0,140,0] ) strongholds_plate();
    place( [280,160,0] ) token_plate();
    place( [380,0,0] ) card_plate();
}
