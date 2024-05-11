ARG BASH_COMPONENT_IMG
ARG OS_IMG
FROM ${OS_IMG} as plugins_image

ARG TPM_PATH
ARG TPM_URL
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache git
    git clone --depth=1 "${TPM_URL}" "${TPM_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

FROM ${BASH_COMPONENT_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache tmux
    unset http_proxy https_proxy
END_OF_RUN

ARG TPM_PATH

COPY --from=plugins_image ${TPM_PATH}/* ${TPM_PATH}/
COPY .tmux.conf /root/
COPY etc/ /etc/
