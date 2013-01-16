
all:	population_storage_tray.dxf

clean:
	@rm -f *.dxf

include $(wildcard *.deps)

%.dxf:	%.scad
	openscad -m make -o $@ -d $@.deps $<
