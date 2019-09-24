FROM docker

# + docker-compose https://github.com/wernight/docker-compose/blob/master/Dockerfile

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates && \
    # Install glibc on Alpine (required by docker-compose) from
    # https://github.com/sgerrand/alpine-pkg-glibc
    # See also https://github.com/gliderlabs/docker-alpine/issues/11
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk && \
    apk add glibc-2.29-r0.apk && \
    rm glibc-2.29-r0.apk && \
    apk del --purge .deps

# Required for docker-compose to find zlib.
ENV LD_LIBRARY_PATH=/lib:/usr/lib

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates && \
    # Required dependencies.
    apk add --no-cache zlib libgcc curl make bash git vim openssh-keygen openssh-client && rm -rf /var/cache/apk/* && \
    # Install docker-compose.
    # https://docs.docker.com/compose/install/
    DOCKER_COMPOSE_URL=https://github.com$(wget -q -O- https://github.com/docker/compose/releases/latest \
        | grep -Eo 'href="[^"]+docker-compose-Linux-x86_64' \
        | sed 's/^href="//' \
        | head -n1) && \
    wget -q -O /usr/local/bin/docker-compose $DOCKER_COMPOSE_URL && \
    chmod a+rx /usr/local/bin/docker-compose && \
    \
    # Clean-up
    apk del --purge .deps && \
    docker-compose version

ENV PS1=\\h\\040\\w>\\040

WORKDIR /project

ENTRYPOINT ["make"]