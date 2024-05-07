FROM debian:stable-slim as builder
LABEL maintainer="Ferdinand Prantl <prantlf@gmail.com>"

RUN apt-get update -y && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    ca-certificates git make gcc binutils bash \
    libc-dev libssl-dev libx11-dev libglfw3-dev libfreetype-dev libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/vlang
RUN git clone https://github.com/vlang/v /opt/vlang
RUN make && ./v -version
ENV PATH /opt/vlang:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /src
ADD Makefile data src v.mod /src
RUN v install
RUN make RELEASE=1

FROM busybox

COPY --from=builder /src/litedms /

WORKDIR /
EXPOSE 8020
ENTRYPOINT ["/litedms"]

HEALTHCHECK --interval=5m \
  CMD curl -f http://localhost:8020/ping || exit 1
