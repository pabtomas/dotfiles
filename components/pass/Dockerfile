ARG SSHD_COMPONENT_IMG
FROM ${SSHD_COMPONENT_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache pass git gpg-agent git-bash-completion pass-bash-completion
    unset http_proxy https_proxy
END_OF_RUN
