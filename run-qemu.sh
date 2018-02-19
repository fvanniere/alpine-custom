#!/bin/bash

BASE_NAME=alpine-fred
BASE_IP=192.168.1.2
NETMASK="24"
VM_IMG=alpine.qcow


if [ -z $1 ]
then
	VM_ID=0
	VM_NAME=${BASE_NAME}
	VM_IP=${BASE_IP}${VM_ID}/$NETMASK
else
        VM_ID=$1	  
	VM_NAME=${BASE_NAME}-$1
	VM_IP=${BASE_IP}${VM_ID}/$NETMASK
fi

AUTOCONF_SCRIPT=http://192.168.1.100:8087/autoconf/${VM_NAME}/
MACADDR=00:16:3E:00:$(printf '%02X:%02X\n' $((RANDOM%256)) $((RANDOM%256)))

reset
qemu-system-x86_64 -m 512M -enable-kvm \
	  -name ${VM_NAME} \
	  -vga cirrus -cpu host \
	  -smbios type=1,serial="$VM_IP",version="$VM_NAME" \
	  -smbios type=2,location="$VM_IP",serial="$VM_NAME",asset="$AUTOCONF_SCRIPT" \
	  -netdev user,id=net0 -device virtio-net,netdev=net0 \
	  -netdev tap,id=net1,ifname=tap${VM_ID},script=no,downscript=no \
	  -device virtio-net,netdev=net1,mac=$MACADDR \
	  -serial mon:stdio -nographic \
	  -drive media=cdrom,file="/data/VMs/alpine-custom-BADGE-x86_64.iso",if=virtio \
	  -boot d

	  # -netdev socket,id=net1,connect=:1234 \
	  #-drive file="/data/VMs/alpine.qcow",format=qcow2,if=virtio,boot=off \
      
