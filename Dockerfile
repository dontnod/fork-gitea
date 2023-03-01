#Build stage
FROM docker.io/library/golang:1.20-bullseye AS build-env

ARG GOPROXY
ENV GOPROXY ${GOPROXY:-direct}

ARG TAGS=""
ENV TAGS "bindata $TAGS"
ARG CGO_EXTRA_CFLAGS

#Build deps
# RUN apk --no-cache add build-base git nodejs npm
RUN apt-get update
RUN apt-get install -y git
# nodejs in bullseye is too old
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs
RUN rm -rf /var/lib/apt/lists/*

#Setup repo
# <- COPY go.mod and go.sum files
RUN mkdir /deps
WORKDIR /deps
COPY go.mod .
COPY go.sum .
RUN go mod download -x

COPY package-lock.json .
COPY package.json .
RUN npm install --global


WORKDIR ${GOPATH}/src/gitea

RUN git config --global --add safe.directory ${GOPATH}/src/gitea
