## Orc(hestrator)

Builds a single container with dhpcd, tftpd, httpd, and support for netbooting macs and pxebooting pcs to install Centos 7 with Kickstart

To use:
* Modify ansible/roles/maas/vars/main.yml to taste
* ./orc build (builds the container)
* ./orc buildclean (if the build container needs created from scratch)
* ./orc run (locally to test/debug)
* ./orc deploy (send the image via scp to my deploy host and run with docker-compose)
