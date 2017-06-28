# Credit: this work is heavily based on https://github.com/apache/couchdb-docker/blob/master/2.0.0/Dockerfile

# We use ubuntu instead of debian:jessie as we want Erlang >= 18 for Couchdb SSL support
FROM ubuntu

MAINTAINER Geoff Cox redgeoff@gmail.com

# Update distro to get recent list of packages
RUN apt-get update -y -qq

# Download runtime dependencies
RUN apt-get --no-install-recommends -y install \
            erlang-nox \
            erlang-reltool \
            libicu55 \
            libmozjs185-1.0 \
            openssl \
            curl

# Update package lists
RUN apt-get update -y -qq

# The certs need to be installed after we have updated the package lists
RUN apt-get --no-install-recommends -y install \
            ca-certificates

# grab gosu for easy step-down from root and tini for signal handling
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.7/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 6380DC428747F6C393FEACA59A84159D7001A4E5 \
  && curl -o /usr/local/bin/tini -fSL "https://github.com/krallin/tini/releases/download/v0.14.0/tini" \
  && curl -o /usr/local/bin/tini.asc -fSL "https://github.com/krallin/tini/releases/download/v0.14.0/tini.asc" \
  && gpg --verify /usr/local/bin/tini.asc \
  && rm /usr/local/bin/tini.asc \
  && chmod +x /usr/local/bin/tini

# Download CouchDB, build it and then clean up
RUN buildDeps=" \
    g++ \
    erlang-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libmozjs185-dev \
    make \
    wget \
    # Yes, included again here so that it is removed by the purge below
    ca-certificates \
  " \
  && apt-get --no-install-recommends -y install $buildDeps \
  && cd /usr/src \
  && wget http://www-eu.apache.org/dist/couchdb/source/2.0.0/apache-couchdb-2.0.0.tar.gz \
  && tar xfz apache-couchdb-2.0.0.tar.gz \
  && rm apache-couchdb-2.0.0.tar.gz \
  && cd apache-couchdb-2.0.0 \
  && ./configure \
  && make release \
  && adduser --system \
             --shell /bin/bash \
             --group --gecos \
             "CouchDB Administrator" couchdb \
  && mv ./rel/couchdb /home/couchdb \
  && cd ../ \
  && rm -rf apache-couchdb-2.0.0 \
  && chown -R couchdb:couchdb /home/couchdb/couchdb \
  && find /home/couchdb/couchdb -type d -exec chmod 0770 {} \; \
  && chmod 0644 /home/couchdb/couchdb/etc/* \
  && apt-get purge -y --auto-remove $buildDeps \
  && rm -rf /var/lib/apt/lists/*

# Add config files
COPY local.ini /home/couchdb/couchdb/etc/local.d/
COPY vm.args /home/couchdb/couchdb/etc/

COPY ./docker-entrypoint.sh /

# Setup directories and permissions
RUN mkdir /home/couchdb/couchdb/data /home/couchdb/couchdb/etc/default.d \
  && chown -R couchdb:couchdb /home/couchdb/couchdb/

WORKDIR /home/couchdb/couchdb

EXPOSE 5984 4369 9100-9200

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["/home/couchdb/couchdb/bin/couchdb"]
