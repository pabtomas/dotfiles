FROM alpine:3.20

RUN apk add --no-cache xterm

ENV DISPLAY 172.17.3.2:2365

ENTRYPOINT ["sh", "-c", "env; xterm"]
