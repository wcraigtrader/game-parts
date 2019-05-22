# 18XX: Organizing trays for tiles and other components
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
UTIL1=$(shell grep 'include' 18XX.scad | tr '<>' '||' | cut -d'|' -f2 | sort | uniq)
UTIL2=$(shell grep 'include' $(UTIL1) | tr '<>' '||' | cut -d'|' -f2 | sort | uniq)

BOM=bom
STL=stl
IMAGE=png

BOMS=$(BOM)/$(PREFIX)-bom.md
MODELS=$(patsubst %,$(STL)/$(PREFIX)/$(PREFIX)-%.$(STL),$(PARTS))
IMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)/$(PREFIX)-%.$(IMAGE),$(PARTS))
COMMON=18XX.scad ../util/hexes.scad ../util/boxes.scad ../util/printers.scad ../util/units.scad

# Name of all model prefixes
PREFIXES=$(shell ls *.scad | egrep -v 18XX | sed "s/.scad//" | tr "\n" " ")


all:	models images boms

everything:
	@for prefix in $(PREFIXES) ; do \
		$(MAKE) PREFIX=$${prefix} all ; \
	done

all-boms:
	@for prefix in $(PREFIXES) ; do \
		$(MAKE) PREFIX=$${prefix} boms ; \
	done


directories:
	@mkdir -p $(STL)/$(PREFIX) $(IMAGE)/$(PREFIX) $(BOM)

models: directories $(MODELS)

images: directories $(IMAGES)

boms:    directories $(BOMS)

clean:
	rm $(STL)/$(PREFIX)/$(PREFIX)-* $(IMAGE)/$(PREFIX)/$(PREFIX)-* $(BOM)/$(PREFIX)-bom.md

cleanall:
	rm -rf $(STL) $(IMAGE) $(BOM)

# Dependencies for BOM
$(BOM)/$(PREFIX)-$(BOM).md : $(PREFIX).scad
	@/bin/echo "Creating BOM for $(PREFIX)"
	@/bin/echo "| Model | Qty | Description |" > $@
	@/bin/echo "| ----- | --- | ----------- |" >> $@
	@fgrep '// bom:' $(PREFIX).scad | tr -s '":()/' '|||||' | cut -d '|' -f3,6,7 | sed 's/|/.stl |/;s/^/| $(PREFIX)-/;s/$$/|/' >> $@

# Dependencies for models

$(MODELS) : $(STL)/$(PREFIX)/$(PREFIX)-%.$(STL) : $(PREFIX).scad $(COMMON)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(STL),,$(@F)))\" $<

# Dependencies for images

$(IMAGES) : $(IMAGE)/$(PREFIX)/$(PREFIX)-%.$(IMAGE) : $(PREFIX).scad $(COMMON)
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-,,$(subst .$(IMAGE),,$(@F)))\" $(IMAGE_OPTIONS) $<

