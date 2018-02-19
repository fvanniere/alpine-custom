Custom Alpine ISO builder
=========================

You need and install alpine system on a disk drive with enought disk space, this system is `alpine-master`

Setup the `alpine-master` with doc from https://wiki.alpinelinux.org/wiki/How_to_make_a_custom_ISO_image_with_mkimage

```bash
apk add alpine-sdk build-base apk-tools alpine-conf busybox fakeroot syslinux xorriso
adduser build -G abuild
cd /root/
git clone git://git.alpinelinux.org/aports
apk update
```

Copy the 3 files from builder directory to `alpine-master/root/`

* *build-iso.sh* in `/root/` for building an ISO
* *genapkovl-custom.sh* and *mkimg.custom.sh* in `/root/aports/scripts`

Edit *build-iso.sh* for your needs

The script `run-qemu.sh` is an exemple for running a custom ISO with autoconfiguration for network
