# ---------- STAGE 1: Build do oidcify ----------
FROM golang:1.23 AS builder

WORKDIR /build

# Habilita toolchains remotos
ENV GOTOOLCHAIN=auto

# Instala o toolchain go1.25.5
RUN go install golang.org/dl/go1.25.5@latest && \
    /go/bin/go1.25.5 download

# Clona o oidcify
RUN git clone https://github.com/hanlaur/oidcify.git .

# Usa o toolchain go1.25.5 para rodar go mod tidy
RUN /go/bin/go1.25.5 mod tidy

# Compila
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 /go/bin/go1.25.5 build -o oidcify .

# ---------- STAGE 2: Kong ----------
FROM kong:3.8

USER root

COPY --from=builder /build/oidcify /usr/local/bin/oidcify

RUN chmod +x /usr/local/bin/oidcify

ENV KONG_PLUGINS="bundled,oidcify"
ENV KONG_PLUGINSERVER_NAMES="oidcify"
ENV KONG_PLUGINSERVER_OIDCIFY_QUERY_CMD="/usr/local/bin/oidcify -dump"
ENV KONG_PLUGINSERVER_OIDCIFY_START_CMD="/usr/local/bin/oidcify"

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["kong", "docker-start"]