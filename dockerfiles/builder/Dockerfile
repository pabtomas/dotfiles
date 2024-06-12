ARG _BUILDKIT_LOCAL_IMG

FROM ${_BUILDKIT_LOCAL_IMG}

ARG _BUILDKIT_CONF_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG REGISTRY_TARGET

USER root

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    mkdir -p "$(dirname -- "${_BUILDKIT_CONF_PATH}")"
    cat << TEMPLATING >> "${_BUILDKIT_CONF_PATH}"
[log]
  format = "text"

[registry."${REGISTRY_TARGET}"]
  http = true
  insecure = true
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

USER user
