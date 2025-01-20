FROM alpine
ENV PORT=873 \
    MAX_CONN=1 \
    DISK_LIMIT=60 \
    DISK_HARD_LIMIT=85
RUN (echo "@edge-main https://dl-cdn.alpinelinux.org/alpine/edge/main"; echo "@edge-community https://dl-cdn.alpinelinux.org/alpine/edge/community") >> /etc/apk/repositories \
 && apk upgrade --no-cache \
 && apk add --no-cache rsync@edge-main \
 && apk add --no-cache supervisor bash coreutils findutils python3
COPY files /
ENTRYPOINT ["supervisord", "-nkc/etc/supervisord.conf"]
