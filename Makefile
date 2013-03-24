OPENSCAD=/usr/local/bin/openscad

all:	images/eclipse_population_tray.dxf images/eclipse_sector_tray.dxf

clean:
	@rm -f images/*.deps

cleanall:	clean
	@rm -f images/*

include $(wildcard *.deps)

images/%.dxf:	%.scad
	$(OPENSCAD) -m make -o $@ -d $@.deps $<
