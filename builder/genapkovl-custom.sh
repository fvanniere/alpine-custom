#!/bin/sh -e

echo "======= CONFIG $PWD =============="
echo "$*"
echo "================================="

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	echo "usage: $0 hostname"
	exit 1
fi

cleanup() {
	rm -rf "$tmp"
}

makefile() {
	OWNER="$1"
	PERMS="$2"
	FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}

rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc
makefile root:root 0644 "$tmp"/etc/hostname <<EOF
$HOSTNAME
EOF

mkdir -p "$tmp"/etc/network
makefile root:root 0644 "$tmp"/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

mkdir -p "$tmp"/etc/apk
makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
alpine-base
util-linux
bash
bash-completion
vim
EOF

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot
rc_add networking boot
rc_add urandom boot
rc_add keymaps boot

rc_add local default
rc_add dropbear default

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

mkdir -p "$tmp/root/.ssh"
mkdir -p "$tmp/etc/apk"
echo '/media/cdrom' >> "$tmp/etc/apk/repositories"
echo 'http://uk.alpinelinux.org/alpine/v3.7/main' >> "$tmp/etc/apk/repositories"
#echo 'PS1=\'\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \'' > "$tmp/root/.profile" 

mkdir -p "${tmp}/etc/local.d/"
cp /etc/inittab "$tmp/etc/inittab"
cp /etc/passwd "$tmp/etc/passwd"
cp /root/.profile "$tmp/root/.profile"

# Hostname setup script 
cat > "$tmp/etc/local.d/hostname.start" << EOF
#!/bin/sh

HOSTNAME=\$(cat /sys/devices/virtual/dmi/id/board_serial)
sed -i -e "s/alpine/\$HOSTNAME/g" /etc/hostname /etc/hosts
hostname \$HOSTNAME
EOF
chmod +x "$tmp/etc/local.d/hostname.start"

# IP setup script
cat > "$tmp/etc/local.d/ip-eth1.start" << EOF
#!/bin/sh

ip link set eth1 up
IP=\$(cat /sys/devices/virtual/dmi/id/product_serial)
ip add add \$IP dev eth1
echo "IP eth1: \$IP" > /etc/motd
EOF
chmod +x "$tmp/etc/local.d/ip-eth1.start"

# autoconf setup script
cat > "$tmp/etc/local.d/autoconf.start" << EOF
#!/bin/sh

URL=\$(cat /sys/devices/virtual/dmi/id/board_asset_tag)
wget -T 2 -O /tmp/autoconf.sh "\$URL"
if [ \$? -eq 0 ]
then
    chmod +x /tmp/autoconf.sh
    /tmp/autoconf.sh 2>&1 > /tmp/autoconf.log
    echo "Autoconf done from \$URL
else
    echo "Failed to fetch \$URL
fi
EOF
chmod +x "$tmp/etc/local.d/autoconf.start"

tar -c -C "$tmp" etc | gzip -9n > $HOSTNAME.apkovl.tar.gz
