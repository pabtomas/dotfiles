ARG OS
ARG DOCKER_IMG
ARG LINUXSERVER_PROXY_IMG

FROM ${LINUXSERVER_PROXY_IMG} as linuxserver_img
FROM ${DOCKER_IMG} as docker_img
FROM ${OS} as default_conf

COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

ARG ETC_NGX
ARG PROXY_PORT
ARG SOCKET_PATH
ARG TMP_NGX
ARG TMP_WARNING
ARG HTTP_PROXY
ARG HTTPS_PROXY

ARG API_SFX
ARG ${API_SFX}NETWORKS
ARG ${API_SFX}VERSION

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache curl yq
    mkdir -p "${TMP_NGX}" "$(dirname "${TMP_WARNING}")"
    GH_RAW='https://raw.githubusercontent.com'
    ENDPOINTS="$(curl -s "${GH_RAW}/moby/moby/master/docs/api/v$(docker version --format '{{ .Client.APIVersion }}').yaml" | yq '.paths | keys | .[]')"
    cat << TEMPLATING > "${TMP_WARNING}"
-------------------------------------------------------------------------------
API version: $(docker version --format '{{ .Client.APIVersion }}')$(
  for arg in $(env | grep "^${API_SFX}")
  do
    if [ "${arg#"${arg%??}"}" != '=0' ]
    then
      arg="$(printf '%s\n' "${arg}" | cut -d'=' -f1)"
      flag=0
      for endpoint in ${ENDPOINTS}
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
    cat << TEMPLATING > "${TMP_NGX}/default.conf"
server {
    server_name _;
    listen ${PROXY_PORT} default_server;
    default_type text/plain;
    include ${ETC_NGX}/proxy.conf;
    set \$dockersocket ${SOCKET_PATH};
$(for endpoint in ${ENDPOINTS}
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

FROM ${OS}

ARG NET
ARG ETC_NGX
ARG TMP_NGX
ARG TMP_WARNING
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache nginx openssh-server
    ENTRYPOINT='/docker_entrypoint.sh'
    cat << TEMPLATING > "/etc/ssh/sshd_config.d/${NET}.conf"
PasswordAuthentication no
TEMPLATING
    ssh-keygen -A
    mkdir -p "$(dirname "${TMP_WARNING}")"
    cat << TEMPLATING > "${ENTRYPOINT}"
#!/bin/sh
printf 'include ${ETC_NGX}/http.d/*.conf;\n' > /run/default.conf
/usr/sbin/nginx -e stderr &
/usr/sbin/sshd -D -e &
cat ${TMP_WARNING}
wait
TEMPLATING
    chmod 0700 "${ENTRYPOINT}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

COPY --from=linuxserver_img ${ETC_NGX}/nginx.conf ${ETC_NGX}/
COPY --from=linuxserver_img ${ETC_NGX}/proxy.conf ${ETC_NGX}/
COPY --from=default_conf ${TMP_NGX}/default.conf ${ETC_NGX}/http.d/
COPY --from=default_conf ${TMP_WARNING} ${TMP_WARNING}

ENTRYPOINT ["/docker_entrypoint.sh"]

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}
EXPOSE 22
