OPENSCAD=/usr/bin/openscad

VERBOSE=0

STL=stl
PNG=png

models:	\
	$(STL)/outpost-card-tray-large-box.stl \
	$(STL)/outpost-card-tray-large-lid.stl \
	$(STL)/outpost-card-tray-1-box.stl \
	$(STL)/outpost-card-tray-1-lid.stl \
	$(STL)/outpost-card-tray-2-box.stl \
	$(STL)/outpost-card-tray-2-lid.stl \
	$(STL)/outpost-factories-box.stl \
	$(STL)/outpost-factories-lid.stl \
	$(STL)/outpost-tile-pick.stl \
	$(STL)/outpost-parts-box.stl \
	$(STL)/outpost-parts-lid.stl

pictures: \
	$(PNG)/outpost-card-tray-large-box.png \
	$(PNG)/outpost-card-tray-large-lid.png \
        $(PNG)/outpost-card-tray-1-box.png \
	$(PNG)/outpost-card-tray-1-lid.png \
        $(PNG)/outpost-card-tray-2-box.png \
	$(PNG)/outpost-card-tray-2-lid.png \
        $(PNG)/outpost-factories-box.png \
	$(PNG)/outpost-factories-lid.png \
	$(PNG)/outpost-tile-pick.png \
        $(PNG)/outpost-parts-box.png \
	$(PNG)/outpost-parts-lid.png

all:	directories models pictures

directories:
	mkdir -p $(STL) $(PNG)

clean:
	rm -rf $(PNG) $(STL) *.stl *.gcode *.png

# Dependencies for models

$(STL)/outpost-card-tray-large-box.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-card-tray-large-lid.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-card-tray-1-box.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-card-tray-1-lid.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=4 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-card-tray-2-box.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=5 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-card-tray-2-lid.stl: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=6 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-factories-box.stl: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-factories-lid.stl: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-tile-pick.stl: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-parts-box.stl: outpost-parts.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

$(STL)/outpost-parts-lid.stl: outpost-parts.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

# Dependencies for pictures

$(PNG)/outpost-card-tray-large-box.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-card-tray-large-lid.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-card-tray-1-box.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-card-tray-1-lid.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=4 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-card-tray-2-box.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=5 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-card-tray-2-lid.png: outpost-card-tray.scad
	$(OPENSCAD) -o $@ -DPART=6 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-factories-box.png: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-factories-lid.png: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-tile-pick.png: outpost-factories.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-parts-box.png: outpost-parts.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

$(PNG)/outpost-parts-lid.png: outpost-parts.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

