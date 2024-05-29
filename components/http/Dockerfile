ARG NGINX_COMPONENT_IMG
ARG LINUXSERVER_PROXY_LOCAL_IMG

FROM ${LINUXSERVER_PROXY_LOCAL_IMG} as linuxserver_img
FROM ${NGINX_COMPONENT_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG ETC_NGINX_HTTPD_PATH
ARG ETC_NGINX_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    cat << TEMPLATING >> "${ETC_NGINX_HTTPD_PATH}/proxy.conf"
include ${ETC_NGINX_PATH}/proxy.conf;
TEMPLATING
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux
  if [ ! -r '${ETC_NGINX_HTTPD_PATH}/default.conf' ]
  then
    exit 1
  fi
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY --from=linuxserver_img ${ETC_NGINX_PATH}/nginx.conf ${ETC_NGINX_PATH}/
COPY --from=linuxserver_img ${ETC_NGINX_PATH}/proxy.conf ${ETC_NGINX_PATH}/
