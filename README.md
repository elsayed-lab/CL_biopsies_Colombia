# Introduction

This experiment comprises a series of macrophages infected with two
primary strains of L. panamensis, two drugs, and the various
uninfected/untreated controls.  I will write a more thorough summary
shortly, I just want to get some instructions in place for the moment.

# Installation

Grab a copy of the repository:

```{bash}
git pull https://github.com/elsayed-lab/CL_biopsies_Colombia.git
```

The resulting directory should contain a few subdirectories of note:

* local: Contains the setup scripts for the container and software
  inside it.
* data: The place I put all of the data for a pre-compiled analysis.
  It is essentially what happens when I rsync my root directory for a
  project.
* dotemacs.d: Probably only of interest to me, I use emacs and it
  allows me to play with the analyses interactively.

At the root, there should also be a yml and Makefile which contain the
definition of the container and a few shortcuts for
building/running/playing with it.

# Creating the container

With either of the following commands, singularity should read the yml
file and build a Debian stable container with a R environment suitable
for running all of the analyses in Rmd/.

```{bash}
make cl_biopsies.sif
## Really, this just runs:
sudo -E singularity build cl_biopsies.sif cl_biopsies.yml
```

# Generating the html/rda/excel output files

One of the neat things about singularity is the fact that one may just
'run' the container and it will execute the commands in its
'runscript' section.  That runscript should use knitr to render a
html copy of all the Rmd/ files and put a copy of the html outputs
along with all of the various excel/rda/image outputs into the current
working directory of the host system.  In order for this to work, it
makes one bit assumption: the environment variable
SINGULARITY_BINDPATH _must_ include '.:/output'.

One may of course change PWD to wherever one wishes, as well as add
more comma-separated paths.  With that in mind, the following should
run for a few hours and print a whole lot of text to the screen, then
dump a lot of files to {PWD}/{current_date}_outputs.

*NOTE: 202309* I did not think through the implications of the
immutable nature of the singularity container.  I knew that the images
are RO, but for some reason I still assumed I can write to it in the
run script.  As a result, until I more fully understand singularity,
the following will not work.  I think the key thing I must do is
create a sandbox image, but until I figure it out, it will likely
easiest to use an overlay.

```{bash}
export SINGULARITY_BINDPATH=".:/output"
./cl_biopsies.sif
## Or if you wish to render another document:
./cl_biopsies.sif -i something.Rmd
```

# Playing around inside the container

If, like me, you would rather poke around in the container and watch
it run stuff, either of the following commands should get you there:

```{bash}
make cl_biopsies.overlay
## That makefile target just runs:
mkdir -p cl_biopsies_overlay
sudo singularity shell --overlay cl_biopsies_overlay cl_biopsies.sif
```

## Manually running the markdown files

All of the fun stuff is in /data.  The container has a working vim and
emacs installation, so go nuts. I also put a portion of my emacs
config sufficient to play with R markdown files.

```{bash}
## From within the container
cd /data
emacs -nw 01datasets.Rmd
## Render your own copy of the data:
Rscript -e 'hpgltools::renderme("01datasets.Rmd")'
cp *datasets*.html /output/
```

If you used the SINGULARITY_BIND environment variable as noted above,
then any files you copy to /output within the container should appear
at the current working directory of the host when you started it.  You
may also copy stuff to the other singularity binds like $HOME, but
since overlays require sudo, the results are likely to be inconsistent
and weird.

In addition, if you poke around in the hpgltools_overlay
directory, you will find copies of _any_ files which changed in the
container while it was running; so you may poke around in there to get
a more complete view of what happened while it was running.
