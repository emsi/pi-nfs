#!/bin/bash

set -Eeuo pipefail

useradd -m -s /bin/bash -G audio,video,spi,gpio kiosk || true

# enable autologin
systemctl set-default graphical.target
ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin kiosk --noclear %I \$TERM
EOF

cat > /home/kiosk/.bash_profile <<EOF
if [ -z \$DISPLAY ] && [ \$(tty) = /dev/tty1 ]
then
	while true; do
	  startx
	done
fi
EOF

cat > /home/kiosk/.xinitrc <<EOF
chromium-browser  --window-size=1920,1080 \
  --window-position=0,0 \
  --start-fullscreen \
  --kiosk --noerrdialogs --use-gl=egl \
  --enable-gpu-rasterization --enable-native-gpu-memory-buffers --enable-accelerated-video-decode \
  --ignore-gpu-blacklist --disable-infobars --autoplay-policy=no-user-gesture-required --check-for-update-interval=31536000 'https://google.com'
EOF
