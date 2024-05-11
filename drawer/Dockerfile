ARG OS_IMG
FROM ${OS_IMG} as cloner_image

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache git
    git clone --depth=1 "${FIGLET_FONTS_URL}" /usr/share/figlet/fonts/
    unset http_proxy https_proxy
END_OF_RUN

ARG OS_IMG
FROM ${OS_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache figlet lolcat
    unset http_proxy https_proxy
END_OF_RUN

COPY --from=clone_image /usr/share/figlet/fonts/* /usr/share/figlet/fonts/
