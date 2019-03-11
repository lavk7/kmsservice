FROM golang

RUN apt update && \
    apt install -y uuid-runtime

WORKDIR /go/src/chainstack

ENV GOPATH=/go

COPY . .

RUN go get ./...

CMD ["go", "run", "cmd/kms/main.go"]
