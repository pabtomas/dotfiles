ARG PROXY_COMPONENT_IMG
FROM ${PROXY_COMPONENT_IMG}

ARG API_TAG
ARG API_URL
ARG APK_PATHS
ARG COLLECTOR_IP
ARG CONTROLLER_IP
ARG _DOCKER_SOCKET_PATH
ARG ENTRYPOINTD_PATH
ARG ETC_NGINX_HTTPD_PATH
ARG OPT_SCRIPTS_PATH
ARG PROXY_PORT
ARG HTTP_PROXY
ARG HTTPS_PROXY

ARG API_PFX
ARG ${API_PFX}_PING
ARG ${API_PFX}BUILD
ARG ${API_PFX}CONTAINERS_CREATE
ARG ${API_PFX}CONTAINERS_ID
ARG ${API_PFX}CONTAINERS_ID_ARCHIVE
ARG ${API_PFX}CONTAINERS_ID_ATTACH
ARG ${API_PFX}CONTAINERS_ID_EXEC
ARG ${API_PFX}CONTAINERS_ID_JSON
ARG ${API_PFX}CONTAINERS_ID_KILL
ARG ${API_PFX}CONTAINERS_ID_LOGS
ARG ${API_PFX}CONTAINERS_ID_START
ARG ${API_PFX}CONTAINERS_ID_STOP
ARG ${API_PFX}CONTAINERS_ID_WAIT
ARG ${API_PFX}CONTAINERS_JSON
ARG ${API_PFX}IMAGES_CREATE
ARG ${API_PFX}IMAGES_JSON
ARG ${API_PFX}IMAGES_NAME
ARG ${API_PFX}NETWORKS
ARG ${API_PFX}VERSION
ARG ${API_PFX}VOLUMES

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    mkdir -p "${OPT_SCRIPTS_PATH}"
    apk add --no-cache --virtual __install_spec_parser yq
    endpoints="$(wget -q -O- "${API_URL}" | yq '.paths | keys | .[]')"
    nginx_varname () { printf '%s\n' "${1}" | sed 's@^/@@;s@/{\|}/\|/@_@g;s@}$@@'; }
    docker_varname () { printf '%s%s\n' "${API_PFX}" "${1}" | tr 'a-z' 'A-Z'; }
    apk del __install_spec_parser
    rm -rf ${APK_PATHS}
    cat << TEMPLATING > "${ETC_NGINX_HTTPD_PATH}/default.conf"
geo \$privileged {
    default          0;
    ${CONTROLLER_IP} 1;
}

map \$request_method \$readonly {
    default  0;
    GET      1;
    HEAD     1;
}

map \$privileged:\$readonly \$return_403 {
    default  0;
    "0:0"    1;
}

server {
    server_name _;
    listen ${PROXY_PORT} default_server;
    allow ${CONTROLLER_IP};
    allow ${COLLECTOR_IP};
    deny all;
    dav_methods PUT DELETE;

    default_type text/plain;
    set \$dockersocket ${_DOCKER_SOCKET_PATH};
$(for endpoint in ${endpoints}
  do
    nginx_var="$(nginx_varname "${endpoint}")"
    regex="$(printf '%s\n' "${endpoint}" | sed 's@/{id}$\|/{name}$@@;s@/{id}/\|/{name}/@/[a-zA-Z0-9_.-]+/@')"
    docker_var="$(docker_varname "${nginx_var}")"
    resolve_ref="$(eval "printf '%s' \"\${${docker_var}:-0}\"")"
    printf '\n    set $%s %d;\n' "${nginx_var}" "${resolve_ref}"
    printf '    location ~* ^(/v[\d\.]+)?%s {set $e403 "[403] Forbidden API endpoint: %s (%s is 0)";if ($return_403 = 1){return 403 $e403;}if ($%s = 0){return 403 $e403;}proxy_pass http://unix:$dockersocket;}\n' "${regex}" "'${endpoint}'" "'${docker_var}'" "${nginx_var}"
  done)
}
TEMPLATING
    warning_entrypoint="${ENTRYPOINTD_PATH}/98warning.sh"
    cat << TEMPLATING >> "${warning_entrypoint}"
#! /bin/sh

main ()
{
  set -eux
  cat << EOF
-------------------------------------------------------------------------------
API version: ${API_TAG}$(
  for arg in $(set | grep "^${API_PFX}")
  do
    if [ "${arg#"${arg%????}"}" != "='0'" ]
    then
      arg="$(printf '%s\n' "${arg}" | cut -d'=' -f1)"
      flag=0
      for endpoint in ${endpoints}
      do
        if [ "$(docker_varname "$(nginx_varname "${endpoint}")")" == "${arg}" ]
        then
          flag=1
          break
        fi
      done
      if [ "${flag}" == '0' ]
      then
        printf '\n[warning] %s does not match any API endpoint' "'${arg}'"
      fi
    fi
  done)
-------------------------------------------------------------------------------
EOF
}

main
TEMPLATING
    chmod 0700 "${warning_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}
