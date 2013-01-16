OPENSCAD=/usr/local/bin/openscad

all:	population_storage_tray.dxf

clean:
	@rm -f *.dxf

include $(wildcard *.deps)

%.dxf:	%.scad
	$(OPENSCAD) -m make -o $@ -d $@.deps $<
