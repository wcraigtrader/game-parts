# Brass: Lancashire and Brass: Birmingham
#
# by W. Craig Trader is dual-licensed under
# Creative Commons Attribution-ShareAlike 3.0 Unported License and
# GNU Lesser GPL 3.0 or later.
#
# This makefile expects an OpenSCAD file named $(PREFIX).scad that defines
# the following variables:
#
# PART    -- the name of a part to generate
# VERBOSE -- logically true if you want verbose output (optional)
#
# The OpenSCAD program should have logic that renders a single part by name:
#
# if (PART == "foo") {
#     foo();
# } else if (PART == "bar") {
#     bar();
# } else if (PART == "foo-bar") {
#     foo_bar();
# }
#
# This makefile will use OpenSCAD to create individual model (STL) files and
# image (PNG) files for each declared part
#
# So if PREFIX=widget, then the created files will be:
#
# stl/widget-foo.stl stl/widget-bar.stl stl/widget-foo-bar.stl
# png/widget-foo.png png/widget-bar.png png/widget-foo-bar.png

# Name of OpenSCAD model file
PREFIX=tm

# ----- Local OpenSCAD settings -----------------------------------------------

# OpenSCAD binary and options
OPENSCAD=/opt/openscad
OPENSCAD_OPTIONS=-DVERBOSE=false
IMAGE_OPTIONS=--imgsize=1024,768 --colorscheme=DeepOcean

# ----- Everything after this should not need modification --------------------

# Scripts
EXPAND=../bin/scad-expand.py
DEPEND=../bin/scad-dependencies.py

# Names of parts to build
PARTS=$(shell grep 'PART == ' $(PREFIX).scad | cut -d'"' -f2)
SOURCES=$(shell $(DEPEND) $(PREFIX).scad)

STL=stl
IMAGE=png

MODELS=$(patsubst %,$(STL)/$(PREFIX)-%.$(STL),$(PARTS))
IMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-%.$(IMAGE),$(PARTS))
ALLIN1=$(PREFIX)-all.scad


all:	models images $(ALLIN1)

directories:
	@mkdir -p $(STL) $(IMAGE)

models: directories $(MODELS)

images: directories $(IMAGES)

clean:
	rm -f $(STL)/$(PREFIX)-* $(IMAGE)/$(PREFIX)-* $(ALLIN1)

cleanall:
	rm -rf $(STL) $(IMAGE) $(ALLIN1)

# Dependencies for models

$(MODELS) : $(STL)/$(PREFIX)-%.$(STL) : $(SOURCES)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(STL),,$(@F)))\" $<

# Dependencies for images

$(IMAGES) : $(IMAGE)/$(PREFIX)-%.$(IMAGE) : $(SOURCES)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(IMAGE),,$(@F)))\" $(IMAGE_OPTIONS) $<

# Dependencies for all-in-1
$(ALLIN1) : $(SOURCES)
	$(EXPAND) $(PREFIX).scad $(ALLIN1)

