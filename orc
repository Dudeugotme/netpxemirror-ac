#!/bin/bash

set -ueo pipefail

build() {
  ansible-container build
}
buildclean() {
  ansible-container build --from-scratch
}
run() {
  ansible-container run &
}
deploy() {
  echo "* Deploying..." 
  LOCAL="$(docker images -q orc-maas:latest)"
  LATEST="$(ssh deploy 'docker images -q orc-maas:latest')"
  if [[ "$LOCAL" != "$LATEST" ]]; then
    echo " - Syncing the latest"
    docker save orc-maas:latest | pv | ssh deploy 'docker load'
  else
    echo " - Already the latest"
  fi
  echo " - Copying compose file"
  scp -q ansible/docker-compose.yml deploy:
  echo " - Restarting compose app"
  ssh deploy 'docker-compose down'
  ssh -q deploy 'docker-compose up &' 2> /dev/null 1> /dev/null &
  echo "* Done."
}
usage() {
  echo "usage here"
  exit
}

# Do we have a command?
if [ -z "${1-}" ]; then usage; fi

# Allowed call?
allowed_nouns=("build" "buildclean" "run" "deploy" "usage")
if [[ ! " ${allowed_nouns[@]} " =~ " ${1} " ]]; then usage; fi

# Run what was passed
"$@"
