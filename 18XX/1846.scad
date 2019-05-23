// 1846: The Race for the Midwest
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

// Command Line Arguments
PART = "other";           // Which part to output
VERBOSE = true;           // Set to non-zero to see more data

// Box dimensions
BOX_HEIGHT      = 11.5 * inch;
BOX_WIDTH       =  8.5 * inch;
BOX_DEPTH       =  3.0 * inch;

// Tile dimensions
TILE_DIAMETER   = 50.0 * mm;
TILE_THICKNESS  =  3.0 * mm;
POKE_HOLE       = 40.0 * mm;    // Diameter of poke holes in bottom

// Inner well dimensions
WELL_DEPTH      = 1.25 * inch;
WELL_HEIGHT     = 5.50 * inch;
WELL_WIDTH      = BOX_WIDTH;

// Card dimensions
CARD_WIDTH      = 2.50 * inch;
CARD_HEIGHT     = 1.75 * inch;

COMPANY_CARDS   =  3.4 * mm;
TRAIN_CARDS     = 10.6 * mm; // (9) Yel, (6) Grn, (5) Brn, (9) Sil
OTHER_CARDS     =  5.9 * mm; // (10 + 5 + 1)

// Marker dimensions
MARK_DIAMETER   = 9/16 * inch;
MARK_THICKNESS  = 3.0 * mm;
MARK_MAX        = 10;

// Poker chip dimensions
CHIP_DIAMETER   = 41 * mm;
CHIP_THICKNESS  = 3.31 * mm;

LIP     = 5.00 * mm;
SHIFTING = 1.00 * mm;    // Room for tiles to shift

include <18XX.scad>;

// ----- Functions ----------------------------------------------------------------------------------------------------

function tile_height( count ) = count * TILE_THICKNESS;
function half_box_size( count ) = [BOX_WIDTH, 5.5*inch, layer_height( count*TILE_THICKNESS ) ];

// ----- Modules ------------------------------------------------------------------------------------------------------

module tile_box( count=5 ) {
    hex_box_2( hex_tile_even_rows( 3, 4 ), half_box_size( count ), TILE_DIAMETER, [ "V2", "1846" ] );
}

module tile_lid( count=5 ) {
    hex_lid_2(  hex_tile_even_rows( 3, 4 ), half_box_size( count ), TILE_DIAMETER, false, true );
}

module card_box_1( dimensions=REASONABLE ) {
    bottom = dimensions[BOTTOM];
    
    x1 = ceil( MARK_DIAMETER+SHIFTING );
    x2 = ceil( CARD_WIDTH + 2*SHIFTING );

    box = [
        WIDE_WALL + x1 + THIN_WALL + x2 + WIDE_WALL,
        floor( WELL_WIDTH / 4),
        ceil( max( COMPANY_CARDS, OTHER_CARDS, MARK_DIAMETER ) )
    ];

    dy = box.y - 2*WIDE_WALL;
    mz = x1 / 2;

    ho = 10 * mm;
    hx = x2 - 2*ho;
    hy = dy - 2*ho;

    lip = 6 * mm; // 7 * mm; //

    if (VERBOSE) {
        echo( CardBox=box, MinCardBoxY=CARD_HEIGHT+2*WIDE_WALL );
        echo( WellDepth=WELL_DEPTH, x1=x1, x2=x2, dy=dy, mz=mz );
        echo( hx=hx, hy=hy, diagonal=sqrt( hx*hx + hy*hy), CardWidth=CARD_WIDTH );
    }

    difference() {
        // Box
        cube( box );

        // Markers
        translate( [ WIDE_WALL+mz, 2*WIDE_WALL, bottom+mz] ) rotate( [-90,0,0] ) cylinder( r=mz, h=dy-2*WIDE_WALL, center=false );
        translate( [ WIDE_WALL, WIDE_WALL, bottom+mz-OVERLAP] ) cube( [x1, dy, box.z] );

        // Cards
        translate( [ WIDE_WALL+x1+THIN_WALL, WIDE_WALL, bottom] ) cube( [x2, dy, box.z+OVERLAP] );

        // Lip
        translate( [ WIDE_WALL, WIDE_WALL, box.z-lip] ) cube( [x1+THIN_WALL+x2, WIDE_WALL, lip+OVERLAP] );
        translate( [ WIDE_WALL, box.y-2*WIDE_WALL, box.z-lip] ) cube( [x1+THIN_WALL+x2, WIDE_WALL, lip+OVERLAP] );

        // Finger Hole
        translate( [ WIDE_WALL + x1 + THIN_WALL + ho, WIDE_WALL + ho, -OVERLAP] ) cube( [ hx, hy, box.z+2*OVERLAP ] );
    }
}

module card_lid_1() {
    x1 = ceil( MARK_DIAMETER+SHIFTING );
    x2 = ceil( CARD_WIDTH + 2*SHIFTING );

    bx = WIDE_WALL + x1 + THIN_WALL + x2 + WIDE_WALL;
    by = floor( WELL_WIDTH / 4); // AKA CARD_HEIGHT plus something
    bz = ceil( max( COMPANY_CARDS, OTHER_CARDS, MARK_DIAMETER ) ) + TOP;

    dx = bx - 2*WIDE_WALL;
    dy = by - 2*WIDE_WALL;

    ho = 10 * mm;
    hx = dx - 2*ho;
    hy = dy - 2*ho;

    difference() {
        union() {
            cube( [bx, by, TOP] );
            translate( [ 2*WIDE_WALL, WIDE_WALL+GAP, TOP-OVERLAP] ) cube( [dx-2*WIDE_WALL, THIN_WALL, LIP+OVERLAP] );
            translate( [ 2*WIDE_WALL, by-WIDE_WALL-THIN_WALL-GAP, TOP-OVERLAP] ) cube( [dx-2*WIDE_WALL, THIN_WALL, LIP+OVERLAP] );
        }

    translate( [ WIDE_WALL + ho, WIDE_WALL + ho, -OVERLAP] ) cube( [ hx, hy, bz+2*OVERLAP ] );
    }
}

cx1 = MARK_DIAMETER + SHIFTING;
cx2 = CARD_WIDTH + 2*SHIFTING;
cy = floor( WELL_WIDTH/4 ) - 4*WALL_WIDTH[3] - 2*GAP; // CARD_HEIGHT + 2*SHIFTING;
cz = layer_height( max( COMPANY_CARDS, OTHER_CARDS, MARK_DIAMETER ) );

CARD_CELLS = [ [ [cx1, cy], [cx2, cy] ] ];

if (VERBOSE) {
    echo( CardSize = [ CARD_WIDTH, CARD_HEIGHT ], Cells=CARD_CELLS );
}

module card_box_2( dimensions=REASONABLE ) {
    inner  = dimensions[INNER];
    bottom = dimensions[BOTTOM];

    inside = [
        row_length( CARD_CELLS, inner ),
        col_length( CARD_CELLS, inner ),
        cz
    ];

    window = [ CARD_CELLS[0][1][0]-20, CARD_CELLS[0][1][1]-20, bottom+4*OVERLAP ];

    difference() {
        cell_box( CARD_CELLS, cz, ROUNDED);
        translate( [ inside.x-window.x-10, inside.y-window.y-10, -bottom-2*OVERLAP ] ) cube( window );
    }
}

module card_lid_2( dimensions=REASONABLE ) {
    inner  = dimensions[INNER];
    top    = dimensions[TOP];

    inside = [
        row_length( CARD_CELLS, inner ),
        col_length( CARD_CELLS, inner ),
        cz
    ];

    window = [ inside.x-20, inside.y-20, top+2*OVERLAP ];

    difference() {
        cell_lid( CARD_CELLS, cz );
        translate( [ 10, 10, -top-OVERLAP ] ) cube( window );
    }
}

module card_box_3( dimensions=REASONABLE ) {
    inner  = dimensions[INNER];
    bottom = dimensions[BOTTOM];
    
    inside = [
        MARK_DIAMETER + SHIFTING + inner + CARD_WIDTH + 2 * SHIFTING,
        floor( WELL_WIDTH/4 ) - 4*WALL_WIDTH[3] - 2*GAP,
        layer_height( max( COMPANY_CARDS, OTHER_CARDS, MARK_DIAMETER ) )
    ];
            
    marker_radius = (MARK_DIAMETER + SHIFTING) / 2;
    
    window = [ inside.x-20-2*marker_radius-inner, inside.y-20, bottom+2*OVERLAP ];
    
    difference() {
        union() {
            // Start with a hollow box
            rounded_box( inside, HOLLOW );
            
            // Add a marker rack
            difference() {
                cube( [MARK_DIAMETER + SHIFTING, inside.y, marker_radius] );
                translate( [marker_radius, 0, marker_radius] )  rotate( [-90,0,0] ) cylinder( r=marker_radius, h = inside.y, center=false );
            }
            
            // Add a divider
            translate( [2*marker_radius, 0, 0] ) cube( [inner, inside.y, inside.z*0.75] );
        }
        
        // Remove a finger hole
        translate( [inside.x-window.x-10, 10, -bottom-OVERLAP] ) cube( window );
    }

}

module card_lid_3( dimensions=REASONABLE ) {
    inner  = dimensions[INNER];
    top    = dimensions[TOP];
    
    inside = [
        MARK_DIAMETER + SHIFTING + inner + CARD_WIDTH + 2 * SHIFTING,
        floor( WELL_WIDTH/4 ) - 4*WALL_WIDTH[3] - 2*GAP,
        layer_height( max( COMPANY_CARDS, OTHER_CARDS, MARK_DIAMETER ) )
    ];
    
    marker_radius = (MARK_DIAMETER + SHIFTING) / 2;
    
    window = [ inside.x-20-2*marker_radius-inner, inside.y-20, top+2*OVERLAP ];
    
    difference() {
        rounded_lid( inside );
        translate( [inside.x-window.x-10, 10, -top-OVERLAP] ) cube( window );
    }
}


module card_plate() {
    translate( [ 3,85,0] ) rotate( [0,0,-90] ) card_box_3();
    translate( [60,85,0] ) rotate( [0,0,-90] ) card_lid_3();
}

// ----- Rendering ----------------------------------------------------------------------------------------------------

if (PART == "short-tile-tray") {            // bom: 2 | short tile tray |
    tile_box( 2 );
} else if (PART == "tall-tile-tray") {      // bom: 2 | tall tile tray |
    tile_box( 5 );
} else if (PART == "short-tile-lid") {      // bom: 2 | short tile tray lid |
    tile_lid( 2 );
} else if (PART == "tall-tile-lid") {       // bom: 2 | tall tile tray lid |
    tile_lid( 5 );
} else if (PART == "card-box") {            // bom: 8 | card box |
    card_box_3();
} else if (PART == "card-lid") {            // bom: 8 | card box lid |
    card_lid_3();
} else if (PART == "card-plate") {
    card_plate();
} else {
    translate( [-5, -5, 0] ) rotate( [0,0,180] ) tile_box( 5 );
    translate( [-5,  5, 0] ) rotate( [0,0,180] ) tile_lid( 5 );
    
    translate( [55,  5, 0] ) rotate( [0,0,90] ) card_box_3();
    translate( [55,-87, 0] ) rotate( [0,0,90] ) card_lid_3();
}
