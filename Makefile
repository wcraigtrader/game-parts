OPENSCAD=/usr/local/bin/openscad

all:	images/eclipse_population_tray.dxf

clean:
	@rm -f *.deps

include $(wildcard *.deps)

images/%.dxf:	%.scad
	$(OPENSCAD) -m make -o $@ -d $@.deps $<
