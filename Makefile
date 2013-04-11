OPENSCAD=/usr/local/bin/openscad

all:	models/eclipse_population_tray.dxf models/eclipse_sector_tray.dxf

clean:
	@rm -f models/*.deps

cleanall:	clean
	@rm -f models/*

include $(wildcard *.deps)

models/%.dxf:	%.scad
	$(OPENSCAD) -m make -o $@ -d $@.deps $<
