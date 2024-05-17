ARG OS_LOCAL_IMG
FROM ${OS_LOCAL_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache --virtual __install_linguist ruby-dev build-base cmake
    apk add --no-cache ruby cmake icu-dev zlib-dev openssl-dev libcurl
    gem install github-linguist
    apk del __install_linguist
    unset http_proxy https_proxy
END_OF_RUN

CMD ["github-linguist", "--version"]
