#!/usr/bin/make -f
.PHONY: build clean post-deploy

all: build post-deploy

build: clean
	docker run \
		-i \
		--rm \
		-v $(CURDIR):/live \
		--privileged=true \
		--name netboot \
		--entrypoint=/live/build-image.sh \
		-e BUILD=yes \
		-e OS_VERSION=noble \
		-e SSH_KEYS=https://github.com/zajdee.keys \
		ubuntu:noble

clean:
	rm -rf ./bin

post-deploy:
	[ -f ./post-deploy.sh ] && ./post-deploy.sh || exit 0
