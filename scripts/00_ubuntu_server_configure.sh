#!/bin/bash
set -Eeuo pipefail

if [[ ! -x /usr/sbin/atftpd ]]; then
	# Install atftp
	apt install -y atftpd
fi

if ! grep -q "USE_INETD=false" /etc/default/atftpd; then
	sed -i -e 's/^USE_INETD=true/USE_INETD=false/g' /etc/default/atftpd
	sudo systemctl enable atftpd
	sudo systemctl restart atftpd
fi

if [[ ! -x /sbin/rpcbind || ! -x /usr/sbin/rpc.mountd ]]; then
	# Install nfs server
	apt-get install -y nfs-kernel-server
	
	systemctl enable rpcbind
	systemctl restart rpcbind
	systemctl enable nfs-kernel-server
	systemctl restart nfs-kernel-server
fi
		
if [[ ! -x /usr/bin/qemu-arm-static ]]; then
	# Install qemu for running arm binaries
	apt install -y qemu-user-static binfmt-support
fi
