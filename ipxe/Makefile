#!/usr/bin/make -f
.PHONY: build clean post-deploy

all: build post-deploy

build: clean
	[ ! -f script.ipxe ] && (echo "You did not provide script.ipxe. Please read the README."; exit 1)
	docker run \
		-i \
		--rm \
		-v $(CURDIR):/live \
		-w /live \
		-e BUILD=yes \
		--privileged=true \
		--name ipxe \
		--entrypoint=/live/build-ipxe.sh \
		ubuntu:noble

clean:
	rm -rf ./bin

post-deploy:
	[ -f ./post-deploy.sh ] && ./post-deploy.sh
