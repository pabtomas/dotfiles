ARG _BUILDKIT_LOCAL_IMG
FROM ${_BUILDKIT_LOCAL_IMG}

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG REGISTRY_TARGET

USER root

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    etc_buildkit='/etc/buildkit'
    mkdir -p "${etc_buildkit}"
    cat << TEMPLATING >> "${etc_buildkit}/buildkitd.toml"
[log]
  format = "text"

[registry."${REGISTRY_TARGET}"]
  http = true
  insecure = true
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

USER user
