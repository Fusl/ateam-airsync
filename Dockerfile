FROM alpine:edge
RUN apk upgrade --no-cache \
 && apk add --no-cache rsync supervisor bash coreutils
COPY files /
ENTRYPOINT ["supervisord", "-nkc/etc/supervisord.conf"]
