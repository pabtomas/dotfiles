ARG OS
ARG DOCKER_IMG
ARG LINUXSERVER_PROXY_IMG

FROM ${LINUXSERVER_PROXY_IMG} as linuxserver_img
FROM ${DOCKER_IMG} as docker_img
FROM ${OS} as default_conf

COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

ARG SOCKET_PATH
ARG PROXY_PORT
ARG TMP_NGX
ARG ETC_NGX

ARG API_ENDPOINT_NETWORKS
ARG API_ENDPOINT_VERSION

RUN <<END_OF_RUN
    set -eux
    apk --no-cache add curl yq
    mkdir -p "${TMP_NGX}"
    GH_RAW='https://raw.githubusercontent.com'
    ENDPOINTS="$(curl -s "${GH_RAW}/moby/moby/master/docs/api/v$(docker version --format '{{ .Client.APIVersion }}').yaml" | yq '.paths | keys | .[]')"
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
      docker_varname="API_ENDPOINT_$(printf '%s\n' "${nginx_var}" | tr 'a-z' 'A-Z')"
      resolve_ref="$(eval "printf '%s' \"\${${docker_varname}:-0}\"")"
      printf '\n    set $%s %d;\n' "${nginx_var}" "${resolve_ref}"
      printf '    location ~* ^(/v[\d\.]+)?%s {if ($%s = 0){return 403 "[403] Forbidden API endpoint: %s (%s is 0)";}proxy_pass http://unix:$dockersocket;}\n' "${regex}" "${nginx_var}" "'${endpoint}'" "'${docker_varname}'"
    fi
  done)
}
TEMPLATING
END_OF_RUN

FROM ${OS}

ARG ETC_NGX
ARG TMP_NGX
COPY --from=linuxserver_img ${ETC_NGX}/nginx.conf ${ETC_NGX}/
COPY --from=linuxserver_img ${ETC_NGX}/proxy.conf ${ETC_NGX}/
COPY --from=default_conf ${TMP_NGX}/default.conf ${ETC_NGX}/

RUN <<END_OF_RUN
    set -eux
    apk add --no-cache nginx
    rm -f "${ETC_NGX}/http.d/default.conf"
    ENTRYPOINT='/docker_entrypoint.sh'
    printf '#!/bin/sh\nmv %s/default.conf /run/; exec /usr/sbin/nginx -e stderr\n' "${ETC_NGX}" > "${ENTRYPOINT}"
    chmod 0700 "${ENTRYPOINT}"
END_OF_RUN

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}

ENTRYPOINT ["/docker_entrypoint.sh"]
