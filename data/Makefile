.PHONY: all

OUTPUTS = tmrc.simg

cpm:
	mkdir -p cpm/3_cali_and_tumaco cpm/4_cali cpm/4_tumaco excel figures rda rpkm

preprocessing/TMRC30001:
	cd preprocessing && tar xaf pruned_counts_host.tar
	cd preprocessing && tar xaf pruned_counts_parasite.tar
	cd preprocessing && tar xaf scott_counts.tar

%.render: %.Rmd cpm preprocessing/TMRC30001
	Rscript -e "hpgltools::renderme('$<', 'html_document')" \
		2>&1 | tee $(basename $<).stdout

%.edit:	%.Rmd
	emacs -nw $<.Rmd
