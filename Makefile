.PHONY: all

## Note x,y is multiple binds, a:b binds host:a to container:b
SINGULARITY_BIND="${HOME}/scratch:/scratch,${HOME}/.Xauthority,${PWD}:/output"

%.sif: %.yml
	sudo singularity build $@ $<

%.sbox: %.sif
	sudo singularity build --sandbox $<

%.overlay: %.yml
	mkdir -p $(basename $<)_overlay
	sudo singularity shell -B ${SINGULARITY_BIND} --overlay $(basename $<)_overlay $(basename $@).sif

%.shell: %.sif
	singularity shell -B ${SINGULARITY_BIND} $<

%.run: %.sif
	singularity run -B ${SINGULARITY_BIND} $<.sif

%.runover: %.yml
	mkdir -p $(basename $<)_overlay
	sudo singularity run -B ${SINGULARITY_BIND} --overlay $(basename $<)_overlay $(basename $@).sif
