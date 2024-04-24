.PHONY: graph

TARGET = cl_biopsies.sif

all: $(TARGET)

RMD_FILES = data/*.Rmd

SETUP_SCRIPTS = local/bin/*.sh

CONFIG_FILES = local/etc/*

## Note x,y is multiple binds, a:b binds host:a to container:b
SINGULARITY_BIND="${HOME}/scratch:/scratch,${HOME}/.Xauthority,${PWD}:/output"

%.sif: %.yml $(RMD_FILES) $(SETUP_SCRIPTS) $(CONFIG_FILES)
	sudo singularity build --force $@ $<

%.sbox: %.yml $(RMD_FILES) $(SETUP_SCRIPTS) $(CONFIG_FILES)
	sudo singularity build --sandbox $@ $<

%.overlay: %.yml
	mkdir -p $(basename $<)_overlay
	sudo singularity shell -B ${SINGULARITY_BIND} --overlay $(basename $@)_overlay $(basename $@).sif

%.shell: %.sif
	singularity shell -B ${SINGULARITY_BIND} $(basename $@).sif

%.runover: %.yml
	mkdir -p $(basename $<)_overlay
	sudo singularity run -B ${SINGULARITY_BIND} --overlay $(basename $@)_overlay $(basename $@).sif

graph:
	make -dn MAKE=: all | sed -rn "s/^(\s+)Considering target file '(.*)'\.$/\1\2/p"
