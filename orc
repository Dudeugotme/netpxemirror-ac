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
test() {
  run  # start if not already started
  sleep 5
  did="$(docker ps -q --filter='name=ansible_maas_1')"
  docker run -it --rm -v $(pwd):/share -v /var/run/docker.sock:/var/run/docker.sock chef/inspec exec spec/test.rb -t docker://$did
}
deploy() {
  echo "* Deploying..." 
  LOCAL="$(docker images -q netpxemirror-ac-maas:latest)"
  LATEST="$(ssh deploy 'docker images -q netpxemirror-ac-maas:latest')"
  if [[ "$LOCAL" != "$LATEST" ]]; then
    echo " - Syncing the latest"
    docker save netpxemirror-ac-maas:latest | pv | ssh deploy 'docker load'
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
registry() {
  ssh deploy 'docker run -d -p 5000:5000 --restart=always --name registry registry:2'
}
prep() {
  if [ -z "${1-}" ]; then echo "Error: Need to specify a host to prepare for docker workloads by hostname"; exit; fi
  ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_ROLES_PATH=./ansible/roles ansible-playbook -i inventory/hosts -e "target=$1" playbooks/prep.yml
}
aio() {
  if [ -z "${1-}" ]; then echo "Error: Need to specify a host to prepare for docker workloads by hostname"; exit; fi
  ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_ROLES_PATH=./ansible/roles ansible-playbook -i inventory/hosts -e "target=$1" playbooks/aio.yml
}
usage() {
  echo "Usage: ./orc <command> <options>"
  echo ""
  echo "./orc build - Builds the MaaS container (MaaS)"
  echo "./orc buildclean - Builds the MaaS container from scratch (MaaS)"
  echo "./orc run - Runs the MaaS container locally for testing (MaaS)"
  echo "./orc test - Runs the MaaS container and applies inspec testing against it (MaaS)"
  echo "./orc deploy - Deploys and runs the MaaS service via scp and docker compose (MaaS)"
  echo "./orc registry - Deploys the docker registry container to the deploy host (Registry)"
  echo "./orc prep <inventory name> - Prepares a system for Openstack Kolla (OS Kolla)"
  echo "./orc aio <inventory name> - Installs All-In-One Openstack Kolla on this system (OS Kolla)"
  echo ""
  exit
}

# Do we have a command?
if [ -z "${1-}" ]; then usage; fi

# Allowed call?
allowed_nouns=("build" "buildclean" "run" "test" "deploy" "registry" "prep" "aio" "usage")
if [[ ! " ${allowed_nouns[@]} " =~ " ${1} " ]]; then usage; fi

# Run what was passed
"$@"
