ARG OS_IMG

FROM ${OS_IMG} as tpm_image

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
