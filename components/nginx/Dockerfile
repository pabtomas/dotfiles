ARG ENTRYPOINT_COMPONENT_IMG
FROM ${ENTRYPOINT_COMPONENT_IMG}

ARG APK_PATHS
ARG ENTRYPOINTD_PATH
ARG ETC_NGINX_PATH
ARG VAR_LOG_NGINX_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache nginx-debug
    httpd_path="${ETC_NGINX_PATH}/http.d"
    cat << TEMPLATING > "${httpd_path}/logging.conf"
log_format custom '\$remote_addr - \$remote_user [\$time_local] '
                  '"\$request" \$status \$body_bytes_sent '
                  '"\$http_referer" "\$http_user_agent"'
                  'rt=\$request_time uct="\$upstream_connect_time" uht="\$upstream_header_time" urt="\$upstream_response_time"';

access_log ${VAR_LOG_NGINX_PATH}/access.log custom;
error_log ${VAR_LOG_NGINX_PATH}/error.log info;
error_log stderr;
TEMPLATING
    _nginx="$(command -v nginx-debug)"
    nginx_entrypoint="${ENTRYPOINTD_PATH}/99nginx.sh"
    cat << TEMPLATING > "${nginx_entrypoint}"
#! /bin/sh

main ()
{
  set -eux

  cat << __TEMPLATING > /run/default.conf
include ${httpd_path}/*.conf;
__TEMPLATING

  rm -rf ${APK_PATHS}

  exec ${_nginx}
}

main
TEMPLATING
    chmod 0700 "${nginx_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN
