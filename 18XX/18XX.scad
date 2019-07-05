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

include <util/units.scad>;
include <util/boxes.scad>;
include <util/hexes.scad>;

// ----- Physical dimensions ------------------------------------------------------------------------------------------

STUB        = 3.00 * mm;  // Height of lid stubs
STUB_GAP    = 0.20 * mm;  // Separation between lid stubs and tray hex corners

FONT_NAME   = "helvetica:style=Bold";
FONT_SIZE   = 6.0;
FONT_HEIGHT = layers( 4 );

$fa=4; $fn=30;

// ----- Calculated dimensions ----------------------------------------------------------------------------------------

WALL1 = WALL_WIDTH[4];
WALL2 = WALL1 + 2*STUB_GAP;
WALL3 = WALL2 + 2*WALL_WIDTH[4];
PADDING = [ 4*WALL1, 2*WALL1, 0 ];

SHIFTING = 1.00 * mm;    // Room for tiles to shift

WIDTH  = 0;     // (X) Card width
HEIGHT = 1;     // (Y) Card height
MARKER = 2;     // (Z) Marker diameter

// ----- Functions ----------------------------------------------------------------------------------------------------

function tile_offset( tile, delta, border, z ) = [ tile.x*delta.x+border.x, tile.y*delta.y+border.y, z ];
function corner_offset( tile, corner, delta, border, z ) = [ (tile.x + corner.x) * delta.x + border.x, (tile.y + corner.y) * delta.y + border.y, z ];
function actual_size( size, optimum ) = [ size.x == 0 ? optimum.x : size.x, size.y == 0 ? optimum.y : size.y, size.z ];
function uniform_token_cells( rows, cols, tx, ty ) = [ for( r=[0:rows-1] ) [ for( c=[0:cols-1] ) [ tx, ty ] ] ];

// ----- Modules ------------------------------------------------------------------------------------------------------

/* hex_box_1( layout, size, hex, labels, dimensions )
 *
 * Create a tray to hold hexagonal tiles
 *
 * layout     -- Arrangement of tiles in box
 * size       -- Vector describing the exterior size of the box
 * hex        -- Diameter of a hex tile (corner to opposite corner)
 * labels     -- List of labels to add to the box
 * dimensions -- List of physical dimensions
 *
 * @deprecated
 */
module hex_box_1( layout, size, hex, labels=[], dimensions=REASONABLE ) {
    bottom = dimensions[BOTTOM];
    outer  = dimensions[OUTER];

    inside = [ size.x-4*outer-2*GAP, size.y-4*outer-2*GAP, size.z ];

    border = (inside - layout_size( layout, hex )) / 2;

    config = hex_config( hex );

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
                            offset = corner_offset( tile, TILE_CORNERS[c], config, border, 0 );
                            translate( offset ) hex_corner( c, size.z );
                        }
                    }
                }
            }

            // Add labels
            if (len(labels) > 0) {
                sr = short_row( layout );

                for (l=[len(labels)-1:-1:0]) {
                    ly = layout[sr+2*l][0][1]*config.y + border.y;
                    translate( [inside.x-border.x+1, ly, -OVERLAP] )
                        rotate( [0,0,-90] ) linear_extrude( height=FONT_HEIGHT+OVERLAP )
                            text( labels[l], font=FONT_NAME, size=FONT_SIZE, halign="center", valign="top" );
                }
            }
        }

        // Remove finger holes
        for (row=layout) {
            for (tile=row) {
                offset = tile_offset( tile, config, border, -bottom-OVERLAP );
                translate( offset ) hex_prism( bottom+2*OVERLAP, hex*0.75 );
            }
        }
    }
}

/* hex_lid_1( width, depth, height, outer, inner, remove_corners, add_stubs )
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
 *
 * @deprecated
 */
module hex_lid_1( layout, size, hex, add_stubs=false, remove_holes=true, dimensions=REASONABLE ) {
    top = dimensions[TOP];
    outer = dimensions[OUTER];

    inside = [ size.x-4*outer-2*GAP, size.y-4*outer-2*GAP, size.z ];

    border = (inside - layout_size( layout, hex )) / 2;
    config = hex_config( hex );

    if (VERBOSE) {
        echo( HexBox1_Size=size, InSize=inside, Border=border, Config=config );
    }

    // Mirrored so that the lid match its box
    mirror( [0,1,0] ) union() {
        difference() {
            rounded_lid( inside );

            // Remove finger holes
            if (remove_holes) {
                for (row=layout) {
                    for (tile=row) {
                        offset = tile_offset( tile, config, border, -top-OVERLAP );
                        translate( offset ) hex_prism( top+2*OVERLAP, hex*0.75 );
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
                                    offset = corner_offset( tile, TILE_CORNERS[c], config, border, -OVERLAP );
                                    translate( offset ) hex_prism( STUB+OVERLAP, 7*WIDE_WALL );
                                }
                            }
                        }
                    }

                    union() { // add corners
                        for (row=layout) {
                            for (tile=row) {
                                for (c=[0:5]) {
                                    offset = corner_offset( tile, TILE_CORNERS[c], config, border, 0 );
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


/* hex_box_2( layout, size, hex, labels, dimensions )
 *
 * Create a tray to hold hexagonal tiles
 *
 * layout     -- Arrangement of tiles in box
 * size       -- Vector describing the exterior size of the box
 * hex        -- Diameter of a hex tile (corner to opposite corner)
 * labels     -- List of labels to add to the box
 * dimensions -- List of physical dimensions
 *
 * size.x     -- (X) Outside length of box (if zero, use optimum)
 * size.y     -- (Y) Outside width of box (if zero, use optimum)
 * size.z     -- (Z) Inside height of box
 */
module hex_box_2( layout, size, hex, labels=[], dimensions=REASONABLE ) {
    bottom = dimensions[BOTTOM];
    outer  = dimensions[OUTER];

    walls  = [ 4*outer+2*GAP, 4*outer+2*GAP, 0];
    minimum = layout_size( layout, hex );
    optimum = minimum + walls + PADDING;

    inside = actual_size( size, optimum ) - walls;
    border = (inside - minimum) / 2;

    config = hex_config( hex );

    if (VERBOSE) {
        echo( HexBox1_Size=size, InSize=inside, Border=border, Config=config );
        echo (HexBox1_Minimum=minimum, Optimum=optimum );
    }

    difference() {
        union() {
            rounded_box( inside, HOLLOW );

            if (len(labels) > 0) {
                sr = short_row( layout );

                for (l=[len(labels)-1:-1:0]) {
                    ly = layout[sr+2*l][0][1]*config.y + border.y;
                    translate( [inside.x-border.x+1, ly, -OVERLAP] )
                        rotate( [0,0,-90] ) linear_extrude( height=FONT_HEIGHT+OVERLAP )
                            text( labels[l], font=FONT_NAME, size=FONT_SIZE, halign="center", valign="top" );
                }
            }

            translate( [0, 0, -OVERLAP] )
                for (row=layout) {
                    for (tile=row) {
                        for (c=[0:5]) {
                            offset = corner_offset( tile, TILE_CORNERS[c], config, border, 0 );
                            translate( offset ) hex_wall( c, config, WALL1, size.z+2*OVERLAP );
                        }
                    }
                }


        }

        for (row=layout) {
            for (tile=row) {
                offset = tile_offset( tile, config, border, -bottom-OVERLAP );
                translate( offset ) hex_prism( bottom+2*OVERLAP, hex*0.75 );
            }
        }
    }

}

/* hex_lid_2( width, depth, height, outer, inner, remove_corners, add_stubs )
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
 *
 * size.x         -- (X) Outside length of box (if zero, use optimum)
 * size.y         -- (Y) Outside width of box (if zero, use optimum)
 * size.z         -- (Z) Inside height of box
 */
module hex_lid_2( layout, size, hex, add_stubs=false, remove_holes=true, dimensions=REASONABLE ) {
    top = dimensions[TOP];
    outer = dimensions[OUTER];

    walls  = [ 4*outer+2*GAP, 4*outer+2*GAP, 0];
    minimum = layout_size( layout, hex );
    optimum = minimum + walls + PADDING;

    inside = actual_size( size, optimum ) - walls;
    border = (inside - minimum) / 2;

    config = hex_config( hex );

    if (VERBOSE) {
        echo( HexBox1_Size=size, InSize=inside, Border=border, Config=config );
    }

    // Mirrored so that the lid match its box
    mirror( [0,1,0] ) union() {
        difference() {
            rounded_lid( inside );

            // Remove finger holes
            if (remove_holes) {
                for (row=layout) {
                    for (tile=row) {
                        offset = tile_offset( tile, config, border, -top-OVERLAP );
                        translate( offset ) hex_prism( top+2*OVERLAP, hex*0.75 );
                    }
                }
            }
        }

        if (add_stubs) {
            overlap = [0,0,OVERLAP];
            stub_z = min( size.z, STUB );   // If box is really thin, use thin stubs

            translate( -overlap ) intersection() {
                cube( [inside.x, inside.y, stub_z+OVERLAP] );
                union() {
                    for (row=layout) {
                        for (tile=row) {
                            for (c=[0:5]) {
                                displacement = corner_offset( tile, TILE_CORNERS[c], config, border, 0 );
                                difference() {
                                    translate( displacement ) hex_wall( c, config, WALL3, stub_z+OVERLAP );
                                    translate( displacement ) hex_wall( c, config, WALL2, STUB+2*OVERLAP );
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/* card_box( sizes, dimensions )
 *
 * Create a box to hold cards and tokens
 *
 * sizes      -- Width aand Height of cards, diameter of Marker
 * dimensions -- List of physical dimensions
 */
module card_box( sizes, dimensions=REASONABLE ) {
    inner  = dimensions[INNER];
    bottom = dimensions[BOTTOM];
    width  = sizes[WIDTH];
    height = sizes[HEIGHT];
    marker = sizes[MARKER];
    border = 10 * mm;

    inside = [
        marker + inner + width + 3 * SHIFTING,
        height + 2 * SHIFTING,
        layer_height( marker )
    ];

    mr = (marker + SHIFTING) / 2;   // Marker Radius

    window = [ inside.x-2*border-2*mr-inner, inside.y-2*border, bottom+2*OVERLAP ];

    if (VERBOSE) {
        echo( CardBox=sizes, CardBoxInside=inside );
    }

    difference() {
        union() {
            // Start with a hollow box
            rounded_box( inside, HOLLOW );

            // Add a marker rack
            difference() {
                cube( [2*mr, inside.y, mr] );
                translate( [mr, 0, mr] ) rotate( [-90,0,0] ) cylinder( r=mr, h = inside.y, center=false );
            }

            // Add a divider
            translate( [2*mr, 0, 0] ) cube( [inner, inside.y, inside.z] );
        }

        // Remove a finger hole
        translate( [inside.x-window.x-border, border, -bottom-OVERLAP] ) cube( window );
    }
}

/* card_lid( sizes, dimensions )
 *
 * Create a lid for a card box
 *
 * sizes      -- Width aand Height of cards, diameter of Marker
 * dimensions -- List of physical dimensions
 */
module card_lid( sizes, dimensions=REASONABLE ) {
    inner  = dimensions[INNER];
    top    = dimensions[TOP];
    width  = sizes[WIDTH];
    height = sizes[HEIGHT];
    marker = sizes[MARKER];
    border = 10 * mm;

    inside = [
        marker + inner + width + 3 * SHIFTING,
        height + 2 * SHIFTING,
        layer_height( marker )
    ];

    mr = (marker + SHIFTING) / 2;   // Marker Radius

    window = [ inside.x-2*border-2*mr-inner, inside.y-2*border, top+2*OVERLAP ];

    mirror( [0,1,0] ) difference() {
        rounded_lid( inside );
        translate( [inside.x-window.x-border, border, -top-OVERLAP] ) cube( window );
    }
}

/* deep_card_box( sizes, dimensions )
 *
 * Create a box to hold cards and tokens
 *
 * sizes      -- Width aand Height of cards, diameter of Marker
 * dimensions -- List of physical dimensions
 */
module deep_card_box( sizes, dimensions=REASONABLE ) {
    inner  = dimensions[INNER];
    bottom = dimensions[BOTTOM];
    width  = sizes[WIDTH];
    height = sizes[HEIGHT];
    marker = sizes[MARKER];
    border = 10 * mm;

    inside = [
        width + 2 * SHIFTING,
        marker + inner + height + 3 * SHIFTING,
        layer_height( marker )
    ];

    mr = (marker + SHIFTING) / 2;   // Marker Radius

    window = [ inside.x-2*border, inside.y-2*border-2*mr-inner, bottom+2*OVERLAP ];

    if (VERBOSE) {
        echo( CardBox=sizes, CardBoxInside=inside );
    }

    difference() {
        union() {
            // Start with a hollow box
            rounded_box( inside, HOLLOW );

            // Add a marker rack
            difference() {
                cube( [inside.x, 2*mr, mr] );
                translate( [0, mr, mr] ) rotate( [0,90,0] ) cylinder( r=mr, h = inside.x, center=false );
            }

            // Add a divider
            translate( [0, 2*mr, 0] ) cube( [inside.x, inner, inside.z] );
        }

        // Remove a finger hole
        translate( [border, inside.y-window.y-border, -bottom-OVERLAP] ) cube( window );
    }
}

/* deep_card_lid( sizes, dimensions )
 *
 * Create a lid for a card box
 *
 * sizes      -- Width aand Height of cards, diameter of Marker
 * dimensions -- List of physical dimensions
 */
module deep_card_lid( sizes, dimensions=REASONABLE ) {
    inner  = dimensions[INNER];
    top    = dimensions[TOP];
    width  = sizes[WIDTH];
    height = sizes[HEIGHT];
    marker = sizes[MARKER];
    border = 10 * mm;

    inside = [
        width + 2 * SHIFTING,
        marker + inner + height + 3 * SHIFTING,
        layer_height( marker )
    ];

    mr = (marker + SHIFTING) / 2;   // Marker Radius

    window = [ inside.x-2*border, inside.y-2*border-2*mr-inner, top+2*OVERLAP ];

    mirror( [0,1,0] ) difference() {
        rounded_lid( inside );
        translate( [border, inside.y-window.y-border, -top-OVERLAP] ) cube( window );
    }
}

/* card_rack( count, slot_depth, width, height )
 *
 * Create a card rack, sized for the share / engine cards
 *
 * count      -- Number of card slots
 * slot_depth -- How thick a stack of cards will fit in a slot
 * width      -- How wide should the rack be (~60% of width of cards)
 * height     -- How tall should the rack be?
 */
module card_rack( count=9, slot_depth=10*TILE_THICKNESS, width=1.5*inch, height=20*mm ) {

    rounding = 2*mm; // radius

    offset = [
        (height - 3*mm) / tan(60) + WALL_WIDTH[6],
        width/2 - CARD_WIDTH/2,
        3*mm
    ];

    dx = slot_depth / sin(60) + WALL_WIDTH[6];

    length = dx*count + offset.x;


    difference() {
        translate( [rounding, rounding, rounding] ) minkowski() {
            cube( [ length-2*rounding, width-2*rounding, height-2*rounding ] );
            sphere( r=rounding );
        }

        // Remove slots for cards
        for (x=[0:1:count-1]) { // Extra slot bevels the front of the rack
            translate( [offset.x+x*dx, offset.y, offset.z] )
                rotate( [0,-30, 0] )
                    cube( [ slot_depth, CARD_WIDTH, CARD_HEIGHT ] );
        }

        // Slope the front of the rack
        translate( [offset.x+count*dx, offset.y, offset.z] ) rotate( [0, -30, 0 ] )
            cube( [3*slot_depth, CARD_WIDTH, CARD_HEIGHT] );
    }
}

// ----- Testing ------------------------------------------------------------------------------------------------------

if (0) {
    CARDS = [ 2.50 * inch, 1.75 * inch, 15*mm ];
    translate( [ 5,  5, 0] ) deep_card_box( CARDS );
    translate( [ 5, -5, 0] ) deep_card_lid( CARDS );
    translate( [-5, -5, 0] ) rotate( [0, 0, 180] ) card_box( CARDS );
    translate( [-5,  5, 0] ) rotate( [0, 0, 180] ) card_lid( CARDS );
}

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
    box_size = [0,0,5];
    translate( [5, 5, 0] ) hex_box_2( hex_tile_even_rows( 2,2 ), box_size, 46, ["18XX"] );
    translate( [5,-5, 0] ) hex_lid_2( hex_tile_even_rows( 2,2 ), box_size, 46, true );
}
