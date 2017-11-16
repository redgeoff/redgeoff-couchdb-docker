# redgeoff-couchdb-docker

CouchDB in a docker container

## Hashing a password
All your CouchDB nodes need the same hashed password so that user sessions can work seamlessly between nodes. You can use the `couch-hash-pwd` utility to generate this hash. For example, if your password is `admin` you can use:
    
    $ sudo npm install -g couch-hash-pwd
    $ couchdb-hash-pwd -p admin
    
You'll then want to use the outputted value as the value of `COUCHDB_HASHED_PASSWORD` 

## Example

    docker run -d --name couchdb \
      -p 5984:5984 \
      -v /home/ubuntu/common:/home/couchdb/common \
      -e COUCHDB_DATA_DIR="/home/couchdb/common/data/couchdb1.mydomain.com" \
      -e COUCHDB_USER='admin' \
      -e COUCHDB_HASHED_PASSWORD='-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10' \
      -e COUCHDB_COOKIE='mycookie' \
      -e COUCHDB_SECRET='mysecret' \
      redgeoff/couchdb

Creates a CouchDB instance listening on port 5984 with an admin username and password of `admin`. `COUCHDB_COOKIE` and `COUCHDB_SECRET` should be some random string of characters--you may want to use a password generator to generate these values.

## Example with SSL

We assume /home/ubuntu/common/ssl/mydomain.com.crt and /home/ubuntu/common/ssl/mydomain.com.key are the certificate and private key for your SSL config.

    docker run -d --name couchdb \
      -p 6984:6984 \
      -v /home/ubuntu/common:/home/couchdb/common \
      -e COUCHDB_DATA_DIR="/home/couchdb/common/data/couchdb1.mydomain.com" \
      -e COUCHDB_USER='admin' \
      -e COUCHDB_HASHED_PASSWORD='-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10' \
      -e COUCHDB_COOKIE='mycookie' \
      -e COUCHDB_SECRET='mysecret' \
      -e COUCHDB_CERT_FILE="/home/couchdb/common/ssl/mydomain.com.crt" \
      -e COUCHDB_KEY_FILE="/home/couchdb/common/ssl/mydomain.com.key" \
      -e COUCHDB_CACERT_FILE="/home/couchdb/common/ssl/mydomain.com.crt" \
      redgeoff/couchdb


## Example with SSL and custom local.ini

We assume /home/ubuntu/common/etc/local.ini contains any custom config, e.g.

    [chttpd]
    bind_address = any

    [httpd]
    bind_address = any

    [couchdb]
    max_dbs_open=1000

Then run:

    docker run -d --name couchdb \
      -p 6984:6984 \
      -v /home/ubuntu/common:/home/couchdb/common \
      -v /home/ubuntu/common/etc/local.ini:/home/couchdb/couchdb/etc/local.d/local.ini \
      -e COUCHDB_DATA_DIR="/home/couchdb/common/data/couchdb1.mydomain.com" \
      -e COUCHDB_USER='admin' \
      -e COUCHDB_HASHED_PASSWORD='-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10' \
      -e COUCHDB_COOKIE='mycookie' \
      -e COUCHDB_SECRET='mysecret' \
      -e COUCHDB_CERT_FILE="/home/couchdb/common/ssl/mydomain.com.crt" \
      -e COUCHDB_KEY_FILE="/home/couchdb/common/ssl/mydomain.com.key" \
      -e COUCHDB_CACERT_FILE="/home/couchdb/common/ssl/mydomain.com.crt" \
      redgeoff/couchdb


## Create Cluster

For example, assume that you have the following DNS config:

    192.168.50.10 couchdb1.mydomain.com
    192.168.50.11 couchdb2.mydomain.com

On server 1, run:

    docker run -d --name couchdb \
      -p 5984:5984 \
      -p 6984:6984 \
      -p 5986:5986 \
      -p 4369:4369 \
      -p 9100-9200:9100-9200 \
      -v /home/ubuntu/common:/home/couchdb/common \
      -v /home/ubuntu/common/etc/local.ini:/home/couchdb/couchdb/etc/local.d/local.ini \
      -e COUCHDB_DATA_DIR="/home/couchdb/common/data/couchdb1.mydomain.com" \
      -e COUCHDB_USER='admin' \
      -e COUCHDB_HASHED_PASSWORD='-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10' \
      -e COUCHDB_COOKIE='mycookie' \
      -e COUCHDB_NODE_NAME='192.168.50.10' \
      -e COUCHDB_SECRET='mysecret' \
      -e COUCHDB_CERT_FILE="/home/couchdb/common/ssl/mydomain.com.crt" \
      -e COUCHDB_KEY_FILE="/home/couchdb/common/ssl/mydomain.com.key" \
      -e COUCHDB_CACERT_FILE="/home/couchdb/common/ssl/mydomain.com.crt" \
      redgeoff/couchdb

On server 2, run:

    docker run -d --name couchdb \
      -p 5984:5984 \
      -p 6984:6984 \
      -p 5986:5986 \
      -p 4369:4369 \
      -p 9100-9200:9100-9200 \
      -v /home/ubuntu/common:/home/couchdb/common \
      -v /home/ubuntu/common/etc/local.ini:/home/couchdb/couchdb/etc/local.d/local.ini \
      -e COUCHDB_DATA_DIR="/home/couchdb/common/data/couchdb2.mydomain.com" \
      -e COUCHDB_USER='admin' \
      -e COUCHDB_HASHED_PASSWORD='-pbkdf2-b1eb7a68b0778a529c68d30749954e9e430417fb,4da0f8f1d98ce649a9c5a3845241ae24,10' \
      -e COUCHDB_COOKIE='mycookie' \
      -e COUCHDB_NODE_NAME='192.168.50.11' \
      -e COUCHDB_SECRET='mysecret' \
      -e COUCHDB_CERT_FILE="/home/couchdb/common/ssl/mydomain.com.crt" \
      -e COUCHDB_KEY_FILE="/home/couchdb/common/ssl/mydomain.com.key" \
      -e COUCHDB_CACERT_FILE="/home/couchdb/common/ssl/mydomain.com.crt" \
      redgeoff/couchdb

Create cluster:

    ./create-cluster.sh admin admin 5984 5986 "192.168.50.12 192.168.50.11"

You can then use a load balancer to balance port 6984 traffic over 192.168.50.12 and 192.168.50.11. You can also do the the SSL termination directly on the load balancer and have the load balancer connect with the CouchDB nodes on port 5984. For better security, you should use a firewall to make sure to only allow outside traffic via the load balancer.

## Upgrade to latest image

    $ docker pull redgeoff/couchdb
    $ docker rm couchdb --force
    $ docker run -d --name couchdb ...

## On AWS
See [Running a CouchDB 2.0 Cluster in Production on AWS with Docker](https://hackernoon.com/running-a-couchdb-2-0-cluster-in-production-on-aws-with-docker-50f745d4bdbc)
