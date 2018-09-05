# NOTE: this Dockerfile needs to be run from one-level up so that
# we get the examples docker-compose.yml files. Use 'make build/tester'
# in the makefile at the root of this repo and everything will work

FROM anaxexp/alpine:3.7-2.1.0

RUN apk update \
    && apk add nodejs python3 openssl bash curl docker
RUN npm install -g anaxexp json

# the Compose package in the public releases doesn't work on Alpine
RUN pip3 install docker-compose==1.10.0

# install specific version of Docker and Compose client
COPY test/anaxexp-docker-cli/anaxexp-docker /usr/local/bin/anaxexp-docker
RUN sed -i 's/1.9.0/1.10.0/' /usr/local/bin/anaxexp-docker \
    && ln -s /usr/local/bin/anaxexp-docker /usr/local/bin/anaxexp-compose \
    && ln -s /usr/local/bin/anaxexp-docker /usr/local/bin/anaxexp-docker-install \
    && /usr/local/bin/anaxexp-docker-install \
    && rm /usr/local/bin/anaxexp-compose-helper \
    && ln -s /usr/bin/anaxexp-compose /usr/local/bin/anaxexp-compose-helper


# install test targets
COPY examples/anaxexp/docker-compose.yml /src/examples/anaxexp/docker-compose.yml
COPY examples/compose/docker-compose.yml /src/examples/compose/docker-compose.yml

# install test code
COPY test/anaxexp.sh /src/anaxexp.sh
COPY test/compose.sh /src/compose.sh