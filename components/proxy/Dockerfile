ARG NGINX_COMPONENT_IMG
ARG LINUXSERVER_PROXY_LOCAL_IMG

FROM ${LINUXSERVER_PROXY_LOCAL_IMG} as linuxserver_img
FROM ${NGINX_COMPONENT_IMG}

ARG ENTRYPOINTD_PATH
ARG ETC_NGINX_PATH
ARG NGINX_DEFAULT_CONF_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    cat << TEMPLATING >> "${ETC_NGINX_PATH}/http.d/proxy.conf"
include ${ETC_NGINX_PATH}/proxy.conf;
TEMPLATING
    checkdefault_entrypoint="${ENTRYPOINTD_PATH}/98checkdefault.sh"
    cat << TEMPLATING >> "${checkdefault_entrypoint}"
#! /bin/sh

main ()
{
  set -eux
  if [ ! -r '${NGINX_DEFAULT_CONF_PATH}' ]
  then
    exit 1
  fi
}

main
TEMPLATING
    chmod 0700 "${checkdefault_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN

COPY --from=linuxserver_img ${ETC_NGINX_PATH}/nginx.conf ${ETC_NGINX_PATH}/
COPY --from=linuxserver_img ${ETC_NGINX_PATH}/proxy.conf ${ETC_NGINX_PATH}/
