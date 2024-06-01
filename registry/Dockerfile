ARG REGISTRY_LOCAL_IMG

FROM ${REGISTRY_LOCAL_IMG}

ARG DATA_PATH
ARG REGISTRY_LOG_ACCESSLOG_DISABLED=false
ARG REGISTRY_LOG_LEVEL=info
ARG REGISTRY_LOG_FORMATTER=test
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache --virtual __yq yq
    yq -i ".log |= (. + {\"accesslog\": {\"disabled\": ${REGISTRY_LOG_ACCESSLOG_DISABLED}}, \"level\": \"${REGISTRY_LOG_LEVEL}\", \"formatter\": \"${REGISTRY_LOG_FORMATTER}\"}), .storage |= (. + {\"filesystem\": {\"rootdirectory\": \"${DATA_PATH}\"}})" /etc/docker/registry/config.yml
    apk del __yq
    unset http_proxy https_proxy
END_OF_RUN
