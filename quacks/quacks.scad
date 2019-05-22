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

include <../util/units.scad>;
include <../util/boxes.scad>;

// ----- Command Line Arguments ---------------------------------------------------------------------------------------

PART = "other";           // Which part to output
VERBOSE = true;           // Set to non-zero to see more data

// ----- Physical Measurements ----------------------------------------------------------------------------------------

WELL = [ 10.5*inch, 3.5*inch, 2*inch ];     // Inside measurement of component well
HALF = [ WELL.x/2, WELL.y, WELL.z/2 ];
CHIP = [ WELL.x/4, WELL.y, WELL.z/2 ];      // Outside size of chip boxes

QUACKS = [ 5*LAYER_HEIGHT, 5*LAYER_HEIGHT, WALL_WIDTH[3], WALL_WIDTH[2], 5*mm, 20*mm, 2*mm ];

// ----- Calculated Measurements --------------------------------------------------------------------------------------

WALLS  = wall_sizes( QUACKS );

// ----- Modules ------------------------------------------------------------------------------------------------------

module half_box() {
    inside = CHIP - WALLS;
    
    overlap = [0,0,OVERLAP];
    fillet = QUACKS[ FILLET ];
    
    rounded_box( inside, ROUNDED, borders=QUACKS );
}

module half_lid() {
    inside = CHIP - WALLS;
    
    mirror( [1,0,0] ) rounded_lid( inside, borders=QUACKS );
}


module single_box() {
    inner = QUACKS[ INNER ];
    inside = HALF - WALLS;

    dx = (inside.x - inner*0) / 1;
    dy = (inside.y - inner*0) / 1;

    cells = [ [ [dx, dy] ] ];

    cell_box( cells, inside.z, ROUNDED, borders=QUACKS );
}

module single_lid() {
    inside = HALF - WALLS;

    mirror( [1,0,0] ) rounded_lid( inside, borders=QUACKS );
}

module dual_box() {
    inner = QUACKS[ INNER ];
    inside = HALF - WALLS;

    dx = (inside.x - inner*1) / 2;
    dy = (inside.y - inner*0) / 1;

    cells = [ [ [dx, dy], [dx, dy ] ] ];

    cell_box( cells, inside.z, ROUNDED, borders=QUACKS );
}

module quad_box() {
    inner = QUACKS[ INNER ];
    inside = HALF - WALLS;

    dx = (inside.x - inner*1) / 2;
    dy = (inside.y - inner*1) / 2;

    cells = [ [ [dx, dy], [dx, dy ] ], [ [dx, dy], [dx, dy ] ] ];

    cell_box( cells, inside.z, ROUNDED, borders=QUACKS );
}

module chip_box() {
    inner = QUACKS[ INNER ];
    inside = HALF - WALLS;

    dx1 = (inside.x - inner*3) / 4;
    dx2 = (inside.x - inner*1) / 2;
    dy = (inside.y - inner*1) / 2;
    
    cells = [ [ [dx2, dy], [dx2, dy ] ], [ [dx1, dy], [dx1, dy ], [dx1, dy ], [dx1, dy ] ] ];

    cell_box( cells, inside.z, ROUNDED, borders=QUACKS );
}


// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "single-lid") {
    single_lid();
} else if (PART == "single-box") {
    single_box();
} else if (PART == "dual-box") {
    dual_box();
} else if (PART == "quad-box") {
    quad_box();
} else if (PART == "chip-box") {
    chip_box();
} else if (PART == "half-box") {
    half_box();
} else if (PART == "half-lid") {
    half_lid();
} else {
    translate( [ 5,-89,0] ) half_box();
    translate( [-5,-89,0] ) half_lid();

    translate( [-5,  5,0] ) single_lid();

    translate( [   5,  5, 0] ) single_box();
    translate( [   5, 99, 0] ) dual_box();
    translate( [ 144,  5, 0] ) quad_box();
    translate( [ 144, 99, 0] ) chip_box();
}

