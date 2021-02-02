#!/bin/sh

# Install atftp
apt install -y atftpd
sed -I -e 's/^USE_INETD=true/USE_INETD=false/g' /etc/default/atftpd
sudo systemctl enable atftpd
sudo systemctl restart atftpd

# Install nfs server
apt-get install -y nfs-kernel-server

systemctl enable rpcbind
systemctl restart rpcbind
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server


# Install qemu for running arm binaries
apt install -y qemu-user-static binfmt-support
