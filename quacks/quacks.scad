// The Quacks of Quedlinburg
// by W. Craig Trader
//
// --------------------------------------------------------------------------------------------------------------------
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
//
// --------------------------------------------------------------------------------------------------------------------

include <../util/boxes.scad>;

// ----- Command Line Arguments ---------------------------------------------------------------------------------------

PART = "other";           // Which part to output
VERBOSE = true;           // Set to non-zero to see more data

// ----- Physical Measurements ----------------------------------------------------------------------------------------

WELL = [ 10.5*inch, 3.5*inch, 2*inch ];     // Inside measurement of component well

// Box dimensions
QUACKS = [ 5*LAYER_HEIGHT, 5*LAYER_HEIGHT, WALL_WIDTH[3], WALL_WIDTH[2], 5*mm, 20*mm, 2*mm ];
CARDS  = [56.25, 87.5, 0.30 ];

// ----- Calculated Measurements --------------------------------------------------------------------------------------

CHIP = [ WELL.x/2, WELL.y/1, WELL.z/2 ];
MISC = [ WELL.x/2, WELL.y/1, WELL.z/3 ];    // Outside size of chip boxes
MINI = [ WELL.y/1, WELL.z/1, WELL.x/12 ];   // Outside size of player boxes

WALLS  = wall_sizes( QUACKS );

// ----- Modules ------------------------------------------------------------------------------------------------------

module mini_box() {
    if (VERBOSE) { echo( MiniBox=MINI ); }
    rounded_box( MINI - WALLS, ROUNDED, borders=QUACKS );
}

module mini_lid() {
    if (VERBOSE) { echo( MiniLid=MINI ); }
    mirror( [1,0,0] ) rounded_lid( MINI - WALLS, borders=QUACKS );
}

module misc_box() {
    if (VERBOSE) { echo( MiscBox=MISC ); }

    inside = MISC - WALLS;

    inner = QUACKS[ INNER ];
    dx = (inside.x - inner*1) / 2;
    dy = (inside.y - inner*1) / 2;

    cells = [ [ [dx, dy], [dx, dy ] ], [ [dx, dy], [dx, dy ] ] ];

    cell_box( cells, inside.z, ROUNDED, borders=QUACKS );
}

module misc_lid() {
    if (VERBOSE) { echo( MiscLid=MISC ); }
    mirror( [1,0,0] ) rounded_lid( MISC-WALLS, borders=QUACKS );
}

module chip_box() {
    if (VERBOSE) { echo( ChipBox=CHIP ); }
    
    inside = CHIP - WALLS;

    inner = QUACKS[ INNER ];
    dx1 = (inside.x - inner*3) * 0.25;
    dx2 = (inside.x - inner*1) * 0.50;
    dy1 = (inside.y - inner*1) * 0.50;
    dy2 = (inside.y - inner*1) * 0.50;
    
    cells = [ [ [dx2, dy1], [dx2, dy1 ] ], [ [dx1, dy2], [dx1, dy2], [dx1, dy2], [dx1, dy2] ] ];

    cell_box( cells, inside.z, ROUNDED, borders=QUACKS );
}

module chip_lid() {
    if (VERBOSE) { echo( ChipLid=CHIP ); }
    mirror( [1,0,0] ) rounded_lid( CHIP-WALLS, borders=QUACKS );
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "chip-lid") {
    chip_lid();
} else if (PART == "chip-box") {
    chip_box();
} else if (PART == "misc-box") {
    misc_box();
} else if (PART == "misc-lid") {
    misc_lid();
} else if (PART == "mini-box") {
    mini_box();
} else if (PART == "mini-lid") {
    mini_lid();
} else if (PART == "card-sleeve") {
    deck_box( CARDS, 24 );
} else {
    deck_box( CARDS, 24 );
    /*
    translate( [  5, -51, 0] ) mini_box();
    translate( [ -5, -51, 0] ) mini_lid();

    translate( [  5,   5, 0] ) misc_box();
    translate( [ -5,   5, 0] ) misc_lid();

    translate( [  5,  99, 0] ) chip_box();
    translate( [ -5,  99, 0] ) chip_lid();
    */
}

