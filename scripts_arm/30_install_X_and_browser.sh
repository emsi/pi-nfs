#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get install -yq --no-install-recommends xserver-xorg-core xserver-xorg-input-all xinit chromium-chromedriver rpi-chromium-mods libgles2-mesa mesa-utils libsdl2-dev
