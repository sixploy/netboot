# Build the ipxe images

## Overview

This directory contains all the tooling necessary to build the ipxe images. The scripts build the following images:

| File | Boot Environment | Purpose/use
|---|---|---
| `ipxe64.efi` | UEFI | To be loaded during network boot
| `undionly.kpxe` | Legacy | To be loaded during network boot
| `ipxe-floppy-legacy.img` | Legacy | Boot floppy
| `ipxe-floppy-uefi.img` | UEFI | Boot floppy
| `ipxe-iso-uefi.iso` | UEFI/Legacy | Hybrid boot ISO

The boot ISO and floppies have the `embed.ipxe` file baked in. The default `embed.ipxe` offers DHCP and static configurations,
so you can load and boot those files on a remote server via IPMI quickly, and the rest will be retrieved from the server directly,
over the network.

## Configure your `embed.ipxe`

There's a sample `embed.example.ipxe`. Copy it to a file named `embed.ipxe` and adjust the `url_prefix` to point to the webserver holding your boot images.

## Post-build script

You can create a `post-deploy.sh` file, set it as executable, and it will be executed at the end of the build process automatically.

## Build

To build the images, install Docker and `make` and run:

```bash
$ make
```

> [!TIP]
> The build requires privileged Docker containers, otherwise the build tools fail.

We're currently building the images based on a [`master`](https://github.com/ipxe/ipxe) iPXE branch. The images will be placed in the `bin` directory.
