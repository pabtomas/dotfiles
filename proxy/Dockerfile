ARG OS_IMG
ARG LINUXSERVER_PROXY_IMG

FROM ${LINUXSERVER_PROXY_IMG} as linuxserver_img
FROM ${OS_IMG}

ARG APK_PATHS
ARG API_URL
ARG COLLECTOR_IP
ARG CONTROLLER_IP
ARG ENTRYPOINT_PATH
ARG ETC_NGX_PATH
ARG OPT_SCRIPTS_PATH
ARG PROXY_PORT
ARG RUN_HTTPD_PATH
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
    apk add --no-cache nginx yq curl jq
    rm -rf ${APK_PATHS}
    _nginx="$(command -v nginx)"
    cat << TEMPLATING > "${ENTRYPOINT_PATH}"
#!/bin/sh
api_version="\$(curl -s --unix-socket "${SOCKET_PATH}" http://localhost/version | jq -r '.ApiVersion')"
gh_url="${API_URL}/v\${api_version}.yaml"
endpoints="\$(wget -q -O- "\${gh_url}" | yq '.paths | keys | .[]')"
nginx_varname () { printf '%s\n' "\${1}" | sed 's@^/@@;s@/{\|}/\|/@_@g'; }
docker_varname () { printf '${API_PFX}%s\n' "\${1}" | tr 'a-z' 'A-Z'; }
cat << __TEMPLATING
-------------------------------------------------------------------------------
API version: \${api_version}\$(
  for arg in \$(set | grep '^${API_PFX}')
  do
    if [ "\${arg#"\${arg%????}"}" != "='0'" ]
    then
      arg="\$(printf '%s\n' "\${arg}" | cut -d'=' -f1)"
      flag=0
      for endpoint in \${endpoints}
      do
        if [ "\${endpoint#"\${endpoint%?}"}" != '}' ]
        then
          if [ "\$(docker_varname "\$(nginx_varname "\${endpoint}")")" == "\${arg}" ]
          then
            flag=1
            break
          fi
        fi
      done
      if [ "\${flag}" == '0' ]
      then
        printf '\n[warning] %s does not match any API endpoint' "'\${arg}'"
      fi
    fi
  done)
-------------------------------------------------------------------------------
__TEMPLATING
mkdir '${RUN_HTTPD_PATH}'
cat << __TEMPLATING > '${RUN_HTTPD_PATH}/default.conf'
geo \\\$privileged {
    default          0;
    ${CONTROLLER_IP} 1;
}
map \\\$request_method \\\$readonly {
    default  0;
    GET      1;
    HEAD     1;
}
map \\\$privileged:\\\$readonly \\\$return_403 {
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
    set \\\$dockersocket ${SOCKET_PATH};
\$(for endpoint in \${endpoints}
   do
     if [ "\${endpoint#"\${endpoint%?}"}" != '}' ]
     then
       nginx_var="\$(nginx_varname "\${endpoint}")"
       regex="\$(printf '%s\n' "\${endpoint}" | sed 's@/{id}\$\|/{name}\$@@;s@/{id}/\|/{name}/@/[a-zA-Z0-9_.-]+/@')"
       docker_var="\$(docker_varname "\${nginx_var}")"
       resolve_ref="\$(eval "printf '%s' \\"\\\${\${docker_var}:-0}\\"")"
       printf '\n    set \$%s %d;\n' "\${nginx_var}" "\${resolve_ref}"
       printf '    location ~* ^(/v[\d\.]+)?%s {set \$e403 "[403] Forbidden API endpoint: %s (%s is 0)";if (\$return_403 = 1){return 403 \$e403;}if (\$%s = 0){return 403 \$e403;}proxy_pass http://unix:\$dockersocket;}\n' "\${regex}" "'\${endpoint}'" "'\${docker_var}'" "\${nginx_var}"
     fi
   done)
}
__TEMPLATING
cat << __TEMPLATING > /run/default.conf
include ${RUN_HTTPD_PATH}/default.conf;
__TEMPLATING
exec ${_nginx} -e stderr
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY --from=linuxserver_img ${ETC_NGX_PATH}/nginx.conf ${ETC_NGX_PATH}/
COPY --from=linuxserver_img ${ETC_NGX_PATH}/proxy.conf ${ETC_NGX_PATH}/

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}
