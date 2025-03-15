# Using `kexec` to load the netboot images

This directory contains a sample script to load the kernel and initramdisk from a remote location, build the kernel command line, and hand control over to the loaded kernel.

The script `kexec-reboot.sh` needs a small tuning for your use case:

- edit `URL_PREFIX` to point to your webserver with the netboot images
- change `IP`, `IP6` and `IPV6` to set your IPs (or set to use DHCP when applicable), see below
- set the uplink network MAC address as the `MAC` variable. The MAC must be provided in the hyphenated format, see below

The script only loads the kernel, initramdisk, and configures the kernel command line. Once that's done, it's up to you to fire the `kexec` by running

```
kexec -e
```

> [!IMPORTANT]
> If you have Secure boot enabled, you can only load kernels and initramdisks signed with the correct Secure boot keys.
> Failed to do so results in the `kexec_load failed: Operation not permitted` error.

## Network configuration

The script attempts to figure out what the uplink network card is, and then derive its hyphenated MAC address.

The typical MAC address in Linux uses colons, e.g. `54:00:11:de:ad:be`. The network boot scripts require colons to be replaced by dashes (hyphens), e.g. `54-00-11-de-ad-be`.

To configure IPv4, set the `IP` variable to one of the following options:

- `none`: IPv4 will not be configured
- `dhcp`: DHCPv4 will be used to configure IPv4
- specific static IP config, e.g. `192.0.2.2::192.0.2.1:255.255.255.0::${DEVICE}:off:8.8.8.8`

The static IP config uses the extended format, which is specified in the [kernel docs](https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt).

```
<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:<dns0-ip>:<dns1-ip>:<ntp0-ip>
```

To configure IPv6, there are two variables:

- `IP6` to configure the built-in IPv6 support of Debian/Ubuntu's initramdisk. Available values are `none` and `dhcp`
- `IPV6` to configure the [supplemental IPv6 config initramfs script](../live-system/files/includes.chroot/etc/initramfs-tools/scripts/casper-premount/35ipv6)

The supplemental IPv6 config script has the following options:

```
addr=2001:db8::/64,gw=fe80::1,iface=eth0,accept_ra=2,ll=fe80::2,forwarding=0,dns=2001:4860:4860::8888
```

For kexec, you will typically only want either of those two options:

- `addr=2001:db8::/64,gw=fe80::1,dns=2001:4860:4860::8888`: sets address/netmask and gateway statically and configures Google DNS
- `accept_ra=2,dns=2001:4860:4860::8888`: enables SLAAC and configures Google DNS

The netboot scripts attempt to determine the right network card by the provided MAC address.
