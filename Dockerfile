FROM ubuntu:14.04
MAINTAINER  Grant Heffernan <grant@mapzen.com>

ENV TERM xterm
ENV BASEDIR /valhalla
ENV ENVIRONMENT ${ENVIRONMENT:-"dev"}
ENV TOOLS_BRANCH ${TOOLS_BRANCH:-"master"}
ENV MJOLNIR_BRANCH ${MJOLNIR_BRANCH:-"master"}
ENV VALHALLA_GITHUB ${VALHALLA_GITHUB:-"https://github.com/valhalla"}

RUN mkdir -p ${BASEDIR}
WORKDIR ${BASEDIR}
RUN mkdir tiles logs src locks extracts temp elevation data

ADD ./conf ${BASEDIR}/conf

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
  jq \
  git \
  curl \
  sudo \
  pigz \
  osmosis \
  parallel \
  osmctools \
  python-pip \
  spatialite-bin \
  software-properties-common

RUN pip install --upgrade pip
RUN pip install boto filechunkio awscli

RUN add-apt-repository ppa:valhalla-routing/valhalla
RUN add-apt-repository ppa:kevinkreiser/prime-server
RUN apt-get update && apt-get install -y --force-yes valhalla-bin

# the assumption here is that data will be furnished through some other method.
#   If there is none, get something to test with.
WORKDIR ${BASEDIR}/data
RUN if [ $(ls ${BASEDIR}/data | wc -l) = 0 ]; then curl -O https://s3.amazonaws.com/metro-extracts.mapzen.com/trento_italy.osm.pbf; fi

# prep data
RUN valhalla_build_admins -c ${BASEDIR}/conf/valhalla.json ${BASEDIR}/data/*.pbf
RUN valhalla_build_tiles -c ${BASEDIR}/conf/valhalla.json ${BASEDIR}/data/*.pbf

# cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# run the service
EXPOSE 8080
CMD ["valhalla_route_service", "/valhalla/conf/valhalla.json"]
