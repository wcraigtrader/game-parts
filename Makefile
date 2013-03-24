OPENSCAD=/usr/local/bin/openscad

all:	eclipse_population_tray.dxf

clean:
	@rm -f *.dxf

include $(wildcard *.deps)

%.dxf:	%.scad
	$(OPENSCAD) -m make -o $@ -d $@.deps $<
