FROM alpine
ENV PORT=873 \
    MAX_CONN=1 \
    DISK_LIMIT=60 \
    DISK_HARD_LIMIT=85
RUN apk upgrade --no-cache \
 && apk add --no-cache rsync supervisor bash coreutils findutils python3
COPY files /
ENTRYPOINT ["supervisord", "-nkc/etc/supervisord.conf"]
