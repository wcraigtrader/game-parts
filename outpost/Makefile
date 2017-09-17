OPENSCAD=/usr/bin/openscad
OPENSCAD_OPTIONS=-DVERBOSE=0

SLIC3R=/opt/Slic3r/Slic3r-1.36.2-prusa3d-linux64-full-201707281217/slic3r
SLIC3R_OPTIONS=--load slic3r.ini --print-center 125,105

STL=stl
IMAGE=png
GCODE=gcode

PREFIX=outpost

CPARTS=1-box 1-lid 2-box 2-lid large-box large-lid
FPARTS=box lid pick
PPARTS=box lid

FMODELS=$(patsubst %,$(STL)/$(PREFIX)-factories-%.stl,$(FPARTS))
CMODELS=$(patsubst %,$(STL)/$(PREFIX)-card-tray-%.stl,$(CPARTS))
PMODELS=$(patsubst %,$(STL)/$(PREFIX)-parts-%.stl,$(PPARTS))

FIMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-factories-%.png,$(FPARTS))
CIMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-card-tray-%.png,$(CPARTS))
PIMAGES=$(patsubst %,$(IMAGE)/$(PREFIX)-parts-%.png,$(PPARTS))

GCODES=$(patsubst %,$(GCODE)/$(PREFIX)-factories-%.gcode,$(FPARTS))
GCODES+=$(patsubst %,$(GCODE)/$(PREFIX)-card-tray-%.gcode,$(CPARTS))
GCODES+=$(patsubst %,$(GCODE)/$(PREFIX)-parts-%.gcode,$(PPARTS))



all:	models gcodes images

directories:
	@mkdir -p $(STL) $(IMAGE) $(GCODE)

models: directories $(FMODELS) $(CMODELS) $(PMODELS)

gcodes: directories $(GCODES)

images: directories $(FIMAGES) $(CIMAGES) $(PIMAGES)

clean:
	rm -rf $(STL) $(GCODE) $(IMAGE)

# Dependencies for models

$(FMODELS) : $(STL)/$(PREFIX)-factories-%.stl : $(PREFIX)-factories.scad
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-factories-,,$(subst .stl,,$(@F)))\" $<

$(CMODELS) : $(STL)/$(PREFIX)-card-tray-%.stl : $(PREFIX)-card-tray.scad
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-card-tray-,,$(subst .stl,,$(@F)))\" $<

$(PMODELS) : $(STL)/$(PREFIX)-parts-%.stl : $(PREFIX)-parts.scad
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-parts-,,$(subst .stl,,$(@F)))\" $<

# Dependencies for images

$(FIMAGES) : $(IMAGE)/$(PREFIX)-factories-%.png : $(PREFIX)-factories.scad
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-factories-,,$(subst .png,,$(@F)))\" $<

$(CIMAGES) : $(IMAGE)/$(PREFIX)-card-tray-%.png : $(PREFIX)-card-tray.scad
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-card-tray-,,$(subst .png,,$(@F)))\" $<

$(PIMAGES) : $(IMAGE)/$(PREFIX)-parts-%.png : $(PREFIX)-parts.scad
	$(OPENSCAD) $(OPENSCAD_OPTIONS) -o $@ -DPART=\"$(subst $(PREFIX)-parts-,,$(subst .png,,$(@F)))\" $<

# Dependencies for slicing

$(GCODES) : $(GCODE)/%.gcode : $(STL)/%.stl
	$(SLIC3R) -o $@ $(SLIC3R_OPTIONS) $<

