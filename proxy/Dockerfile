ARG ENTRYPOINT_COMPONENT_IMG
ARG LINUXSERVER_PROXY_IMG

FROM ${LINUXSERVER_PROXY_IMG} as linuxserver_img
FROM ${ENTRYPOINT_COMPONENT_IMG}

ARG APK_PATHS
ARG API_TAG
ARG API_URL
ARG COLLECTOR_IP
ARG CONTROLLER_IP
ARG ENTRYPOINTD_PATH
ARG ETC_NGX_PATH
ARG OPT_SCRIPTS_PATH
ARG PROXY_PORT
ARG SOCKET_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

ARG API_PFX
ARG ${API_PFX}IMAGES_JSON
ARG ${API_PFX}NETWORKS
ARG ${API_PFX}_PING
ARG ${API_PFX}VERSION

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    mkdir -p "${OPT_SCRIPTS_PATH}"
    apk add --no-cache --virtual __install_spec_parser yq
    endpoints="$(wget -q -O- "${API_URL}" | yq '.paths | keys | .[]')"
    nginx_varname () { printf '%s\n' "${1}" | sed 's@^/@@;s@/{\|}/\|/@_@g'; }
    docker_varname () { printf '%s%s\n' "${API_PFX}" "${1}" | tr 'a-z' 'A-Z'; }
cat << TEMPLATING
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
        if [ "${endpoint#"${endpoint%?}"}" != '}' ]
        then
          if [ "$(docker_varname "$(nginx_varname "${endpoint}")")" == "${arg}" ]
          then
            flag=1
            break
          fi
        fi
      done
      if [ "${flag}" == '0' ]
      then
        printf '\n[warning] %s does not match any API endpoint' "'${arg}'"
      fi
    fi
  done)
-------------------------------------------------------------------------------
TEMPLATING
    apk del __install_spec_parser
    apk add --no-cache nginx
    rm -rf ${APK_PATHS}
cat << TEMPLATING > "${ETC_NGX_PATH}/http.d/default.conf"
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

    default_type text/plain;
    include ${ETC_NGX_PATH}/proxy.conf;
    set \$dockersocket ${SOCKET_PATH};
$(for endpoint in ${endpoints}
  do
    if [ "${endpoint#"${endpoint%?}"}" != '}' ]
    then
      nginx_var="$(nginx_varname "${endpoint}")"
      regex="$(printf '%s\n' "${endpoint}" | sed 's@/{id}$\|/{name}$@@;s@/{id}/\|/{name}/@/[a-zA-Z0-9_.-]+/@')"
      docker_var="$(docker_varname "${nginx_var}")"
      resolve_ref="$(eval "printf '%s' \"\${${docker_var}:-0}\"")"
      printf '\n    set $%s %d;\n' "${nginx_var}" "${resolve_ref}"
      printf '    location ~* ^(/v[\d\.]+)?%s {set $e403 "[403] Forbidden API endpoint: %s (%s is 0)";if ($return_403 = 1){return 403 $e403;}if ($%s = 0){return 403 $e403;}proxy_pass http://unix:$dockersocket;}\n' "${regex}" "'${endpoint}'" "'${docker_var}'" "${nginx_var}"
    fi
  done)
}
TEMPLATING
    _nginx="$(command -v nginx)"
    nginx_entrypoint="${ENTRYPOINTD_PATH}/99nginx.sh"
    cat << TEMPLATING > "${nginx_entrypoint}"
#! /bin/sh -eux

cat << __TEMPLATING > /run/default.conf
include ${ETC_NGX_PATH}/http.d/default.conf;
__TEMPLATING

exec ${_nginx} -e stderr
TEMPLATING
    chmod 0700 "${nginx_entrypoint}"
    unset http_proxy https_proxy
END_OF_RUN

COPY --from=linuxserver_img ${ETC_NGX_PATH}/nginx.conf ${ETC_NGX_PATH}/
COPY --from=linuxserver_img ${ETC_NGX_PATH}/proxy.conf ${ETC_NGX_PATH}/

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}
