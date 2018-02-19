#!/bin/bash

VM_IMG=/data/VMs/alpine-master.qcow

reset
qemu-system-x86_64 -m 512M -enable-kvm \
	  -name alpine-master \
	  -netdev user,id=net0 -device virtio-net,netdev=net0 \
	  -drive file=$VM_IMG,format=qcow2,if=virtio \
	  -serial mon:stdio -nographic \
	  #-drive media=cdrom,file="/tmp/alpine-extended-3.7.0-x86_64.iso",if=virtio
      
      
