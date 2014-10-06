# Docker image for OSM tools
# To build, run docker build --rm --tag=jmarin/osm-docker
# A container with a shell including Imposm3 can be started by running docker run -t -i jmarin/osm-docker

FROM jmarin/jdk8
MAINTAINER Juan Marin Otero <juan.marin.otero@gmail.com>

RUN yum -y update; yum clean all

# Install dependencies and configure

RUN yum -y install tar git mercurial snappy boost-devel gcc gcc-c++ flex wget protobuf protobuf-devel supervisor; yum clean all
RUN yum -y install golang leveldb leveldb-devel geos geos-devel; yum clean all

# Install Osmosis

RUN mkdir -p /opt/osmosis
WORKDIR /opt/osmosis
RUN wget http://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz
RUN tar zxvf osmosis-latest.tgz
RUN chmod a+x bin/osmosis
ENV PATH $PATH:/opt/osmosis/bin

# Install Imposm3

WORKDIR /tmp
ENV GOPATH /usr
ENV PATH $PATH:$GOPATH/bin

# Install GO support for LevelDB, SQLite, Protocol Buffers and PostgreSQL
RUN go get github.com/jmhodges/levigo
RUN go get github.com/mattn/go-sqlite3
RUN go get code.google.com/p/goprotobuf/{proto,protoc-gen-go}
RUN go get github.com/lib/pq

# Install Imposm3

RUN mkdir /opt/imposm
WORKDIR /opt/imposm
RUN git clone https://github.com/omniscale/imposm3 src/imposm3
ENV GOPATH /opt/imposm
RUN go get imposm3
RUN go install imposm3
ENV PATH $PATH:/opt/imposm/bin

# Create directories, copy scripts

RUN mkdir -p /opt/osm/replication
WORKDIR /opt/osm/replication
ADD config-shop.json /opt/osm/replication/config-shop.json
ADD mapping-shop.json /opt/osm/replication/mapping-shop.json
ADD district-of-columbia-latest.osm.pbf /opt/osm/replication/district-of-columbia-latest.osm.pbf

CMD ["/usr/bin/supervisord", "/bin/bash"]


