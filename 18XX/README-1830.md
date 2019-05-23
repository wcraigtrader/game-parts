After using my original design for several months, I decided to refactor my designs and add some features to improve the usability of the boxes:

1. **Rounded boxes** -- All of the boxes now use rounded corners and edges that make them more comfortable to use.
1. **Locking lids** -- All of the boxes now use press-fit lids that are easy to separate, but lock into place, to keep from accidently spilling the tiles.
1. **Redesigned hex boxes** -- The redesigned hex boxes and lids engage to keep tiles from sliding, but don't interfere with opening or closing the boxes.
1. **Redesigned token boxes** -- now with fillets in the compartments, for easier access.
1. **Smaller boxes **-- the newer box designs are easier to remove from the game boxes.
1. **Refactored models** -- now it's much faster and easier to create designs for new games.

I will leave the old models up for posterity and comparison, but strongly suggest using the newer models.

***

After I made my [tile organizer trays for 1846](/thing:2875248) the first thing that people asked was "Will they work for 1830"? Well, as it happens, no they won't because the 1830 box is smaller, and the 1830 tiles are smaller. So I went back to my design room, and refactored the OpenSCAD source files so that I could make trays for 1846 and 1830.

Unlike 1846, 1830 uses cardstock instead of tile stock. The design I used for 1846 wasn't tight enough to keep the tiles from sliding from one stack to the next, so I added interlocking stubs to the lids that overlap the pillars in the tray. This keeps the tiles in their assigned spots, and provides a nice _snap_ that keeps the lid from slipping off.

I put all of the yellow tiles in one tray, 12 of the green tiles in the second tray, the rest of the green tiles and 8 of the brown tiles in the third tray, and the rest of the brown tiles in the last tray.

Total items to print:

| Model | Qty | Description |
| ----- | --- | ----------- |
| 1830-tile-tray.stl | 4 | Tile tray that holds up to 12 tiles per stack |
| 1830-tile-lid.stl | 4 | Lid for tile trays |
| 1830-token-box.stl | 1 | Box to hold all the tokens |
| 1830-token-box-lid.stl | 1 | Lid for token box |

My (used) copy of 1830 has no box inserts, so there's plenty of space in the box for these trays. I recommend putting them in the box first, then adding the map, rules, and the rest of the game components.These are sized to fit the box and track tiles from the Avalon Hill version of 1830. I don't have a copy of the Mayfair version, so I don't know if they'll fit that. If you want trays for the Mayfair version, contact me and we'll work something out.

I've added a PDF that shows how I arrange my tiles, in case it wasn't clear from the photos. You are, of course, free to use these as you like.

Full sources on [GitHub](https://github.com/wcraigtrader/game-parts/tree/master/18XX).

**Revision History:**

August 2018, Initial version.
April-May 2019, Complete redesign of models.