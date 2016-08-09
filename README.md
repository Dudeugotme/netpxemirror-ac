## Ansible-Container MaaS and Openstack Deploy System Orchestrator

1. Builds a single container using ansible-container with dhpcd, tftpd, httpd/yum mirror, and support for netbooting macs and pxebooting pcs to install Centos 7 with Kickstart--then starts that on the deploy server.
2. Starts a docker v2 registry on the deploy server.
3. Prepares a target host for running Openstack Kolla (mitaka or newton) all-in-one using 
4. Installs Openstack Kolla (newton) all-in-one on a target host (configures, build/push, pull, deploy, post-deploy, runonce).

### Usage
```
$./orc
Usage: ./orc <command> <options>

./orc build - Builds the MaaS container (MaaS)
./orc buildclean - Builds the MaaS container from scratch (MaaS)
./orc run - Runs the MaaS container locally for testing (MaaS)
./orc test - Runs the MaaS container and applies inspec testing against it (MaaS)
./orc deploy - Deploys and runs the MaaS service via scp and docker compose (MaaS)
./orc registry - Deploys a private/blank docker registry container to the deploy host (Registry)
./orc prep <inventory name> - Prepares a system for Openstack Kolla (OS Kolla)
./orc aio <inventory name> - Installs All-In-One Openstack Kolla on this system (OS Kolla)
```
