#!/usr/bin/env bash
echo "Setting up a usable Debian stable instance."
apt-get update 1>/dev/null
apt-get -y upgrade 1>/dev/null
apt-get -y install build-essential bzip2 ca-certificates cmake curl emacs environment-modules \
        git less libtool rsync vim xauth 1>/dev/null

## Set up a starter modules tree
mkdir -p "/sw/local/conda/${VERSION}" /sw/modules/conda
cp /sw/modules/template "/sw/modules/conda/${VERSION}"
