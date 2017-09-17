OPENSCAD=/usr/bin/openscad
OPENSCAD_OPTIONS=-DVERBOSE=0

SLIC3R=/opt/Slic3r/Slic3r-1.36.2-prusa3d-linux64-full-201707281217/slic3r
SLIC3R_OPTIONS=--load slic3r.ini --print-center 125,105

STL=stl
IMAGE=png
GCODE=gcode

PREFIX=jump-drive

PARTS=card-tray chit-tray box-lid

MODELS=$(patsubst %,$(STL)/$(PREFIX)-%.stl,$(PARTS))
IMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-%.png,$(PARTS))
GCODES=$(patsubst %,$(GCODE)/$(PREFIX)-%.gcode,$(PARTS))

all:	models gcodes images

directories:
	@mkdir -p $(STL) $(IMAGE) $(GCODE)

models: directories $(MODELS)

gcodes: directories $(GCODES)

images: directories $(IMAGES)

clean:
	rm -rf $(STL) $(GCODE) $(IMAGE)

# Dependencies for models

$(MODELS) : $(STL)/$(PREFIX)-%.stl : $(PREFIX).scad
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .stl,,$(@F)))\" $<

# Dependencies for images

$(IMAGES) : $(IMAGE)/$(PREFIX)-%.png : $(PREFIX).scad
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .png,,$(@F)))\" $<

# Dependencies for slicing

$(GCODES) : $(GCODE)/%.gcode : $(STL)/%.stl
	$(SLIC3R) -o $@ $(SLIC3R_OPTIONS) $<

