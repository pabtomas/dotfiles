ARG ENTRYPOINT_LAYER_IMG
FROM ${ENTRYPOINT_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG ENTRYPOINTD_PATH
ARG ETC_NGINX_CONFD_PATH
ARG ETC_NGINX_HTTPD_PATH
ARG VAR_LOG_NGINX_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache nginx-debug
    mkdir -p "${ETC_NGINX_CONFD_PATH}"
    cat << TEMPLATING > "${ETC_NGINX_HTTPD_PATH}/logging.conf"
log_format custom_http '\$remote_addr - \$remote_user [\$time_local] '
                       '"\$request" \$status \$body_bytes_sent '
                       '"\$http_referer" "\$http_user_agent" '
                       'rt=\$request_time uct="\$upstream_connect_time" uht="\$upstream_header_time" urt="\$upstream_response_time" body="\$request_body"';

access_log ${VAR_LOG_NGINX_PATH}/access.log custom_http;
error_log ${VAR_LOG_NGINX_PATH}/error.log info;
error_log stderr;
TEMPLATING
    _nginx="$(command -v nginx-debug)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check nginx availability
  ${_nginx} -v
}

main
TEMPLATING
    nginx_entrypoint="${ENTRYPOINTD_PATH}/99nginx.sh"
    cat << TEMPLATING > "${nginx_entrypoint}"
#! /bin/sh

main ()
{
  set -eux

  cat << __TEMPLATING > /run/default.conf
include ${ETC_NGINX_HTTPD_PATH}/*.conf;
__TEMPLATING

  exec ${_nginx}
}

main
TEMPLATING
    chmod 0700 "${nginx_entrypoint}" "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
