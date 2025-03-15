#!/usr/bin/env bash

apt-get -y install kexec-tools > /dev/null
# change this to the path where you keep the netboot images
# don't forget to update the IP to either "dhcp" or "static config", for examples see below
# IPv6 config in the preboot environment supports only "none" or "dhcp", static config isn't possible
#
# Don't forget the last slash/!
URL_PREFIX="http://your-webserver/images/noble/"
KERNEL="vmlinuz"
INITRD="initrd.img"

echo "=========="
echo "Downloading vmlinuz and initrd.img..."
SQUASHFS="${URL_PREFIX}/filesystem.iso"
wget -q -O /tmp/kernel "${URL_PREFIX}${KERNEL}"
wget -q -O /tmp/initrd "${URL_PREFIX}${INITRD}"

# Internet-connected network card autodetection (using a configured default gateway)
DEVICE=`awk '($2 == "00000000"){print $1; }' < /proc/net/route | head -1`
if [ -z "${DEVICE}" ]; then
    echo "IPv4 default route not found, trying IPv6"
    DEVICE=`egrep '^00000000000000000000000000000000 ' /proc/net/ipv6_route | grep -v lo | awk '{print $NF}' | head -1`
fi
echo "Uplink interface: ${DEVICE}"
MAC=$(cat /sys/class/net/${DEVICE}/address)
MAC=${MAC//:/-}
echo "MAC (hex-hyphenated): ${MAC}"

# IP configs
## Set to "none" if not using IPv4, "dhcp" if using DHCPv4, or to a specific value (see below) for static config
IP="none"
## IPv4 static config example:
## IP="192.0.2.2::192.0.2.1:255.255.255.0::${DEVICE}:off:8.8.8.8"
## Set to "none" if using none or manual IPv6 config, or to "dhcp" if using DHCPv6
IP6="none"
## Set to empty, if using DHCPv6, or to static addr like this
## "addr=2001:db8::1/64,gw=fe80::1,dns=2001:4860:4860::8888"
## Alternatively enable SLAAC like this
## "accept_ra=1"
IPV6="addr=2001:db8::1/64,gw=fe80::1,dns=2001:4860:4860::8888"

# Kernel command line
CMDLINE="boot=casper noprompt noeject live-config.username=root BOOTIF=01-${MAC} showmounts ip6=${IP6} ip=${IP} ipv6=${IPV6} url=${SQUASHFS}"

# Print the IPs and command line out
echo "=========="
echo -e "IP configs:\nIPv4: ${IP}\nIPv6 (casper): ${IP6}\nIPv6 (custom script): ${IPV6}"
echo "Kernel cmdline: ${CMDLINE}"

# Load the kernel and initramdisk and clean up the filesystem
kexec -l /tmp/kernel --initrd=/tmp/initrd --append="${CMDLINE}"
rm /tmp/kernel /tmp/initrd

# Let the user do the rest
echo "=========="
echo "If you get the 'kexec_load failed: Operation not permitted' error message above, and you are running on UEFI, turn off Secure Boot first."
echo ""
echo "Now run \`kexec -e\` to boot into the loaded kernel."
echo "=========="
