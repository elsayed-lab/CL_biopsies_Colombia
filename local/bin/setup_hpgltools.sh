#!/usr/bin/env bash
start=$(pwd)
##commit="b26529d25251c3d915b718460ef34194dbf8e418"
prefix="/sw/local/conda/${VERSION}"
log=/hpgltools.stdout
cpus=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "Starting setup_hpgltools, downloading required headers and utilities."

## The following installation is for stuff needed by hpgltools, these may want to be moved
## to the following mamba stanza
apt-get -y install libharfbuzz-dev libfribidi-dev libjpeg-dev libxft-dev libfreetype6-dev \
        libmpfr-dev libnetcdf-dev libtiff-dev wget 1>/dev/null 2>&1
apt-get clean

echo "Installing mamba with hpgltools env to ${prefix}."
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -axvj bin/micromamba
echo "Creating hpgltools conda environment."
micromamba --root-prefix="${prefix}" --yes create -n hpgltools \
           imagemagick mpfr netcdf4 pandoc r-base=4.3.1 \
           -c conda-forge 1>/dev/null 2>&1
echo "Activating hpgltools"
source /usr/local/etc/bashrc
## Beginning hpgltools installation. The next line might be dangerous
## if singularity maps ~root and writes to the underlying filesystem.
## Ok, so I tested with and without setting Ncpus in ~/.Rprofile.
## I am now reasonably certain that /root is not being bound, so that is good.
echo "options(Ncpus=${cpus})" > ${HOME}/.Rprofile
echo "options(timeout=600)" >> "${HOME}/.Rprofile"
echo "options(repos='https://cloud.r-project.org')" >> "${HOME}/.Rprofile"
echo "Cloning the hpgltools repository." | tee -a ${log}
git clone https://github.com/abelew/hpgltools.git 1>/dev/null 2>&1
cd hpgltools || exit

#echo "Explicitly setting to the commit which was last used for the analyses."
#git reset ${commit} --hard

## It turns out I cannot allow R to install the newest bioconductor version arbitrarily because
## not every package gets checked immediately, this caused everything to explode!
echo "Installing bioconductor version: ${BIOC_VERSION}." | tee -a ${log}
Rscript -e 'install.packages("BiocManager", repo="http://cran.rstudio.com/")' 2>/dev/null 1>&2
Rscript -e "BiocManager::install(version='${BIOC_VERSION}', ask=FALSE)" 2>/dev/null 1>&2

echo "Installing non-base R prerequisites, essentially tidyverse." | tee -a ${log}
Rscript -e 'BiocManager::install(c("devtools", "tidyverse"), force=TRUE, update=TRUE)' 2>/dev/null 1>&2

echo "Installing hpgltools packages from Depends via devtools." | tee -a ${log}
Rscript -e 'devtools::install_dev_deps(".", dependencies = "Depends")' 2>/dev/null 1>&2
echo "Installing hpgltools packages from Imports via devtools." | tee -a ${log}
Rscript -e 'devtools::install_dev_deps(".", dependencies = "Imports")' 2>/dev/null 1>&2
echo "Installing hpgltools packages from Suggests via devtools." | tee -a ${log}
Rscript -e 'devtools::install_dev_deps(".", dependencies = "Suggests")' 2>/dev/null 1>&2

## preprocessCore has a bug which is triggered from within containers...
## https://github.com/Bioconductor/bioconductor_docker/issues/22
echo "Installing preprocessCore without threading to get around a container-specific bug." | tee -a ${log}
Rscript -e 'BiocManager::install("preprocessCore", configure.args=c(preprocessCore="--disable-threading"), force=TRUE, update=TRUE, type="source")' 1>/dev/null 2>&1
echo "In my last revision I got weird clusterProfiler loading errors, testing it out here." | tee -a ${log}
Rscript -e 'BiocManager::install(c("DOSE", "clusterProfiler"), force=TRUE, update=TRUE, type="source")' 2>/dev/null 1>&2
## I like these sankey plots and vennerable, but they are not in bioconductor.
echo "Installing ggsankey and vennerable." | tee -a ${log}
Rscript -e 'devtools::install_github("davidsjoberg/ggsankey")' 1>/dev/null 2>&1
Rscript -e 'devtools::install_github("js229/Vennerable")' 1>/dev/null 2>&1
## The new version of dbplyr is broken and causes my annotation download to fail, and therefore _everything_ else.
Rscript -e 'devtools::install_version("dbplyr", version="2.3.4", repos="http://cran.us.r-project.org")' 1>/dev/null 2>&1

echo "Attempting to ensure everything is at bioconductor version: ${BIOC_VERSION}" | tee -a ${log}
Rscript -e 'BiocManager::install(), force=TRUE, update=TRUE, ask=FALSE)' 2>/dev/null 1>&2

echo "Installing hpgltools itself." | tee -a ${log}
R CMD INSTALL . 2>/dev/null 1>&2
cd "${start}" || exit
