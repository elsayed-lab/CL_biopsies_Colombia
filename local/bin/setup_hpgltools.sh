#!/usr/bin/env bash
start=$(pwd)
commit="b26529d25251c3d915b718460ef34194dbf8e418"
prefix="/sw/local/conda/${VERSION}"

## The following installation is for stuff needed by hpgltools, these may want to be moved
## to the following mamba stanza
apt-get -y install libharfbuzz-dev libfribidi-dev libjpeg-dev libxft-dev libfreetype6-dev \
        libmpfr-dev libnetcdf-dev libtiff-dev wget 1>/dev/null
apt-get clean

echo "Installing mamba with hpgltools env to ${prefix}."
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -axvj bin/micromamba
echo "Performing create env to ${prefix}."
micromamba --root-prefix="${prefix}" --yes create -n hpgltools \
           imagemagick mpfr netcdf4 pandoc r-base=4.3.1 r-devtools r-tidyverse \
           -c conda-forge 1>/dev/null
echo "Activating hpgltools"
source /usr/local/etc/bashrc
## Beginning hpgltools installation.
echo "options(Ncpus=24)" > ~/.Rprofile
echo "Downloading and installing hpgltools and prerequisites."
git clone https://github.com/abelew/hpgltools.git
cd hpgltools || exit

echo "Explicitly setting to the commit which was last used for the analyses."
git reset ${commit} --hard
echo "Installing non-base R prerequisites, essentially tidyverse."
make prereq 1>/dev/null
echo "Installing the various/random dependencies scattered through hpgltools via BiocManager."
make deps 1>/dev/null

## preprocessCore has a bug which is triggered from within containers...
## https://github.com/Bioconductor/bioconductor_docker/issues/22
Rscript -e 'BiocManager::install("preprocessCore", configure.args=c(preprocessCore="--disable-threading"), force=TRUE, update=TRUE, type="source")'
## I like these sankey plots and vennerable, but they are not in bioconductor.
Rscript -e 'devtools::install_github("davidsjoberg/ggsankey")'
Rscript -e 'devtools::install_github("js229/Vennerable")'

echo "Installing hpgltools itself."
make install
cd $start
