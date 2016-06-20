#!/bin/bash


# build or install from ppa
#if [ ${FROM_SOURCE} = "true" ]; then
#  cd ${BASEDIR}/src && rm -rf ./*
#
#  git clone --depth=1 --recurse-submodules --single-branch --branch=${MJOLNIR_BRANCH} ${VALHALLA_GITHUB}/mjolnir
#  git clone --depth=1 --recurse-submodules --single-branch --branch=${TOOLS_BRANCH} ${VALHALLA_GITHUB}/tools
#
#  cd ${BASEDIR}/src/mjolnir
#  scripts/dependencies.sh ${BASEDIR}/src
#  scripts/install.sh
#  make -j2 && make -j2 install
#
#  cd ${BASEDIR}/src/tools
#  scripts/dependencies.sh ${BASEDIR}/src
#  scripts/install.sh
#  make -j2 && make -j2 install
#
#  ldconfig
#else
  add-apt-repository ppa:valhalla-routing/valhalla
  add-apt-repository ppa:kevinkreiser/prime-server
  apt-get update && apt-get install -y valhalla-bin
#fi

# if there's no data, get some
if [ $(ls ${BASEDIR}/data | wc -l) = 0 ]; then
  curl -O https://s3.amazonaws.com/metro-extracts.mapzen.com/trento_italy.osm.pbf
  exit 0
fi
