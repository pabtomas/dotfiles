FROM alpine:3.20

RUN apk add --no-cache xterm; adduser -D -s /bin/sh -g 'visitor' 'visitor'

ENV DISPLAY :0

USER visitor

ENTRYPOINT ["sh"]
