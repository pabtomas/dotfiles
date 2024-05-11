ARG SSHD_COMPONENT_IMG
FROM ${SSHD_COMPONENT_IMG}

ARG WORKSPACES_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache git tig ripgrep
    mkdir -p "${WORKSPACES_PATH}"
    cat << TEMPLATING >> /etc/profile.d/99default_dir.sh
cd "${WORKSPACES_PATH}"
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/profile.d/* /etc/profile.d/

WORKDIR ${WORKSPACES_PATH}
