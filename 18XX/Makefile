# 18XX: Organizing trays for tiles and other components
#
# by W. Craig Trader is dual-licensed under
# Creative Commons Attribution-ShareAlike 3.0 Unported License and
# GNU Lesser GPL 3.0 or later.

# Override PREFIX on the command line to select the parts to produce.
#
#     make all PREFIX=1830
#     make all PREFIX=1846
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

# OpenSCAD binary and options
OPENSCAD=/usr/bin/openscad
OPENSCAD_OPTIONS=-DVERBOSE=false
IMAGE_OPTIONS=--imgsize=1024,768 --colorscheme=DeepOcean


# Name of OpenSCAD model file
PREFIX=1830

# ----- Everything after this should not need modification

# Names of parts to build
PARTS=$(shell grep 'PART == ' $(PREFIX).scad | cut -d'"' -f2)

STL=stl
IMAGE=png

MODELS=$(patsubst %,$(STL)/$(PREFIX)-%.$(STL),$(PARTS))
IMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-%.$(IMAGE),$(PARTS))
EXTRAS=18XX.scad

all:	models images

directories:
	@mkdir -p $(STL) $(IMAGE)

models: directories $(MODELS)

images: directories $(IMAGES)

clean:
	rm $(STL)/$(PREFIX)-* $(IMAGE)/$(PREFIX)-*

cleanall:
	rm -rf $(STL) $(IMAGE)

# Dependencies for models

$(MODELS) : $(STL)/$(PREFIX)-%.$(STL) : $(PREFIX).scad $(EXTRAS)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(STL),,$(@F)))\" $<

# Dependencies for images

$(IMAGES) : $(IMAGE)/$(PREFIX)-%.$(IMAGE) : $(PREFIX).scad $(EXTRAS)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(IMAGE),,$(@F)))\" $(IMAGE_OPTIONS) $<

