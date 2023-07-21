include <../util/boxes.scad>;

// ----- Command Line Arguments ---------------------------------------------------------------------------------------

PART = "other";           // Which part to output
VERBOSE = true;           // Set to non-zero to see more data

// ----- Physical Measurements ----------------------------------------------------------------------------------------

height = 1.5*cm;

beads  = [ 7*cm, 7*cm, height ];
plant  = [ 7.25*cm, 7.25*cm ];
bill   = [ 4.75*cm, 9.25*cm ];
player = [ 7*cm, 6*cm, height ];

deck = [
    [ plant, plant ]
];

money = [
    [ bill, bill, bill ]
];

resources = [
    [ [ 7*cm, 6*cm], [7*cm, 6*cm] ],
    [ [10*cm, 6*cm], [4*cm, 6*cm] ],
];

if (PART == "player-lid") {
    rounded_lid(player);
} else if (PART == "player-box") {
    rounded_box(player);
} else if (PART == "bead-lid") {
    rounded_lid(beads);
} else if (PART == "bead-box") {
    rounded_box(beads);
} else if (PART == "deck-box") {
    cell_box(deck, height, ROUNDED, true);
} else if (PART == "deck-lid") {
    cell_lid(deck, height, ROUNDED, true);
} else if (PART == "money-box") {
    cell_box(money, height, ROUNDED, true);
} else if (PART == "money-lid") {
    cell_lid(money, height, ROUNDED, true);
} else if (PART == "resources-box") {
    cell_box(resources, height, ROUNDED, false);
} else if (PART == "resources-lid") {
    cell_lid(resources, height, ROUNDED, false);
}