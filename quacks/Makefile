# The Quacks of Quedlinburg
# by W. Craig Trader
#
# --------------------------------------------------------------------------------------------------------------------
#
# This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
# To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
# or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
#
# --------------------------------------------------------------------------------------------------------------------
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
PREFIX=quacks

# ----- Everything after this should not need modification

# Names of parts to build
PARTS=$(shell grep 'PART == ' $(PREFIX).scad | cut -d'"' -f2)

STL=stl
IMAGE=png

MODELS=$(patsubst %,$(STL)/$(PREFIX)-%.$(STL),$(PARTS))
IMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-%.$(IMAGE),$(PARTS))
EXTRAS=../util/boxes.scad

all:	models images

directories:
	@mkdir -p $(STL) $(IMAGE)

models: directories $(MODELS)

images: directories $(IMAGES)

clean:
	rm -f $(STL)/$(PREFIX)-* $(IMAGE)/$(PREFIX)-*

cleanall:
	rm -rf $(STL) $(IMAGE)

# Dependencies for models

$(MODELS) : $(STL)/$(PREFIX)-%.$(STL) : $(PREFIX).scad $(EXTRAS)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(STL),,$(@F)))\" $<

# Dependencies for images

$(IMAGES) : $(IMAGE)/$(PREFIX)-%.$(IMAGE) : $(PREFIX).scad $(EXTRAS)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(IMAGE),,$(@F)))\" $(IMAGE_OPTIONS) $<

