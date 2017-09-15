OPENSCAD=/usr/bin/openscad

VERBOSE=0

models:	\
	outpost-card-tray-large-box.stl outpost-card-tray-large-lid.stl \
	outpost-card-tray-1-box.stl outpost-card-tray-1-lid.stl \
	outpost-card-tray-2-box.stl outpost-card-tray-2-lid.stl \
	outpost-factories-box.stl outpost-factories-lid.stl outpost-tile-pick.stl \
	outpost-parts-box.stl outpost-parts-lid.stl

pictures: \
	outpost-card-tray-large-box.png outpost-card-tray-large-lid.png \
        outpost-card-tray-1-box.png outpost-card-tray-1-lid.png \
        outpost-card-tray-2-box.png outpost-card-tray-2-lid.png \
        outpost-factories-box.png outpost-factories-lid.png outpost-tile-pick.png \
        outpost-parts-box.png outpost-parts-lid.png

all:	models pictures

clean:
	rm -f *.stl *.gcode *.png

# Dependencies for models

outpost-card-tray-large-box.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-large-lid.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-1-box.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-1-lid.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=4 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-2-box.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=5 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-2-lid.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=6 -DVERBOSE=$(VERBOSE) $<

outpost-factories-box.stl: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

outpost-factories-lid.stl: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

outpost-tile-pick.stl: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

outpost-parts-box.stl: outpost-parts.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

outpost-parts-lid.stl: outpost-parts.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

# Dependencies for pictures

outpost-card-tray-large-box.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-large-lid.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-1-box.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-1-lid.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=4 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-2-box.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=5 -DVERBOSE=$(VERBOSE) $<

outpost-card-tray-2-lid.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=6 -DVERBOSE=$(VERBOSE) $<

outpost-factories-box.png: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

outpost-factories-lid.png: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

outpost-tile-pick.png: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

outpost-parts-box.png: outpost-parts.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

outpost-parts-lid.png: outpost-parts.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

