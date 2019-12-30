FROM golang:1.13.4-buster AS builder

ENV GO111MODULE on
ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOARCH amd64

WORKDIR /opt/jenkins-exporter

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -ldflags '-extldflags "-static"' -o jenkins-exporter main.go

FROM alpine:3.11.2
WORKDIR /opt/jenkins-exporter

RUN addgroup -S jenkinsexporter && adduser -S jenkinsexporter -G jenkinsexporter
USER jenkinsexporter

COPY --from=builder /opt/jenkins-exporter/jenkins-exporter .

EXPOSE 8123/tcp

CMD ["sh", "-c", "./jenkins-exporter"]
