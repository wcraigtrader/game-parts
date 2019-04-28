// 18XX Tray Library
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
include <18XX-data.scad>;

// ----- Physical dimensions ------------------------------------------------------------------------------------------

HEX_SPACING = WALL_WIDTH[4];

STUB        = 2.00 * mm;  // Height of lid stubs
STUB_GAP    = 0.20 * mm;  // Separation between lid stubs and tray hex corners

FONT_NAME   = "helvetica:style=Bold";
FONT_SIZE   = 6.0;
FONT_HEIGHT = layers( 4 );

$fa=4; $fn=30;

// ----- Calculated dimensions ----------------------------------------------------------------------------------------

C30 = cos(30); C60 = cos(60);
S30 = sin(30); S60 = sin(60);
T30 = tan(30); T60 = tan(60);

// ----- Offsets for positioning hex tiles ----------------------------------------------------------------------------

TILE_CORNERS = [ // Corners 0, 1, 2, 3, 4, 5, 6, 0
    [ 0, 2 ], [ 2, 1 ], [ 2,-1 ], [ 0,-2 ], [-2,-1 ], [-2, 1 ], [ 0, 2 ]
];

// ----- Functions ----------------------------------------------------------------------------------------------------

function hex_length( hex ) = hex + 2*HEX_SPACING;
function hex_width( hex ) = hex_length( hex ) * S60;
function hex_edge( hex ) = hex_length( hex ) / 2;
function hex_delta( hex ) = [ hex_width( hex )/4, hex_length( hex )/4, hex_edge( hex ) ];

function hex_rows( layout ) = len( layout );
function hex_cols( layout ) = max( len( layout[0] ), len( layout[1] ) );
function uneven_rows( layout ) = (len( layout[0] ) != len( layout[1] )) ? 0 : 0.5;
function short_row( layout ) = len( layout[0] ) > len( layout[1] ) ? 1 : 0;

function border_size_x( layout, hex, x ) = (x - (hex_cols( layout ) + uneven_rows( layout ) ) * hex_width( hex ) ) / 2;
function border_size_y( layout, hex, y ) = (y - (hex_rows( layout ) * 3+1) / 4 * hex_length( hex ) ) / 2;
function border_delta( layout, hex, size ) = [ border_size_x( layout, hex, size.x ), border_size_y( layout, hex, size.y ) ];

function tile_offset( tile, delta, border, z ) = [ tile.x*delta.x+border.x, tile.y*delta.y+border.y, z ];
function corner_offset( tile, corner, delta, border, z ) = [ (tile.x + corner.x) * delta.x + border.x, (tile.y + corner.y) * delta.y + border.y, z ];

// ----- Modules ------------------------------------------------------------------------------------------------------

/* hex_corner( corner, height )
 *
 * This creates a short segment of the corner of a hexagonal wall
 *
 * corner -- 0-5, specifying which corner of the hexagon to create, clockwise
 * height -- Height of the wall segment in millimeters
 * gap    -- Fraction of a millimeter, to tweak the width of the corner
 */
module hex_corner( corner, height, gap=0 ) {
    // FIXME
    size = THIN_WALL;
    offset = corner * -60;
    for ( angle=[210,330] ) {
        rotate( [0, 0, angle+offset] )
        translate( [ 0, -size/2-gap/2, 0 ] )
        cube( [4*size, size+gap, height ] );
    }
    cylinder( d=size+2*gap, h=height );
}

/* hex_wall( corner, height )
 */

module hex_wall( corner, delta, width, height ) {
    diff = TILE_CORNERS[ corner+1 ] - TILE_CORNERS[ corner ];
    w2l = width / delta[2];

    hull() {
        translate( [diff.x*delta.x*(0.15+w2l), diff.y*delta.y*(0.15+w2l), 0] ) cylinder( d=width, h=height, $fn=6 );
        translate( [diff.x*delta.x*(0.85-w2l), diff.y*delta.y*(0.85-w2l), 0] ) cylinder( d=width, h=height, $fn=6 );
    }
}

/* hex_prism( height, diameter )
 *
 * Create a vertical hexagonal prism of a given height and diameter
 */
module hex_prism( height, diameter ) {
    rotate( [ 0, 0, 90 ] ) cylinder( h=height, d=diameter, $fn=6 );
}

/* hex_box( layout, size, hex, labels, dimensions )
 *
 * Create a tray to hold hexagonal tiles
 *
 * layout     -- Arrangement of tiles in box
 * size       -- Vector describing the exterior size of the box
 * hex        -- Diameter of a hex tile (corner to opposite corner)
 * labels     -- List of labels to add to the box
 * dimensions -- List of physical dimensions
 */
module hex_box_1( layout, size, hex, labels=[], dimensions=REASONABLE ) {
    bottom = dimensions[BOTTOM];
    outer  = dimensions[OUTER];

    inside = [ size.x-4*outer-2*GAP, size.y-4*outer-2*GAP, size.z ];

    border = border_delta( layout, hex, inside );
    td = hex_delta( hex );

    if (VERBOSE) {
        echo( HexBox1_Size=size, InSize=inside, Border=border, Delta=td );
    }

    difference() {
        union() {
            // Add bottom plate
            rounded_box( inside, HOLLOW );

            // Add tile corners
            translate( [0, 0, -OVERLAP] ) union() {
                for (row=layout) {
                    for (tile=row) {
                        for (c=[0:5]) {
                            offset = corner_offset( tile, TILE_CORNERS[c], td, border, 0 );
                            translate( offset ) hex_corner( c, size.z );
                        }
                    }
                }
            }

            // Add labels
            if (len(labels) > 0) {
                sr = short_row( layout );

                for (l=[len(labels)-1:-1:0]) {
                    ly = layout[sr+2*l][0][1]*td.y + border.y;
                    translate( [inside.x-border.x+1, ly, -OVERLAP] )
                        rotate( [0,0,-90] ) linear_extrude( height=FONT_HEIGHT+OVERLAP )
                            text( labels[l], font=FONT_NAME, size=FONT_SIZE, halign="center", valign="top" );
                }
            }
        }

        // Remove finger holes
        for (row=layout) {
            for (tile=row) {
                offset = tile_offset( tile, td, border, -bottom-OVERLAP );
                translate( offset ) hex_prism( bottom+2*OVERLAP, POKE_HOLE );
            }
        }
    }
}

/* hex_lid( width, depth, height, outer, inner, remove_corners, add_stubs )
 *
 * Create a lid for a hexagon tile tray
 *
 * width          -- Width (X) of the tray (outside dimensions)
 * depth          -- Depth (Y) of the tray (outside dimensions
 * height         -- Height (Z) of the stack of tiles (inside dimensions)
 * outer          -- Outer wall thickness
 * inner          -- Inner wall thickness
 * remove_corners -- True to remove the corners of the inner walls
 * add_stubs      -- True to add stubs that fit with the hex corners from the tray
 */
module hex_lid_1( layout, size, hex, add_stubs=false, remove_holes=true, dimensions=REASONABLE ) {
    top = dimensions[TOP];
    outer = dimensions[OUTER];

    inside = [ size.x-4*outer-2*GAP, size.y-4*outer-2*GAP, size.z ];

    border = border_delta( layout, hex, inside );
    td = hex_delta( hex );

    if (VERBOSE) {
        echo( HexBox1_Size=size, InSize=inside, Border=border, Delta=td );
    }

    // Mirrored so that the lid match its box
    mirror( [0,1,0] ) union() {
        difference() {
            rounded_lid( inside );

            // Remove finger holes
            if (remove_holes) {
                for (row=layout) {
                    for (tile=row) {
                        offset = tile_offset( tile, td, border, -top-OVERLAP );
                        translate( offset ) hex_prism( top+2*OVERLAP, POKE_HOLE );
                    }
                }
            }
        }

        if (add_stubs) {
            // Add tile corners
            translate( [0, 0, -OVERLAP] ) intersection() {
                cube( [inside.x, inside.y, inside.z+OVERLAP] );

                difference() {
                    union() {
                        for (row=layout) {
                            for (tile=row) {
                                for (c=[0:5]) {
                                    offset = corner_offset( tile, TILE_CORNERS[c], td, border, -OVERLAP );
                                    translate( offset ) hex_prism( STUB+OVERLAP, 7*WIDE_WALL );
                                }
                            }
                        }
                    }

                    union() { // add corners
                        for (row=layout) {
                            for (tile=row) {
                                for (c=[0:5]) {
                                    offset = corner_offset( tile, TILE_CORNERS[c], td, border, 0 );
                                    translate( offset ) hex_corner( c, STUB+OVERLAP, STUB_GAP );
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


/* hex_box( layout, size, hex, labels, dimensions )
 *
 * Create a tray to hold hexagonal tiles
 *
 * layout     -- Arrangement of tiles in box
 * size       -- Vector describing the exterior size of the box
 * hex        -- Diameter of a hex tile (corner to opposite corner)
 * labels     -- List of labels to add to the box
 * dimensions -- List of physical dimensions
 */
module hex_box_2( layout, size, hex, labels=[], dimensions=REASONABLE ) {
    bottom = dimensions[BOTTOM];
    outer  = dimensions[OUTER];

    inside = [ size.x-4*outer-2*GAP, size.y-4*outer-2*GAP, size.z ];

    border = border_delta( layout, hex, inside );
    td = hex_delta( hex );

    if (VERBOSE) {
        echo( HexBox1_Size=size, InSize=inside, Border=border, Delta=td );
    }

    difference() {
        union() {
            rounded_box( inside, HOLLOW );

            if (len(labels) > 0) {
                sr = short_row( layout );

                for (l=[len(labels)-1:-1:0]) {
                    ly = layout[sr+2*l][0][1]*td.y + border.y;
                    translate( [inside.x-border.x+1, ly, -OVERLAP] )
                        rotate( [0,0,-90] ) linear_extrude( height=FONT_HEIGHT+OVERLAP )
                            text( labels[l], font=FONT_NAME, size=FONT_SIZE, halign="center", valign="top" );
                }
            }

            translate( [0, 0, -OVERLAP] )
                for (row=layout) {
                    for (tile=row) {
                        for (c=[0:5]) {
                            offset = corner_offset( tile, TILE_CORNERS[c], td, border, 0 );
                            translate( offset ) hex_wall( c, td, WALL_WIDTH[2], size.z+2*OVERLAP );
                        }
                    }
                }


        }

        for (row=layout) {
            for (tile=row) {
                offset = tile_offset( tile, td, border, -bottom-OVERLAP );
                translate( offset ) hex_prism( bottom+2*OVERLAP, POKE_HOLE );
            }
        }
    }

}

/* hex_lid( width, depth, height, outer, inner, remove_corners, add_stubs )
 *
 * Create a lid for a hexagon tile tray
 *
 * width          -- Width (X) of the tray (outside dimensions)
 * depth          -- Depth (Y) of the tray (outside dimensions
 * height         -- Height (Z) of the stack of tiles (inside dimensions)
 * outer          -- Outer wall thickness
 * inner          -- Inner wall thickness
 * remove_corners -- True to remove the corners of the inner walls
 * add_stubs      -- True to add stubs that fit with the hex corners from the tray
 */
module hex_lid_2( layout, size, hex, add_stubs=false, remove_holes=true, dimensions=REASONABLE ) {
    top = dimensions[TOP];
    outer = dimensions[OUTER];

    inside = [ size.x-4*outer-2*GAP, size.y-4*outer-2*GAP, size.z ];

    border = border_delta( layout, hex, inside );
    td = hex_delta( hex );

    if (VERBOSE) {
        echo( HexBox1_Size=size, InSize=inside, Border=border, Delta=td );
    }

    // Mirrored so that the lid match its box
    mirror( [0,1,0] ) union() {
        difference() {
            rounded_lid( inside );

            // Remove finger holes
            if (remove_holes) {
                for (row=layout) {
                    for (tile=row) {
                        offset = tile_offset( tile, td, border, -top-OVERLAP );
                        translate( offset ) hex_prism( top+2*OVERLAP, POKE_HOLE );
                    }
                }
            }
        }

        if (add_stubs) {
            translate( [0, 0, -OVERLAP] )
                for (row=layout) {
                    for (tile=row) {
                        for (c=[0:5]) {
                            offset = corner_offset( tile, TILE_CORNERS[c], td, border, 0 );
                            difference() {
                                translate( offset ) hex_wall( c, td, WALL_WIDTH[8], STUB+OVERLAP );
                                translate( offset ) hex_wall( c, td, WALL_WIDTH[3], STUB+2*OVERLAP );
                            }
                        }
                    }
                }
        }
    }
}

// ----- Testing ------------------------------------------------------------------------------------------------------

if (0) {
    VERBOSE = true;

    // Part box dimensions
    PART_WIDTH      = 35.0; // 1.25 * inch;  // X
    PART_DEPTH      = 17.5; // 0.75 * inch;  // Y
    PART_HEIGHT     = 6.00 * mm;    // Z

    px = PART_WIDTH; py = PART_DEPTH;

    PART_CELLS = [
        [ [ px, py ], [ px, py ], [ px, py ] ],
        [ [ px, py ], [ px, py ], [ px, py ] ],
        [ [ px, py ], [ px, py ], [ px, py ] ]
    ];

    TEST_CELLS = [
        [ [ 20, 20 ], [ 30, 20 ], [ 40, 20 ] ],
        [ [ 20, 15 ], [ 30, 15 ], [ 40, 15 ] ],
        [ [ 20, 10 ], [ 30, 10 ], [ 40, 10 ] ]
    ];

    cell_box( PART_CELLS, PART_HEIGHT );
    translate( [0, 70, 0] )
    cell_lid( PART_CELLS, PART_HEIGHT );
}

if (0) {
    echo ( TC=TILE_CORNERS );
    echo ( One=TILE_CORNERS[1]-TILE_CORNERS[0], Two=TILE_CORNERS[2]-TILE_CORNERS[1]);
    box_size = [5*inch, 4*inch, 6*mm];
    translate( [5, 5, 0] ) hex_box_2( TILE_CENTERS_2X2, box_size, 46, ["18XX"] );
    translate( [5,-5, 0] ) hex_lid_2( TILE_CENTERS_2X2, box_size, 46, true );
}
