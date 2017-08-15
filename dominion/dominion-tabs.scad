// Laser cut Dominion Card tabs
//
// by W. Craig Trader is dual-licensed under 
// Creative Commons Attribution-ShareAlike 3.0 Unported License and
// GNU Lesser GPL 3.0 or later.

include <MCAD/units.scad>;

CARD_HEIGHT = 100 * mm;
CARD_WIDTH  = 176/3 * mm; 
LABEL_HEIGHT =  9 * mm;
LABEL_WIDTH  = 40 * mm;
PAGE_HEIGHT = 11 * inch;
PAGE_WIDTH  = 8.5 * inch;

// --------------------------------------------------------------------------------

px = PAGE_WIDTH;
py = PAGE_HEIGHT;

ox = (px - 3 * CARD_WIDTH) / 2;
oy = 40 * mm;

dx = 0.02 * mm;
dy = 0.02 * mm;

x0 = dx;
x1 = LABEL_WIDTH;
x2 = CARD_WIDTH - LABEL_WIDTH;
x3 = CARD_WIDTH - dx;

y0 = dy;
y1 = CARD_HEIGHT - LABEL_HEIGHT;
y2 = CARD_HEIGHT - dy;

left_tab = [ [x0,y0], [x0,y2], [x1,y2], [x1,y1], [x3,y1], [x3,y0] ];
right_tab = [ [x0,y0], [x0,y1], [x2,y1], [x2,y2], [x3,y2], [x3,y0] ];

module square_tabs_old() {
    union() {
        difference() {
			square( [px,py] );
        
            translate( [0*x3+ox,1*y2+oy] ) polygon( points=left_tab );
            translate( [1*x3+ox,1*y2+oy] ) polygon( points=right_tab );
            translate( [2*x3+ox,1*y2+oy] ) polygon( points=left_tab );
    
            translate( [0*x3+ox,0*y2+oy] ) polygon( points=right_tab );
            translate( [1*x3+ox,0*y2+oy] ) polygon( points=left_tab );
            translate( [2*x3+ox,0*y2+oy] ) polygon( points=right_tab );
        }
    }
}

module square_tabs_l() {
	union() {
		translate( [x0,y0] ) square( [x3-x0,y1-y0] );
		translate( [x0,y1] ) square( [x1,y2-y1] );
	}
}

module square_tabs_r() {
	union() {
		translate( [x0,y0] ) square( [x3-x0,y1-y0] );
		translate( [x2,y1] ) square( [x3-x2,y2-y1] );
	}
}

module square_tabs() {
	difference() {
		square( [px,py] );

        translate( [0*x3+ox,1*y2+oy] ) square_tabs_l();
        translate( [1*x3+ox,1*y2+oy] ) square_tabs_r();
        translate( [2*x3+ox,1*y2+oy] ) square_tabs_l();

        translate( [0*x3+ox,0*y2+oy] ) square_tabs_r();
        translate( [1*x3+ox,0*y2+oy] ) square_tabs_l();
        translate( [2*x3+ox,0*y2+oy] ) square_tabs_r();
	}
}

square_tabs_old();
