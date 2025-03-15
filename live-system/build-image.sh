#!/bin/bash

# This script is typically executed from within a privileged docker container.
# You may try running it on the host node if you set the BUILD env variable to "yes", however it's not supported.
# You have been warned.
# Also, if you want to execute it directly on your workstation, don't forget to set the SSH_KEYS and OS_VERSION variables.
if [ "$BUILD" != "yes" ]; then
    echo "Do not execute this script directly. Run make instead."
    exit 1
fi
set -x

export DEBIAN_FRONTEND=noninteractive
export TZ=Etc/UTC

apt-get update
apt-get -y install vim live-build fdisk genisoimage dctrl-tools

mkdir -p /live/files/includes.chroot/root/.ssh/
wget -O /live/files/includes.chroot/root/.ssh/authorized_keys "${SSH_KEYS}"

rm -rf /live/tmp
mkdir -p /live/tmp
mkdir -p /live/bin/$OS_VERSION/iso/casper
cd /live/tmp/

lb config \
    --distribution $OS_VERSION \
    --binary-images netboot \
    --debconf-frontend noninteractive \
    --chroot-filesystem squashfs \
    --archive-areas "main restricted universe multiverse" \
    --apt-options "--yes" \
    --bootappend-live "keyboard-layouts=no" \
    --mode ubuntu \
    --firmware-chroot false \
    --syslinux-theme live-build \
    --binary-images iso

for source_config in $(ls /live/files); do
    cp -r /live/files/${source_config} /live/tmp/config/
done

lb build

cp /live/tmp/binary/casper/filesystem.squashfs /live/bin/$OS_VERSION/iso/casper/
mkdir -p /live/bin/$OS_VERSION/iso/.disk/
ln -s /conf/uuid.conf /live/bin/$OS_VERSION/iso/.disk/casper-uuid
genisoimage -v -ldots -r -V NETBOOT -o /live/bin/$OS_VERSION/filesystem.iso /live/bin/$OS_VERSION/iso/

cp /live/tmp/binary/casper/initrd.img* /live/bin/$OS_VERSION/initrd.img
cp /live/tmp/binary/casper/vmlinuz* /live/bin/$OS_VERSION/vmlinuz
cp /live/tmp/binary/casper/memtest /live/bin/$OS_VERSION/memtest
chmod go+r -R /live/bin/$OS_VERSION/
rm -rf /live/tmp /live/bin/$OS_VERSION/iso
echo "Your boot files should be located in bin/$OS_VERSION/ folder. Here's a list of files for you:"
ls -l /live/bin/$OS_VERSION/
