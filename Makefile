SHELL := /bin/bash
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

buildx:
	docker buildx build --platform="linux/arm/v7" -t loqutus/kv2:latest --push .
	docker buildx build --platform="linux/arm/v7" -t loqutus/kv2-test:latest --push -f ./Dockerfile-test .

build_mac_arm64:
	CGO_ENABLED=0 GOARCH=arm64 GOOS=darwin go build -o bin/${BINARY_NAME}-mac-arm64 cmd/server/main.go
	CGO_ENABLED=0 GOARCH=arm64 GOOS=darwin go build -o bin/${BINARY_NAME}-client-mac-arm64 cmd/client/main.go
	chmod +x bin/*

test_mac_arm64:
	./bin/kv2-mac-arm64 &
	KV2_LISTEN_PORT_CLIENT=6971 KV2_LISTEN_PORT_SERVER=6972 ./bin/kv2-mac-arm64 &
	sleep 1
	cd pkg/client/client && go test -count=1 -v -bench ./ || true
	for i in $$(ps aux | grep kv2 | grep -v grep | awk '{print $$2}'); do kill $$i; done

run:
	./bin/kv2-linux-arm64 &
	KV2_LISTEN_PORT_CLIENT=6971 KV2_LISTEN_PORT_SERVER=6972 ./bin/kv2-linux-arm64 &
	KV2_LISTEN_PORT_CLIENT=6973 KV2_LISTEN_PORT_SERVER=6974 ./bin/kv2-linux-arm64 &

run_mac_arm64:
	./bin/kv2-mac-arm64 &
	KV2_LISTEN_PORT_CLIENT=6971 KV2_LISTEN_PORT_SERVER=6972 ./bin/kv2-mac-arm64 &

test:
	cd pkg/client/client && go test -count=1 -v -bench ./

get:
	go mod tidy
	go get ./...

gocritic:
	gocritic check ./...

sleep:
	sleep 1

docker_arm64:
	docker build . -f Dockerfile-arm64 -t loqutus/kv2:latest-arm64
	docker build . -f Dockerfile-test -t loqutus/kv2-test:latest-arm64
	docker push loqutus/kv2:latest-arm64
	docker push loqutus/kv2-test:latest-arm64

docker_amd64:
	docker build . -f Dockerfile-amd64 -t loqutus/kv2:latest-amd64
	docker build . -f Dockerfile-test -t loqutus/kv2-test:latest-amd64
	docker push loqutus/kv2:latest-amd64
	docker push loqutus/kv2-test:latest-amd64

install:
	kubectl apply -f deployments/

uninstall:
	kubectl delete -f deployments/ || true

logs:
	kubectl wait --timeout=300s --for=condition=complete job/kv2-test || kubectl logs job/kv2-test; exit 1
	kubectl logs job/kv2-test

default: get build run sleep test