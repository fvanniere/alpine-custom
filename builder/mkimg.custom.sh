profile_custom() {
        profile_virt
        kernel_cmdline="unionfs_size=128M console=tty0 console=ttyS0,115200"
	initfs_cmdline="modules=loop,squashfs,sd-mod quiet"
        syslinux_serial="0 115200"
        apks="$apks util-linux bash vim python3"
	apkovl="genapkovl-custom.sh"
	#kernel_flavors="vanilla"
}

