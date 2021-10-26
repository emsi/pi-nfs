# pi-nfs

Tool to setup server that pi can use to boot off.

It's main purpose is to set up netbooted kiosk but can be easily modified and extended to bootstrap other configurations.
Among some of its unique features is allowing pi to boot with read only root filesystem with overlay (this can be of course turned off).
All customizations are stored in scripts and thus can easily be examined and altered.
It works only on Ubuntu/debian hosts running on x64 CPU. We'll call it 'the server' further on :) We assume that the server will host both tftp and nfs root (both will be installed and configured by this script).

## assumptions
1. You have raspberry pi 4 or later capable of booting from network (see https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711_bootloader_config.md for boot options). Use `sudo rpi-eeprom-config -e` to modify your pi firmware bootloader (don't forget to reboot from sd card after the change so pi can feed the changes).
2. You have configured pi to boot from network using tftp either by configuring your dhcp server and pointing to 'the server' or flashing the firmware with appropriate value of `TFTP_IP`.
3. You may find it convenient to set `TFTP_PREFIX=1` and leave `TFTP_PREFIX_STR` blank. This way all pis will boot from root of tftp server and the same configuration (which is acceptable for kiosks).

## configuration
First thing you need to do is edit the ENV file and set appropriate options. The most important is `NFS_IP=` variable specifying the server's IP facing the raspberries to be booted. 

## bootsrap

`bootstrap` script is the central part of the solution. Its main job is to load configuration from `ENV` file and execute scripts from `scripts` and `scripts_arm` directories. Scripts from former are executed directly on the server while scripts form latter are executed using arm emulation and chroot into target raspios image allowing us for greater customizations like installing packages or executing system tools.

### options
boostrap has one required positional argument, the path to directory that will be filled with bootstraped raspios image and several switches:
```
$ ./bootstrap -h
Usage: bootstrap [-h] [-v] [-d] [-D] [-R] [-S] [-A] [-t] [-P] target_path

Raspberry pi nfsroot bootstrap script.

Available options:

-h, --help           Print this help and exit
-v, --verbose        Print verbose info (implies dry run)
-d, --debug          Print debug (each run command)
-D, --no-download    Don't download new dist files (fails if not previously
                     downloaded)
-R, --no-ro-root     Don't enable read only root with overlay
-S, --no-scripts     Don't run scripts from scripts folder
-A, --no-armscripts  Don't run scripts from scripts_arm
-t, --set-tftproot   Make a link at /stv/tftp pointing to $target_path/boot
-P, --no-passwd      Don't prompt for new 'pi' user password
                     Leaving default password is UNSECURE (unless --githubuser
                     is used)
    --githubuser     Add github user public keys (downloaded from
                     https://github.com/[githubuser].keys)
                     to 'pi' user ~/.ssh/authorized_keys (implies --no-passwd)
    --arm-shell      Drop me into shell inside chrooted target location wsung
                     arm emulation. It happenes at the very end, right before
                     making tftp link (if requested). If you want to just drop
                     into shell use together with -D -S -A options.
```

### example 
To bootstrap to `/raspios_lite` run:
`sudo ./bootstrap /raspios_lite/`
Once all oparations and customizations are done user is prompted for pi user password. Alternatively ssh public keys can be obtained from github's user oublic keys link (https://github.com/[githubuser].keys) using --githubuser  option with an argument. 
If `-t` switch is used `bootstrap` will create a link at /srv/tftp pointing to `boot` of our target directory.

## scripts
Make sure to examine the scrpts in both `scripts` and `scrupts_arm` directories. 
