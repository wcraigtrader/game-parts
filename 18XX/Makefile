# 18XX: Organizing trays for tiles and other components
#
# by W. Craig Trader is dual-licensed under
# Creative Commons Attribution-ShareAlike 3.0 Unported License and
# GNU Lesser GPL 3.0 or later.

# Override PREFIX on the command line to select the parts to produce.
#
#     make all PREFIX=1830
#     make all PREFIX=1846
#     make all PREFIX=1867
#     make all PREFIX=steam
#
# To build all for every model:
#
#     make everything
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
OPENSCAD=/opt/openscad
OPENSCAD_OPTIONS=-DVERBOSE=false
IMAGE_OPTIONS=--imgsize=1024,768 --colorscheme=DeepOcean

# Name of OpenSCAD model file
PREFIX=1830

# ----- Everything after this should not need modification

# Names of parts to build
PARTS=$(shell grep 'PART == ' $(PREFIX).scad | cut -d'"' -f2)

STL=stl
IMAGE=png

MODELS=$(patsubst %,$(STL)/$(PREFIX)/$(PREFIX)-%.$(STL),$(PARTS))
IMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)/$(PREFIX)-%.$(IMAGE),$(PARTS))
COMMON=18XX.scad 18XX-data.scad ../util/boxes.scad ../util/printers.scad ../util/units.scad

# Name of all model prefixes
PREFIXES=$(shell ls *.scad | egrep -v 18XX | sed "s/.scad//" | tr "\n" " ")


all:	models images

everything:
	@for prefix in $(PREFIXES) ; do \
		$(MAKE) all PREFIX=$${prefix} ; \
	done

directories:
	@mkdir -p $(STL)/$(PREFIX) $(IMAGE)/$(PREFIX)

models: directories $(MODELS)

images: directories $(IMAGES)

clean:
	rm $(STL)/$(PREFIX)/$(PREFIX)-* $(IMAGE)/$(PREFIX)/$(PREFIX)-*

cleanall:
	rm -rf $(STL) $(IMAGE)

# Dependencies for models

$(MODELS) : $(STL)/$(PREFIX)/$(PREFIX)-%.$(STL) : $(PREFIX).scad $(COMMON)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(STL),,$(@F)))\" $<

# Dependencies for images

$(IMAGES) : $(IMAGE)/$(PREFIX)/$(PREFIX)-%.$(IMAGE) : $(PREFIX).scad $(COMMON)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(IMAGE),,$(@F)))\" $(IMAGE_OPTIONS) $<

