ARG OS_IMG
FROM ${OS_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache ruby ruby-dev build-base cmake icu-dev zlib-dev openssl-dev libcurl
    gem install github-linguist
    unset http_proxy https_proxy
END_OF_RUN
