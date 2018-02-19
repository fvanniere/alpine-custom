#!/bin/bash

cd ~/aports/scripts
./mkimage.sh  \
	--profile custom \
	--arch x86_64 \
	--repository http://uk.alpinelinux.org/alpine/latest-stable/main \
	--outdir /root/iso/ \
	--tag BADGE
scp /root/iso/alpine-custom-BADGE-x86_64.iso homere@10.0.2.2:/data/VMs/
