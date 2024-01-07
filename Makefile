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

stop:
	curl -X POST -s -w "%{http_code}" http://localhost:8020/shutdown

build-docker:
	docker build -t litedms .

start-docker:
	docker run --rm -dt -p 8020:8020 -v $PWD/storage:/litedms/storage \
		--name litedms litedms

kill-docker:
	docker container kill litedms

logs-docker:
	docker logs litedms
