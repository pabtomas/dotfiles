FROM alpine:3.19
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/
ENTRYPOINT ["tail", "-f", "/dev/null"]
