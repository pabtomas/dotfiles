ARG NGINX_COMPONENT_IMG
ARG LINUXSERVER_PROXY_LOCAL_IMG

FROM ${LINUXSERVER_PROXY_LOCAL_IMG} as linuxserver_img
FROM ${NGINX_COMPONENT_IMG}

ARG NGINX_DEFAULT_CONF_PATH

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
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
