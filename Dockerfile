FROM alpine:latest

COPY go-helloworld-http /go-helloworld-http

ENTRYPOINT ["/go-helloworld-http"]
