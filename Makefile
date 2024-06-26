VFLAGS=
ifeq (1,${RELEASE})
	VFLAGS:=$(VFLAGS) -prod
endif
ifeq (1,${MACOS_ARM})
	VFLAGS:=-cflags "-target arm64-apple-darwin" $(VFLAGS)
endif
ifeq (1,${LINUX_ARM})
	VFLAGS:=-cc aarch64-linux-gnu-gcc $(VFLAGS)
endif
ifeq (1,${WINDOWS})
	VFLAGS:=-os windows $(VFLAGS)
endif

all: check build test

check:
	v fmt -w .
	v vet .

build:
	v $(VFLAGS) -enable-globals -o litedms .

test:
	v test .

clean:
	rm -rf src/*_test src/*.dSYM litedms

start:
	./litedms &

ping:
	curl -s -w "%{http_code}" http://localhost:8020/ping

stop:
	curl -X POST -s -w "%{http_code}" http://localhost:8020/shutdown

docker: docker-lint docker-build

docker-lint:
	docker run --rm -i \
		-v ${PWD}/.hadolint.yaml:/bin/hadolint.yaml \
		-e XDG_CONFIG_HOME=/bin hadolint/hadolint \
		< Dockerfile

docker-build:
	docker build -t litedms .

docker-start:
	docker run --rm -dt -p 8020:8020 -v ${PWD}/storage:/storage \
		--name litedms litedms

docker-enter:
	docker run --rm -it -p 8020:8020 -v ${PWD}/storage:/storage \
		--entrypoint sh litedms

docker-kill:
	docker container kill litedms

docker-log:
	docker logs litedms

docker-up:
	IMAGE_HUB= docker compose -f docker-compose.yml up -d

docker-down:
	IMAGE_HUB= docker compose -f docker-compose.yml down

docker-log1:
	docker logs litedms-litedms-1
