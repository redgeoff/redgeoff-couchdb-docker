FROM debian:jessie

# Update distro
RUN apt-get update -y && apt-get -y upgrade && apt-get -y dist-upgrade

# Install CouchDB from source
RUN apt-get --no-install-recommends -y install \
            build-essential pkg-config erlang \
            libicu-dev libmozjs185-dev libcurl4-openssl-dev \
            wget curl \
  && cd /usr/src \
  && wget http://www-eu.apache.org/dist/couchdb/source/2.0.0/apache-couchdb-2.0.0.tar.gz \
  && tar xfz apache-couchdb-2.0.0.tar.gz \
  && cd apache-couchdb-2.0.0 \
  && ./configure \
  && make release \
  && adduser --system \
             --shell /bin/bash \
             --group --gecos \
             "CouchDB Administrator" couchdb \
  && cp -R ./rel/couchdb /home/couchdb \
  && chown -R couchdb:couchdb /home/couchdb/couchdb \
  && find /home/couchdb/couchdb -type d -exec chmod 0770 {} \; \
  && chmod 0644 /home/couchdb/couchdb/etc/*

# Add config files
COPY local.ini /home/couchdb/couchdb/etc/local.d/
COPY vm.args /home/couchdb/couchdb/etc/

COPY ./docker-entrypoint.sh /

WORKDIR /home/couchdb/couchdb

EXPOSE 5984 4369 9100-9200

VOLUME ["/home/couchdb/couchdb/data"]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/home/couchdb/couchdb/bin/couchdb"]
