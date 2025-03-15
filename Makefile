#!/usr/bin/make -f
.PHONY: build clean post-deploy

all:
	make -C ipxe
	make -C live-system
