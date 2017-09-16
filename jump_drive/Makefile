OPENSCAD=/usr/bin/openscad

VERBOSE=0

STL=stl
PNG=png

all:	directories models pictures

directories:
	mkdir -p $(STL) $(PNG)

models: \
	$(STL)/jump-drive-card-tray.stl \
	$(STL)/jump-drive-chit-tray.stl \
	$(STL)/jump-drive-box-lid.stl

pictures: \
	$(PNG)/jump-drive-card-tray.png \
	$(PNG)/jump-drive-chit-tray.png \
	$(PNG)/jump-drive-box-lid.png

clean:
	rm -f $(STL)/*.stl *.stl $(STL)/*.gcode *.gcode 
	rm -f $(PNG)/*.png *.png

# Dependencies for models

$(STL)/jump-drive-card-tray.stl: jump-drive.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

$(STL)/jump-drive-chit-tray.stl: jump-drive.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

$(STL)/jump-drive-box-lid.stl: jump-drive.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

# Dependencies for pictures

$(PNG)/jump-drive-card-tray.png: jump-drive.scad
	$(OPENSCAD) -o $@ -DPART=1 -DVERBOSE=$(VERBOSE) $<

$(PNG)/jump-drive-chit-tray.png: jump-drive.scad
	$(OPENSCAD) -o $@ -DPART=2 -DVERBOSE=$(VERBOSE) $<

$(PNG)/jump-drive-box-lid.png: jump-drive.scad
	$(OPENSCAD) -o $@ -DPART=3 -DVERBOSE=$(VERBOSE) $<

