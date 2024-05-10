# FROM debian:stable-slim as builder
# LABEL maintainer="Ferdinand Prantl <prantlf@gmail.com>"

# RUN apt-get update -y && apt-get upgrade -y && \
#   apt-get install -y --no-install-recommends \
#     ca-certificates git make gcc binutils bash \
#     libc-dev libssl-dev libx11-dev libglfw3-dev libfreetype-dev libsqlite3-dev && \
#     apt-get clean && rm -rf /var/cache/apt/archives/* && rm -rf /var/lib/apt/lists/*

# WORKDIR /opt/vlang
# RUN git clone https://github.com/vlang/v /opt/vlang && make && ./v -version
# ENV PATH /opt/vlang:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# WORKDIR /src
# COPY Makefile data src v.mod /src/
# RUN v install && make RELEASE=1

FROM prantlf/vlang as builder

WORKDIR /src
COPY . .
RUN v install && make RELEASE=1

FROM prantlf/healthchk as healthchk

FROM busybox:stable
LABEL maintainer="Ferdinand Prantl <prantlf@gmail.com>"

COPY --from=builder /src/litedms /
COPY --from=healthchk /healthchk /

WORKDIR /
EXPOSE 8020
ENTRYPOINT ["/litedms"]

ARG DEBUG=litedms,dotenv
ENV DEBUG=${DEBUG}
ENV LITEDMS_COMPRESSION_LIMIT=1024
ENV LITEDMS_CORS_MAXAGE=86400
ENV LITEDMS_PORT=8020

# HEALTHCHECK --interval=5m \
#   CMD curl -f http://localhost:8020/ping || exit 1
