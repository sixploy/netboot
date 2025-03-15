# Netboot images

Have you ever worked with a system on the other side of the planet?
Have you struggled loading ISO files over IPMI consoles?
Have you met a VPS provider that doesn't provide remote console to help you with tasks like
repartitioning of the disk the system is running on, or complete reinstallation of the system?

This repository is here to provide an alternative way to solve these problems, using iPXE and a live boot image:

- if you can make the remote server boot from network, you can load iPXE from the network
- if you can mount ISO or a floppy image over IPMI, you can start iPXE from these images
- if none of the above works, but you still have a running system available, you can download the kernel and initramdisk manually and use [`kexec`](https://linux.die.net/man/8/kexec) instead of iPXE

## iPXE options and images
It's not trivial to figure out the right iPXE options.

- For network boot, you can check the [Network Boot To The Rescue](network-boot-to-the-rescue.md) article, which provides a sample `script.ipxe`
- For kexec, check the [`kexec` README](kexec/README.md)

You will also need the iPXE images. [You can build ones yourself easily.](ipxe/README.md)

## Live image
Both iPXE and `kexec` will require images to load. With that, our [live image](live-system/README.md) helps you.

