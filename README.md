# pi-nfs

Tool to make pi boot from network

It's main purpose is to setup netbooted kiosk but can be easily modied and extended to bootstrap other configurations.
Among some of its unique features is allowing pi to boot with read only root filesystem with overlay (this can be be of course tuned).
All custimizations are stored in scripts and thus cen easily be examined and altered.
It works only on Ubuntu/debian hosts running on x64 CPU. We'll call it 'the server' :)


## configuration
First thing you need to do is edit the ENV file and set appropriate options. The most important is `NFS_IP=` variable specifying the server's IP facing the raspberries to be booted. 

## bootsrap

`bootstrap` script is the central part of the solution. Its main job is to load convifuration from `ENV` file and execute scripts from `scripts` and `scripts_arm` directories. It has one required positional argument, the path to directory that will be filled with ootstraped raspios image.

### options
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


