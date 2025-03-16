#!/usr/bin/env bash

if [ "$BUILD" != "yes" ]; then
    echo "Do not execute this script directly. Run make instead."
    exit 1
fi

set -ex

. ./params

export DEBIAN_FRONTEND=noninteractive
export TZ=Etc/UTC

apt-get update
apt-get -y install build-essential dosfstools xorriso git liblzma-dev

ROOTDIR="$(pwd)"
BINDIR="$ROOTDIR/bin"
BUILDDIR="$(mktemp -d)"

mkdir -p "$BINDIR"
mkdir -p "$BUILDDIR" && cd "$BUILDDIR"

[ -d ipxe ] && rm -rf ipxe
git clone https://github.com/ipxe/ipxe.git

cd ipxe
git checkout "$IPXE_GIT_COMMIT" # you can use git tag name or git commit hash here

# build ipxe
cd src

# enable vlan and ping by editing src/config/general.h
# #define VLAN_CMD               /* VLAN commands */
# #define PING_CMD               /* Ping command */
sed -i -E 's^//#define ((PING|VLAN).*)^#define \1^' config/general.h

# build the versions without embedded scripts
# the files will be in in:
# - ipxe/src/bin/undionly.kpxe (legacy boot)
# - ipxe/src/bin-x86_64-efi/ipxe.efi (uefi binary)
make bin/undionly.kpxe
cp bin/undionly.kpxe "$BINDIR/undionly.kpxe"

# build the versions with embedded scripts AND IPv6
sed -i -E 's^//#define (NET_PROTO_IPV6.*)^#define \1^' config/general.h
make bin/ipxe.dsk "EMBED=$ROOTDIR/embed.ipxe"

# make bin-i386-efi/ipxe.efi would build a 32-bit EFI version (obsolete these days)

make bin-x86_64-efi/ipxe.efi
cp bin-x86_64-efi/ipxe.efi "$BINDIR/ipxe64.efi"

make bin-x86_64-efi/ipxe.efi "EMBED=$ROOTDIR/embed.ipxe"

# the files with embedded script are in bin/ipxe.dsk and bin-x86_64-efi/ipxe.efi
cd "$BUILDDIR"

# create the legacy boot floppy
dd bs=512 count=2880 if=/dev/zero of="$BINDIR/ipxe-floppy-legacy.img"
dd if=ipxe/src/bin/ipxe.dsk of="$BINDIR/ipxe-floppy-legacy.img" bs=1 conv=notrunc

# create the UEFI boot floppy
dd bs=512 count=2880 if=/dev/zero of="$BINDIR/ipxe-floppy-uefi.img"
mkfs.vfat -F12 "$BINDIR/ipxe-floppy-uefi.img"
mkdir -p "$BUILDDIR/floppy"
mount -o loop "$BINDIR/ipxe-floppy-uefi.img" "$BUILDDIR/floppy"
mkdir -p "$BUILDDIR/floppy/EFI/BOOT/"
cp ipxe/src/bin-x86_64-efi/ipxe.efi "$BUILDDIR/floppy/EFI/BOOT/bootx64.efi"
umount "$BUILDDIR/floppy"

# create the hybrid legacy/UEFI boot ISO
mkdir -p "$BUILDDIR/iso"
cd "$BUILDDIR/iso"
cp "$BINDIR/ipxe-floppy-legacy.img" .
cp "$BINDIR/ipxe-floppy-uefi.img" .
xorriso \
    -as mkisofs \
    -iso-level 4 \
    -J -R -D -V "NETBOOT" \
    -b ipxe-floppy-legacy.img \
    -hide boot.catalog \
    -eltorito-alt-boot \
    -eltorito-platform efi \
    -no-emul-boot \
    -b ipxe-floppy-uefi.img \
    -o "$BINDIR/ipxe-iso-uefi.iso" \
    .

cd /
rm -rf "$BUILDDIR"
