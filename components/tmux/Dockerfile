ARG BASH_COMPONENT_IMG
FROM ${BASH_COMPONENT_IMG}

ARG BASH_COMPLETION_PATH
ARG TMUX_COMPLETION_URL
ARG TPM_PATH
ARG TPM_URL
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache --virtual __install_plugins git
    git clone --depth=1 "${TPM_URL}" "${TPM_PATH}"
    apk del __install_plugins
    apk add --no-cache tmux tmuxinator tmuxinator-bash-completion
    wget -q -O "${BASH_COMPLETION_PATH}/99tmux.sh" "${TMUX_COMPLETION_URL}"
    unset http_proxy https_proxy
END_OF_RUN

COPY .tmux.conf /root/
COPY etc/ /etc/
