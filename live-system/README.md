# Build the netboot images

This directory contains all the tooling necessary to build the netboot images:

- kernel
- initramdisk
- live system .ISO file

To build the images, install Docker and `make` and run:

```bash
$ make
```

> [!TIP]
> The build requires privileged Docker containers, otherwise the build tools fail.

We're currently building the images based on Ubuntu 24.04 (Noble). The images will be placed in the `bin/noble/` directory.
You can copy them to a webserver of your choice.

> [!IMPORTANT]
> If you want to load the images from iPXE, the webserver must make them available over HTTP (it must not redirect to HTTPS).
> For kexec-based boot, the images can be available only over HTTPS.


# Exploring the initramfs

If you want to explore the initramfs built by the live system builder, on a Debian/Ubuntu system you can use `unmkinitramfs`:

```
$ mkdir -p /tmp/initramdisk
$ unmkinitramfs bin/noble/initrd.img /tmp/initramdisk
```

Your files will be stored in `/tmp/initramdisk`.
The `unmkinitramfs` binary comes from the `initramfs-tools-core` package.
