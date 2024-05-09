ARG OS_IMG
ARG DOCKER_IMG
ARG LINUXSERVER_PROXY_IMG

FROM ${LINUXSERVER_PROXY_IMG} as linuxserver_img
FROM ${DOCKER_IMG} as docker_img
FROM ${OS_IMG} as default_conf

ARG DOCKER_PATH
COPY --from=docker_img ${DOCKER_PATH}/docker ${DOCKER_PATH}/

ARG API_URL
ARG ETC_NGX_PATH
ARG PROXY_PORT
ARG SOCKET_PATH
ARG TMP_NGX_PATH
ARG TMP_WARNING_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

ARG API_SFX
ARG ${API_SFX}NETWORKS
ARG ${API_SFX}VERSION

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache yq
    mkdir -p "${TMP_NGX_PATH}" "$(dirname "${TMP_WARNING_PATH}")"
    api_version="$(docker version --format '{{ .Client.APIVersion }}' 2> /dev/null || :)"
    gh_url="${API_URL}/v${api_version}.yaml"
    endpoints="$(wget -q -O- "${gh_url}" | yq '.paths | keys | .[]')"
    cat << TEMPLATING > "${TMP_WARNING_PATH}"
-------------------------------------------------------------------------------
API version: ${api_version}$(
  for arg in $(env | grep "^${API_SFX}")
  do
    if [ "${arg#"${arg%??}"}" != '=0' ]
    then
      arg="$(printf '%s\n' "${arg}" | cut -d'=' -f1)"
      flag=0
      for endpoint in ${endpoints}
      do
        if [ "${endpoint#"${endpoint%?}"}" != '}' ]
        then
          nginx_var="$(printf '%s\n' "${endpoint}" | sed 's@^/@@;s@/{\|}/\|/@_@g')"
          docker_varname="${API_SFX}$(printf '%s\n' "${nginx_var}" | tr 'a-z' 'A-Z')"
          if [ "${docker_varname}" == "${arg}" ]
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
    cat << TEMPLATING > "${TMP_NGX_PATH}/default.conf"
server {
    server_name _;
    listen ${PROXY_PORT} default_server;
    default_type text/plain;
    include ${ETC_NGX_PATH}/proxy.conf;
    set \$dockersocket ${SOCKET_PATH};
$(for endpoint in ${endpoints}
  do
    if [ "${endpoint#"${endpoint%?}"}" != '}' ]
    then
      nginx_var="$(printf '%s\n' "${endpoint}" | sed 's@^/@@;s@/{\|}/\|/@_@g')"
      regex="$(printf '%s\n' "${endpoint}" | sed 's@/{id}$\|/{name}$@@;s@/{id}/\|/{name}/@/[a-zA-Z0-9_.-]+/@')"
      docker_varname="${API_SFX}$(printf '%s\n' "${nginx_var}" | tr 'a-z' 'A-Z')"
      resolve_ref="$(eval "printf '%s' \"\${${docker_varname}:-0}\"")"
      printf '\n    set $%s %d;\n' "${nginx_var}" "${resolve_ref}"
      printf '    location ~* ^(/v[\d\.]+)?%s {if ($%s = 0){return 403 "[403] Forbidden API endpoint: %s (%s is 0)";}proxy_pass http://unix:$dockersocket;}\n' "${regex}" "${nginx_var}" "'${endpoint}'" "'${docker_varname}'"
    fi
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
  done)
}
TEMPLATING
END_OF_RUN

FROM ${OS_IMG}

ARG APK_PATHS
ARG ENTRYPOINT_PATH
ARG ETC_NGX_PATH
ARG NET
ARG OPT_SCRIPTS_PATH
ARG TMP_NGX_PATH
ARG TMP_WARNING_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache nginx
    rm -rf ${APK_PATHS}
    mkdir -p "$(dirname "${TMP_WARNING_PATH}")" "${OPT_SCRIPTS_PATH}"
    _nginx="$(command -v nginx)"
    cat << TEMPLATING > "${ENTRYPOINT_PATH}"
#!/bin/sh
cat << __TEMPLATING > /run/default.conf
include ${ETC_NGX_PATH}/http.d/*.conf;
__TEMPLATING
cat ${TMP_WARNING_PATH}
exec ${_nginx} -e stderr
wait
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

COPY --from=linuxserver_img ${ETC_NGX_PATH}/nginx.conf ${ETC_NGX_PATH}/
COPY --from=linuxserver_img ${ETC_NGX_PATH}/proxy.conf ${ETC_NGX_PATH}/
COPY --from=default_conf ${TMP_NGX_PATH}/default.conf ${ETC_NGX_PATH}/http.d/
COPY --from=default_conf ${TMP_WARNING_PATH} ${TMP_WARNING_PATH}

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}
