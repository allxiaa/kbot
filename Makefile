APP=$(shell basename $(shell git remote get-url origin))
REGISTRYD=sae4xxx
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS ?= $(shell uname | tr '[:upper:]' '[:lower:]')
TARGETARCH ?= $(shell uname -m | sed -e 's/^armv[0-9].*/arm/' -e 's/^aarch64/arm64/' -e 's/^x86_64/amd64/' -e 's/^i.86/386/')

format:
	gofmt -s -w ./
lint:
	golint
test:
	go test -v

get:
	go get

build: format get
	
	CGO_ENABLED=0 G00S=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/allxiaa/kbot/cmd.appVersion=${VERSION}

image:
	docker --debug build . -t $(REGISTRYD)/$(APP):$(VERSION)-$(TARGETARCH)

push:
	docker push $(REGISTRYD)/$(APP):$(VERSION)-$(TARGETARCH)

clean:
	rm -rf kbot
	docker rmi $(REGISTRYD)/$(APP):$(VERSION)-$(TARGETARCH) || true