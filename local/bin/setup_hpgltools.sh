#!/usr/bin/env bash
start=$(pwd)
##commit="b26529d25251c3d915b718460ef34194dbf8e418"
prefix="/sw/local/conda/${VERSION}"
cpus=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "Starting setup_hpgltools, downloading required headers and utilities."

## The following installation is for stuff needed by hpgltools, these may want to be moved
## to the following mamba stanza
apt-get -y install libharfbuzz-dev libfribidi-dev libjpeg-dev libxft-dev libfreetype6-dev \
        libmpfr-dev libnetcdf-dev libtiff-dev wget 1>/dev/null 2>/setup_hpgltools.stderr
apt-get clean

echo "Installing mamba with hpgltools env to ${prefix}."
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -axvj bin/micromamba
echo "Creating hpgltools conda environment."
micromamba --root-prefix="${prefix}" --yes create -n hpgltools \
           imagemagick mpfr netcdf4 pandoc r-base=4.3.1 \
           -c conda-forge 1>/dev/null 2>>/setup_hpgltools.stderr
echo "Activating hpgltools"
source /usr/local/etc/bashrc
## Beginning hpgltools installation. The next line might be dangerous
## if singularity maps ~root and writes to the underlying filesystem.
## Ok, so I tested with and without setting Ncpus in ~/.Rprofile.
## I am now reasonably certain that /root is not being bound, so that is good.
echo "options(Ncpus=${cpus})" > ${HOME}/.Rprofile
echo "Cloning the hpgltools repository."
git clone https://github.com/abelew/hpgltools.git 1>/dev/null 2>>/stup_hpgltools.stderr
cd hpgltools || exit

#echo "Explicitly setting to the commit which was last used for the analyses."
#git reset ${commit} --hard

## It turns out I cannot allow R to install the newest bioconductor version arbitrarily because
## not every package gets checked immediately, this caused everything to explode!
echo "Installing bioconductor version 3.17."
Rscript -e 'install.packages("BiocManager", repo="http://cran.rstudio.com/")' 1>/dev/null 2>>/setup_hpgltools.stderr
Rscript -e 'BiocManager::install(version="3.17", ask=FALSE)'

echo "Installing non-base R prerequisites, essentially tidyverse."
Rscript -e 'BiocManager::install(c("devtools", "tidyverse"), force=TRUE, update=TRUE)'
make prereq 1>/dev/null 2>prereq.stderr
echo "Installing hpgltools dependencies with bioconductor."
make deps 1>/dev/null 2>deps.stderr

## preprocessCore has a bug which is triggered from within containers...
## https://github.com/Bioconductor/bioconductor_docker/issues/22
echo "Installing preprocessCore without threading to get around a container-specific bug."
Rscript -e 'BiocManager::install("preprocessCore", configure.args=c(preprocessCore="--disable-threading"), force=TRUE, update=TRUE, type="source")' 1>/dev/null 2>preprocessCore.stderr
echo "In my last revision I got weird clusterProfiler loading errors, testing it out here."
Rscript -e 'BiocManager::install(c("DOSE", "clusterProfiler"), force=TRUE, update=TRUE, type="source")'
## I like these sankey plots and vennerable, but they are not in bioconductor.
echo "Installing ggsankey and vennerable."
Rscript -e 'devtools::install_github("davidsjoberg/ggsankey")' 1>/dev/null 2>ggsankey.stderr
Rscript -e 'devtools::install_github("js229/Vennerable")' 1>/dev/null 2>vennerable.stderr
## The new version of dbplyr is broken and causes my annotation download to fail, and therefore _everything_ else.
Rscript -e 'devtools::install_version("dbplyr", version="2.3.4", repos="http://cran.us.r-project.org")'

echo "Installing hpgltools itself."
make install 
cd $start
