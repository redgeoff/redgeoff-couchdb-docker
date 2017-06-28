# redgeoff-couchdb-docker

CouchDB in a docker container

## Example

    docker run -d --name couchdb \
      -p 5984:5984 \
      -v /home/ubuntu/common:/home/couchdb/common \
      -e COUCHDB_DATA_DIR="/home/couchdb/common/data/couchdb1" \
      -e COUCHDB_USER='admin' \
      -e COUCHDB_HASHED_PASSWORD='-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10' \
      -e COUCHDB_COOKIE='mycookie' \
      -e NODENAME='mynode' \
      -e COUCHDB_SECRET='mysecret' \
      redgeoff-couchdb


## Example with SSL:

We assume /home/ubuntu/common/ssl/mydomain.crt and /home/ubuntu/common/ssl/mydomain.key are the certificate and private key for your SSL config.

    docker run -d --name couchdb \
      -p 5984:5984 \
      -p 6984:6984 \
      -v /home/ubuntu/common:/home/couchdb/common \
      -e COUCHDB_DATA_DIR="/home/couchdb/common/data/couchdb1" \
      -e COUCHDB_USER='admin' \
      -e COUCHDB_HASHED_PASSWORD='-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10' \
      -e COUCHDB_COOKIE='mycookie' \
      -e NODENAME='mynode' \
      -e COUCHDB_SECRET='mysecret' \
      -e COUCHDB_CERT_FILE="/home/couchdb/common/ssl/mydomain.crt" \
      -e COUCHDB_KEY_FILE="/home/couchdb/common/ssl/mydomain.key" \
      -e COUCHDB_CACERT_FILE="/home/couchdb/common/ssl/mydomain.crt" \
      redgeoff-couchdb


## Example with SSL and custom local.ini:

We assume /home/ubuntu/common/etc/local.ini contains any custom config, e.g.

    [chttpd]
    bind_address = any

    [httpd]
    bind_address = any

    [couchdb]
    max_dbs_open=1000

Then run:

    docker run -d --name couchdb \
      -p 5984:5984 \
      -p 6984:6984 \
      -v /home/ubuntu/common:/home/couchdb/common \
      -e COUCHDB_DATA_DIR="/home/couchdb/common/data/couchdb1" \
      -e COUCHDB_USER='admin' \
      -e COUCHDB_HASHED_PASSWORD='-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10' \
      -e COUCHDB_COOKIE='mycookie' \
      -e NODENAME='mynode' \
      -e COUCHDB_SECRET='mysecret' \
      -e COUCHDB_CERT_FILE="/home/couchdb/common/ssl/mydomain.crt" \
      -e COUCHDB_KEY_FILE="/home/couchdb/common/ssl/mydomain.key" \
      -e COUCHDB_CACERT_FILE="/home/couchdb/common/ssl/mydomain.crt" \
      -e COUCHDB_LOCAL_INI="/home/couchdb/common/etc/local.ini" \
      redgeoff-couchdb
