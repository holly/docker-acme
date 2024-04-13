FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
ENV LS_COLORS di=01;36
COPY app/*.sh /app/
VOLUME [ "/vols/html", "/vols/ssl" ]
RUN --mount=type=cache,target=/var/lib/apt/lists --mount=type=cache,target=/var/cache/apt/archives \
 apt update \
 && apt install -y --no-install-recommends curl git cron ca-certificates socat openssl \
 && touch /app/acme_domains.txt \
 && chmod +x /app/*.sh 

ENTRYPOINT [ "/app/entrypoint.sh" ]
