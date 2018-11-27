# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: target/share/install/build_stage2.sh
# Copyright (C) 2004 - 2018 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

. $base/misc/target/functions.in

set -e

echo_header "Creating 2nd stage filesystem:"
rm -rf $disksdir/2nd_stage*
mkdir -p $disksdir/2nd_stage; cd $disksdir/2nd_stage

#
package_map="00-dirtree               $SDECFG_LIBC
zlib
parted             cryptsetup
xfsprogs           mkdosfs            jfsutils           btrfs-progs
e2fsprogs          reiserfsprogs      reiser4progs       genromfs
popt               raidtools          mdadm              pcre
lvm                lvm2               device-mapper      libaio
dump               eject              disktype
hdparm             memtest86          cpuburn            bonnie++
ncurses            readline           libgpg-error       libgcrypt
bash               attr               acl                findutils
mktemp             coreutils          pciutils
grep               sed                gzip               bzip2
tar                gawk               lzo                lzop
less               nvi                bc                 cpio
xz                 zstd               ed                 zile
curl               dialog             minicom
lrzsz              rsync              tcpdump            module-init-tools
sysvinit           shadow             util-linux         wireless-tools
runit              runit-logacct      runit-shutdown
net-tools          procps             psmisc
modutils           pciutils           portmap
sysklogd           setserial          iproute2
netkit-base        netkit-ftp         netkit-telnet      netkit-tftp
sysfiles           libpcap            iptables           tcp_wrappers
stone              mkinitrd           rocknet
kbd		   ntfsprogs
libol              hotplug++          memtester
serpnp             udev
openssl            openssh            iproute2"

# TODO: a global multilib package multiplexer that allows distrinct control
#       and avoids such hacks ...
if [ "$SDECFG_SPARC64_32BIT" = "1" ]; then
	package_map="$package_map ${SDECFG_LIBC}32"
fi

if pkginstalled mine ; then
	packager=mine
else
	packager=bize
fi

package_map=" $( echo "$packager $package_map" | tr '\n' ' ' | tr '\t' ' ' | tr -s ' ' ) "

echo_status "Copying files."
for pkg in `grep '^X ' $base/config/$config/packages | cut -d ' ' -f 5`; do
	# include the package?
	#echo maybe $pkg >&2
	if [ "${package_map/ $pkg /}" != "$package_map" ]; then
		cut -d ' ' -f 2 $build_root/var/adm/flists/$pkg
	fi
done | (
	# quick and dirty filter
	grep  -v -e 'lib[^/]*/[^/]*\.\(a\|la\|o\)$' \
	         -e 'var/\(adm\|games\|mail\|opt\)' \
	         -e 'usr/\(local\|doc\|man\|info\|games\|share\|include\|src\)' \
	         -e 'usr/.*-linux-gnu' -e '/gconv/' -e '/locale/' -e '/pkgconfig/' \
	         -e '/init.d/' -e '/rc.d/'
	# TODO: usr/lib/*/
) > ../files-wanted

# some more stuff
cut -d ' ' -f 2 $build_root/var/adm/flists/{kbd,pciutils,ncurses} |
grep -e 'usr/share/terminfo/.*/\(ansi\|linux\|.*xterm.*\|vt.*\|screen\)' \
     -e 'usr/share/kbd/keymaps/i386/\(include\|azerty\|qwertz\|qwerty\)' \
     -e 'usr/share/kbd/keymaps/include' \
     -e 'usr/share/pci.ids' \
 >> ../files-wanted

copy_with_list_from_file $build_root $PWD $PWD/../files-wanted
copy_and_parse_from_source $base/target/share/install/rootfs $PWD

echo_status "Creating usability sym-links."
[ ! -e usr/bin/vi -a -e usr/bin/nvi ] && ln -s nvi usr/bin/vi
[ ! -e usr/bin/emacs -a -e usr/bin/zile ] && ln -s zile usr/bin/emacs

[ "$SDECFG_CROSSBUILD" != 1 ] && (chroot . /sbin/ldconfig || true)

mkdir -p mnt/source mnt/target
echo '$STONE install' > etc/stone.d/default.sh

echo_status "Creating 2nd_stage archive."
tar -c * | bzip2 > $isofsdir/2nd_stage.tar.bz2

cd $disksdir/

echo_header "Creating 2nd_stage_small filesystem:"
mkdir -p 2nd_stage_small; cd 2nd_stage_small

mkdir -p dev proc sys tmp bin etc share bin sbin usr/{bin,sbin}
mkdir -p mnt/{source,target}
#ln -s bin sbin ; ln -s . usr

progs="agetty bash cat cp date dd df dmesg ifconfig ln ls $packager mkdir \
       mkswap mount mv rm reboot route sleep swapoff swapon sync umount \
       eject chmod chroot grep halt rmdir sh shutdown uname killall5 \
       stone mktemp sort fold sed mkreiserfs cut head tail disktype \
       zstd bzip2 gzip mkfs.ext3 gasgui dialog stty wc fmt"

progs="$progs parted fdisk sfdisk"

if [ $arch = powerpc* ] ; then
	progs="$progs mac-fdisk pdisk"
fi

if [ $packager = bize ] ; then
	progs="$progs md5sum"
fi

for x in $progs ; do
	fn=""
	if   [ -f ../2nd_stage/bin/$x ]; then fn="bin/$x"
	elif [ -f ../2nd_stage/sbin/$x ]; then fn="sbin/$x"
	elif [ -f ../2nd_stage/usr/bin/$x ]; then fn="usr/bin/$x"
	elif [ -f ../2nd_stage/usr/sbin/$x ]; then fn="usr/sbin/$x"
	fi

	if [ "$fn" ] ; then
		cp ../2nd_stage/$fn $fn
	else
		echo_error "\`- Program not found: $x"
	fi
done

echo_status "Copy the required libraries ..."
found=1
while [ $found = 1 ]; do
	found=0
	for x in ../2nd_stage/{,usr/}lib{64,}; do
		for y in $( cd $x 2>/dev/null && ls *.so.* 2>/dev/null ); do
			dir=${x#../2nd_stage/}
			if [ ! -f $dir/$y ] &&
			   grep -q $y {s,}bin/* usr/{s,}bin/* lib{64,}/* 2> /dev/null
			then
				echo_status "\`- Found $dir/$y."
				mkdir -p $dir ; cp $x/$y $dir/$y
				found=1
			fi
		done
	done
done
#
echo_status "Copy /etc/fstab."
cp ../2nd_stage/etc/fstab etc
echo_status "Copy stone.d."
mkdir -p etc/stone.d
for i in gui_text gui_dialog mod_install mod_packages mod_gas default ; do
	cp ../2nd_stage/etc/stone.d/$i.sh etc/stone.d
done
echo_status "copy additional files."
mkdir -p usr/share/terminfo/l/
cp ../2nd_stage/usr/share/terminfo/l/linux usr/share/terminfo/l/linux

copy_and_parse_from_source $base/target/share/install/rootfs $PWD

echo_status "Creating links for identical files."
link_identical_files

echo_status "Creating 2nd_stage_small archive."
tar -c * | bzip2 -4 > $isofsdir/2nd_stage_small.tar.bz2

cd ..
