.DEFAULT_GOAL := default
.PHONY: all
BINARY_NAME=kv2

build:
	CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -o bin/${BINARY_NAME}-linux-amd64 cmd/server/main.go
	CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -o bin/${BINARY_NAME}-client-linux-amd64 cmd/client/main.go
	CGO_ENABLED=0 GOARM=6 GOARCH=arm GOOS=linux go build -o bin/${BINARY_NAME}-linux-arm cmd/server/main.go
	CGO_ENABLED=0 GOARM=6 GOARCH=arm GOOS=linux go build -o bin/${BINARY_NAME}-client-linux-arm cmd/client/main.go
	CGO_ENABLED=0 GOARCH=arm64 GOOS=linux go build -o bin/${BINARY_NAME}-linux-arm64 cmd/server/main.go
	CGO_ENABLED=0 GOARCH=arm64 GOOS=linux go build -o bin/${BINARY_NAME}-client-linux-arm64 cmd/client/main.go
	CGO_ENABLED=0 GOARCH=arm64 GOOS=darwin go build -o bin/${BINARY_NAME}-mac-arm64 cmd/server/main.go
	CGO_ENABLED=0 GOARCH=arm64 GOOS=darwin go build -o bin/${BINARY_NAME}-client-mac-arm64 cmd/client/main.go
	CGO_ENABLED=0 GOARCH=amd64 GOOS=darwin go build -o bin/${BINARY_NAME}-mac-amd64 cmd/server/main.go
	CGO_ENABLED=0 GOARCH=amd64 GOOS=darwin go build -o bin/${BINARY_NAME}-client-mac-amd64 cmd/client/main.go
	chmod +x bin/*

build_mac_arm64:
	CGO_ENABLED=0 GOARCH=arm64 GOOS=darwin go build -o bin/${BINARY_NAME}-mac-arm64 cmd/server/main.go
	CGO_ENABLED=0 GOARCH=arm64 GOOS=darwin go build -o bin/${BINARY_NAME}-client-mac-arm64 cmd/client/main.go
	chmod +x bin/*

test_mac_arm64:
	./bin/kv2-mac-arm64 &
	cd pkg/client/client && go test -count=1 -v -bench ./
	kill %1

run:
	./bin/kv2-linux-arm64 &

test:
	cd pkg/client/client && go test -count=1 -v -bench ./
	kill $(ps aux | grep kv2 | grep -v grep | awk '{print $2}') || true

get:
	go mod tidy
	go get ./...

default: get build run test