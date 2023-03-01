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
RUN apt-get --yes install --no-install-recommends git ca-certificates curl gnupg && apt-get --yes clean
# nodejs in bullseye is too old
# Use the version from the alpine version used by Gitea in their dockerfile
RUN \
    mkdir -p /etc/apt/keyrings && \
    (curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg) && \
    (echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list) && \
    apt-get update && \
    apt-get --yes install --no-install-recommends nodejs && \
    apt-get --yes clean

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
