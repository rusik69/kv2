FROM --platform=$BUILDPLATFORM golang:1.18-alpine AS build-env
WORKDIR /go/src/github.com/rusik69/kv2
COPY . ./
ARG TARGETOS
ARG TARGETARCH
RUN go get ./...
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -o /go/bin/server cmd/server/main.go 

FROM alpine:latest
WORKDIR /
COPY --from=build-env /go/bin/server /usr/bin/kv2
ENTRYPOINT ["/usr/bin/kv2"]
EXPOSE 6969 6970 6971