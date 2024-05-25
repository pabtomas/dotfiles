FROM alpine:3.20

RUN apk add --no-cache xterm;adduser -D -s /bin/sh -g 'visitor' 'visitor'

ENV DISPLAY 172.17.3.2:2365

USER visitor

ENTRYPOINT ["sh"]
