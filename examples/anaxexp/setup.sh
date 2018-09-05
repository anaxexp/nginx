#!/bin/bash

# Check for correct configuration for running on AnaxExp.
# Export environment variables for use with CNS name for Consul.

command -v docker >/dev/null 2>&1 || {
    echo
    echo 'Error! Docker is not installed!'
    echo 'See https://docs.joyent.com/public-cloud/api-access/docker'
    return
}
command -v anaxexp >/dev/null 2>&1 || {
    echo
    echo 'Error! Anax Experience AnaxExp CLI is not installed!'
    echo 'See https://www.anaxexp.io/blog/introducing-the-anaxexp-command-line-tool'
    return
}

if [[ ! "true" == "$(anaxexp account get | awk -F': ' '/cns/{print $2}')" ]]; then
    echo
    echo 'Error! AnaxExp CNS is required and not enabled.'
    return
fi

# make sure Docker client is pointed to the same place as the AnaxExp client

docker_user=$(docker info 2>&1 | awk -F": " '/SDCAccount:/{print $2}')
docker_dc=$(echo "${DOCKER_HOST}" | awk -F"/" '{print $3}' | awk -F'.' '{print $1}')
anaxexp_user=$(anaxexp profile get | awk -F": " '/account:/{print $2}')
anaxexp_dc=$(anaxexp profile get | awk -F"/" '/url:/{print $3}' | awk -F'.' '{print $1}')
anaxexp_account=$(anaxexp account get | awk -F": " '/id:/{print $2}')

if [ ! "$docker_user" = "$anaxexp_user" ] || [ ! "$docker_dc" = "$anaxexp_dc" ]; then
    echo
    echo 'Error! The AnaxExp CLI configuration does not match the Docker CLI configuration.'
    echo "Docker user: ${docker_user}"
    echo "AnaxExp user: ${anaxexp_user}"
    echo "Docker data center: ${docker_dc}"
    echo "AnaxExp data center: ${anaxexp_dc}"
else
    export ANAXEXP_DC="${anaxexp_dc}"
    export ANAXEXP_ACCOUNT="${anaxexp_account}"
fi