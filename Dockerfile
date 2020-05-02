FROM golang:1.14-alpine as buildstage


# later we'll use "gosu" to switch user and launch an unpriviledged rest-server
ADD https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64 /gosu
RUN chmod +x /gosu

# Also we'll boot from a little script (to ensure $DATA is chown'ed correctly)
# to ensure signals are passed all the way down to the rest-server 'dumb-init' will be used
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /dumb-init
RUN chmod +x /dumb-init

# do the build
WORKDIR /build
COPY . .
ENV GO111MODULE=on \
    GOOS=linux \
    GOARCH=amd64 \
    CGO_ENABLED=0
RUN go build -v ./cmd/rest-server


##############################################
FROM alpine

ENV LISTEN :8000
ENV DATA /data

# Ensure the "appuser" and "appgroup" exists in the container
RUN addgroup -g 1000 -S appuser  && \
    adduser -u 1000 -G appuser -S appuser

# Grab the binaries in
COPY --from=buildstage /build/rest-server /
COPY --from=buildstage /gosu /
COPY --from=buildstage /dumb-init /
COPY --from=buildstage /build/docker/entrypoint.sh /

CMD [ "/entrypoint.sh" ]
