#!/bin/bash

# Unofficial Bash Strict Mode (http://redsymbol.net/articles/unofficial-bash-strict-mode/)
set -euo pipefail
IFS=$'\n\t'

if [ $# -eq 0 ]
then 
   cache=""
else 
   cache="--no-cache"
fi 

VERSION=v0.1
DOCKER_TAG="kmer-workshop:$VERSION"
SINGULARITY_IMAGE="${DOCKER_TAG/:/_}.sif"

# build Docker image
docker build ${cache} -t "$DOCKER_TAG" -f Dockerfile .

# test Docker image
docker run --rm "$DOCKER_TAG"

# build Singularity image
SINGULARITY_TMPDIR=$(pwd) SINGULARITY_DISABLE_CACHE=true singularity build "$SINGULARITY_IMAGE" "docker-daemon://$DOCKER_TAG"

# test Singularity image
singularity exec --no-home --cleanenv kmer-workshop_${VERSION}.sif /bin/bash 

