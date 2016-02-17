// 504 PART tray 
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <functions.scad>;

HINTS = true; // Set to false to render without glue-up hints

// ----- Measurements ---------------------------------------------------------

THICKNESS = 5*mm;		// Foam Core
PADDING = 3*mm;
BORDER = 1*cm;

// Widths are left-right (X)
// Depths are forward-back (Y)
// Heights are vertical (Z)

SMH_SHEET = [ 14*in, 11*in ];
SMV_SHEET = [ 11*in, 14*in ];
LGV_SHEET = [ 16*in, 20*in ];
LGH_SHEET = [ 20*in, 16*in ];

BOX_WIDTH = 36.4*cm;
BOX_DEPTH = 26.4*cm;

FULL_HEIGHT = 5.0*cm;
HALF_HEIGHT = 2.5*cm;

MAP_WIDTH = 9.6*cm;
MAP_DEPTH = BOX_DEPTH;

PLAYER_WIDTH = BOX_DEPTH / 2;
PLAYER_SHORT = PLAYER_WIDTH - THICKNESS;
PLAYER_DEPTH =  9.5*cm;
PLAYER_SLOTS1 = [ 3.5*cm, 3.2*cm, 4.5*cm ];
PLAYER_SLOTS2 = [ 2.9*cm, 1.7*cm, 2.9*cm ];

GOOD_WIDTH = PLAYER_DEPTH;
GOOD_DEPTH = ( BOX_DEPTH - PLAYER_SHORT ) / 2;

FACT_WIDTH = PLAYER_DEPTH;
FACT_DEPTH = PLAYER_DEPTH;

DICE_WIDTH = PLAYER_DEPTH;
DICE_DEPTH = BOX_DEPTH - 2*FACT_DEPTH;

CARD_WIDTH = BOX_WIDTH - (MAP_WIDTH + FACT_WIDTH + GOOD_WIDTH);
CARD_DEPTH = 12.9*cm;
CARD_SIDE  = CARD_WIDTH - 2*THICKNESS;
CARD_SLOTS = [[5,5], [15,5], [25,5], [35,5], [45,5], [55,7], [67,7], [79,15], [99,25] ];

MONEY_DEPTH = BOX_DEPTH - CARD_DEPTH;
MONEY_WIDTH = CARD_WIDTH;
TOKEN_WIDTH = 5.1*cm;
TOKEN_DEPTH = MONEY_DEPTH;
TOKEN_SHORT = 4.3*cm;

// ----- Calculated sizes -----------------------------------------------------

th = THICKNESS;
pad = PADDING;
bd = BORDER;

FULL_TRAY = FULL_HEIGHT - th;
HALF_TRAY = HALF_HEIGHT - th;

ft = FULL_TRAY;
ht = HALF_TRAY;
eps = 0.5;

// ----- Macros -----------------------------------------------------------------------------------

module plain_tray_base( w, d ) {
    difference() {
        square( [ w, d ] );
        if (HINTS) {
            translate( [th, th, 0 ] ) square( [ w-2*th, d-2*th ] );
        }
    }
}

module plain_tray_back( w, d ) {
    square( [ w, HALF_TRAY ] );
}

module plain_tray_side( w, d ) {
    square( [ d-2*th, HALF_TRAY ] );
}

module plain_tray( w, d ) {
    plain_tray_base( w, d );
    translate( [0, 1*d+0*ht+1*pad, 0] ) plain_tray_back(w,d);
    translate( [0, 1*d+1*ht+2*pad, 0] ) plain_tray_back(w,d);
    translate( [0, 1*d+2*ht+3*pad, 0] ) plain_tray_side(w,d);
    translate( [0, 1*d+3*ht+4*pad, 0] ) plain_tray_side(w,d);
}

function plain_tray_x( w, d ) = w + 2*pad;
function plain_tray_y( w, d ) = d + 4*ht + 6*pad;

// ----- Player Trays -----------------------------------------------------------------------------

module player_base( short=false ) {
    pw = PLAYER_WIDTH;
    pd = PLAYER_DEPTH;
    ps1 = PLAYER_SLOTS1;
    ps2 = PLAYER_SLOTS2;
    offset = short ? th : 0;

    difference() {
        square( [ pw-offset, pd ] );
        if (HINTS) {
            translate( [1*th,               1*th,               0] ) square( [ ps1[0], pd-2*th ] );
            translate( [2*th+ps1[0],        1*th,               0] ) square( [ ps1[1], ps2[0] ] );
            translate( [2*th+ps1[0],        2*th+ps2[0],        0] ) square( [ ps1[1], ps2[1] ] );
            translate( [2*th+ps1[0],        3*th+ps2[0]+ps2[1], 0] ) square( [ ps1[1], ps2[2] ] );
            translate( [3*th+ps1[0]+ps1[1], 1*th,               0] ) square( [ ps1[2]-offset, pd-2*th ] );
        }
    }
}

module player_back( short=false ) {
    offset = short ? th : 0;
    square( [ PLAYER_WIDTH-offset, HALF_TRAY ] );
}

module player_side( ) {
    square( [ HALF_TRAY, PLAYER_DEPTH-2*th ] );
}

module player_inner1( ) {
    square( [ PLAYER_SLOTS1[1], HALF_TRAY ] );
}

module player_inner2( ) {
    square( [ PLAYER_SLOTS1[1], HALF_TRAY-th ] );
}

module player_set( short=false ) {
    pw = PLAYER_WIDTH;
    pd = PLAYER_DEPTH;
    ps1 = PLAYER_SLOTS1;
    ps2 = PLAYER_SLOTS2;

    translate( [0, 0, 0] ) player_base( short );
    
    translate( [0, 1*pd+0*ht+1*pad, 0] ) player_back( short );
    translate( [0, 1*pd+1*ht+2*pad, 0] ) player_back( short );
    
    translate( [1*pw+0*ht+1*pad, 1*th, 0 ] ) player_side( ); 
    translate( [1*pw+1*ht+2*pad, 1*th, 0 ] ) player_side( ); 
    translate( [1*pw+2*ht+3*pad, 1*th, 0 ] ) player_side( ); 
    translate( [1*pw+3*ht+4*pad, 1*th, 0 ] ) player_side( );
    
    translate( [1*pw+0*ht+1*pad, 1*pd+1*pad, 0 ] ) player_inner1( );
    translate( [1*pw+0*ht+1*pad, 1*pd+1*ht+2*pad, 0 ] ) player_inner2( );
}

// ----- Map Tile Tray ----------------------------------------------------------------------------

module map_base() {
    s = ( MAP_DEPTH - 4*th ) / 3;
    difference() {
        square( [MAP_WIDTH,MAP_DEPTH] );
        if (HINTS) {
            translate( [1*th,1*th+0*s,0] ) square( [MAP_WIDTH-th-eps,s] );
            translate( [1*th,2*th+1*s,0] ) square( [MAP_WIDTH-th-eps,s] );
            translate( [1*th,3*th+2*s,0] ) square( [MAP_WIDTH-th-eps,s] );
        }
    }
}

module map_back() {
    s = ( MAP_DEPTH - 4*th ) / 3;
    difference() {
        square( [ FULL_TRAY, MAP_DEPTH] );
        if (HINTS) {
            translate( [eps,1*th+0*s,0] ) square( [ft-2*eps,s] );
            translate( [eps,2*th+1*s,0] ) square( [ft-2*eps,s] );
            translate( [eps,3*th+2*s,0] ) square( [ft-2*eps,s] );
        }
    }
}

module map_side() {
    square( [ FULL_TRAY, MAP_WIDTH-th ] );
}

module map_set() {
    mw = MAP_WIDTH;
    md = MAP_DEPTH;
    
    map_base();
    translate( [1*mw+1*pad,0,0] ) map_back();
    place( [0*ft+0*pad,1*md+0*mw+1*pad,0] ) map_side();
    place( [0*ft+0*pad,1*md+1*mw+1*pad,0] ) map_side();
    place( [1*ft+1*pad,1*md+0*mw+1*pad,0] ) map_side();
    place( [1*ft+1*pad,1*md+1*mw+1*pad,0] ) map_side();
}

map_x = MAP_WIDTH + 1*ft + 3*pad;
map_y = MAP_DEPTH + 2 * MAP_WIDTH + 4*pad;

// ----- Cards Tray -------------------------------------------------------------------------------

module card_base() {
    difference() {
        square( [ CARD_WIDTH, CARD_DEPTH ] );
        if (HINTS) {
            for ( slot = CARD_SLOTS ) {
                translate( [th, slot[0], 0] ) square( [CARD_WIDTH-th-eps, slot[1]] );
            }
        }
    }
}

module card_back() {
    difference() {
        square( [ ft, CARD_DEPTH ] );
        if (HINTS) {
            for ( slot = CARD_SLOTS ) {
                translate( [eps, slot[0], 0] ) square( [ft-2*eps, slot[1]] );
            }
        }
    }    
}

module card_side() {
    sw = CARD_SIDE;
    polygon( [[0,0], [0,ft], [ sw/2, ft ], [sw,ft/3], [sw,0]]);
}

module card_side_set() {
    cs = CARD_SIDE;
    
    translate( [0*cs+0*pad,0*ft+0*pad,0]) card_side();
    translate( [1*cs+1*pad,0*ft+0*pad,0]) card_side();
    translate( [2*cs+2*pad,0*ft+0*pad,0]) card_side();
    translate( [3*cs+3*pad,0*ft+0*pad,0]) card_side();
    translate( [4*cs+4*pad,0*ft+0*pad,0]) card_side();
    translate( [0*cs+0*pad,1*ft+1*pad,0]) card_side();
    translate( [1*cs+1*pad,1*ft+1*pad,0]) card_side();
    translate( [2*cs+2*pad,1*ft+1*pad,0]) card_side();
    translate( [3*cs+3*pad,1*ft+1*pad,0]) card_side();
    translate( [4*cs+4*pad,1*ft+1*pad,0]) card_side();
}

module card_set() {
    cw = CARD_WIDTH;
    cd = CARD_DEPTH;
    
    card_base();
    translate( [cw+0*ft+1*pad,0,0]) card_back();
    translate( [cw+1*ft+2*pad,0,0]) card_side_set();
}

// ----- Money / Token Trays ----------------------------------------------------------------------

module money_base() {
    mw = MONEY_WIDTH;
    md = MONEY_DEPTH;
    tw = TOKEN_WIDTH;
    ts = TOKEN_SHORT;
    xw = mw-tw;
    
    difference() {
        square( [ mw, md ] );
        if (HINTS) {
            translate( [th,        th,0] ) square( [xw-th,md-2*th] );
            translate( [xw+th,     th,0] ) square( [tw-2*th,ts] );
            translate( [xw+th,ts+2*th,0] ) square( [tw-2*th,md-ts-3*th] );
        }
    }
}

module money_side() {
    mw = MONEY_WIDTH;
    md = MONEY_DEPTH;
    tw = TOKEN_WIDTH;
    ts = TOKEN_SHORT;
    xw = mw-tw;
    
    polygon([[0,0],[0,ft],[xw,ft],[xw,ht],[mw,ht],[mw,0]]);
}

module money_back() {
    square( [ft,MONEY_DEPTH-2*th] );
}

module money_front() {
    square( [ht,MONEY_DEPTH-2*th] );
}

module token_base() {
    tw = TOKEN_WIDTH;
    td = TOKEN_DEPTH;
    ts = TOKEN_SHORT;
    
    difference() {
        square( [TOKEN_WIDTH, TOKEN_DEPTH] );
        if (HINTS) {
            translate( [th,      th,0] ) square( [tw-2*th,ts] );
            translate( [th, ts+2*th,0] ) square( [tw-2*th,td-ts-3*th] );
        }
    }
}

module token_back() {
    square( [ht, TOKEN_DEPTH] );
}

module token_side() {
    square( [TOKEN_WIDTH-2*th,ht] );
}

module money_set() {
    mw = MONEY_WIDTH;
    md = MONEY_DEPTH;
    tw = TOKEN_WIDTH;
    ts = TOKEN_SHORT;
    xw = mw-tw;
    
    money_base();
    translate( [mw+0*ht+1*pad,th,0] ) money_front();
    translate( [mw+1*ht+2*pad,th,0] ) money_front();
    
    translate( [0,md+0*ft+1*pad,0] ) money_side();
    translate( [0,md+1*ft+2*pad,0] ) money_side();
    translate( [xw+th,md+2*ft+3*pad,0] ) token_side();
    
    translate( [mw+pad,md+pad,0] ) money_back();

    translate( [mw+2*ht+5*pad,0,0] ) token_base();
    translate( [mw+tw+2*ht+6*pad,0,0] ) token_back();
    translate( [mw+tw+3*ht+7*pad,0,0] ) token_back();

    translate( [mw+2*ht+5*pad+th,md+0*ht+1*pad,0] ) token_side();
    translate( [mw+2*ht+5*pad+th,md+1*ht+2*pad,0] ) token_side();
    translate( [mw+2*ht+5*pad+th,md+2*ht+3*pad,0] ) token_side();    
}


// ----- Cut Parts View ---------------------------------------------------------------------------

card_y = CARD_WIDTH;
card_s = 5 * CARD_SIDE + 5*pad;
play_x = PLAYER_WIDTH + 4*ht + 6*pad;
play_y = PLAYER_DEPTH + 2*ht + 4*pad;
good_x = plain_tray_x( GOOD_WIDTH, GOOD_DEPTH );
good_y = plain_tray_y( GOOD_WIDTH, GOOD_DEPTH );
fact_x = plain_tray_x( FACT_WIDTH, FACT_DEPTH );
fact_y = plain_tray_y( FACT_WIDTH, FACT_DEPTH );
dice_x = plain_tray_x( DICE_WIDTH, DICE_DEPTH );
dice_y = plain_tray_y( DICE_WIDTH, DICE_DEPTH );

module sheet_1() {
    % square( LGH_SHEET );
    place( [bd+0*play_x,bd+0*play_y,0], 0, "purple" ) player_set();
    place( [bd+0*play_x,bd+1*play_y,0], 0, "teal" )   player_set();
    place( [bd+1*play_x,bd+0*play_y,0], 0, "green" )  player_set();
    place( [bd+1*play_x,bd+1*play_y,0], 0, "tan" )    player_set();
    
    place( [bd+0*play_x,bd+2*play_y,0], 0, "coral" )          card_side_set();
    place( [bd+1*card_s,bd+2*play_y+card_y,0], -90, "coral" ) card_base();
}

module sheet_2() {
    % square( SMV_SHEET );
    place( [bd+0*play_x,bd+0*play_y,0], 0, "orange" ) player_set( true );
    place( [bd+0*play_x,bd+1*play_y,0], 0, "red" ) plain_tray( DICE_WIDTH, DICE_DEPTH );
}

module sheet_3() {
    % square( LGH_SHEET );
    place( [bd+0*fact_x,bd+1*map_x-2*pad,0], -90, "olive" ) map_set();
    place( [bd+0*fact_x,bd+1*map_x+0*pad,0], 0, "plum" ) plain_tray( FACT_WIDTH, FACT_DEPTH );
    place( [bd+1*fact_x,bd+1*map_x+0*pad,0], 0, "plum" ) plain_tray( FACT_WIDTH, FACT_DEPTH );
    place( [bd+2*fact_x,bd+1*map_x+0*pad,0], 0, "pink" ) plain_tray( GOOD_WIDTH, GOOD_DEPTH );
    place( [bd+3*fact_x,bd+1*map_x+0*pad,0], 0, "pink" ) plain_tray( GOOD_WIDTH, GOOD_DEPTH );
    place( [bd+MAP_DEPTH+4*pad,bd+ft,0], -90, "coral" ) card_back();
}

module sheet_4() {
    % square( SMV_SHEET );
    place( [bd,bd,0], 0, "navy" ) money_set();
}

module all_sheets() {
place( [  0,  0,0] ) sheet_1();
place( [525,  0,0] ) sheet_2();
place( [  0,450,0] ) sheet_3();
place( [525,450,0] ) sheet_4();
}

// ------------------------------------------------------------------------------------------------
// ----- Rendered PART ----------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------
all_sheets();