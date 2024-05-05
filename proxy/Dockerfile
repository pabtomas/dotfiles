ARG OS
ARG DOCKER_IMG
ARG LINUXSERVER_PROXY_IMG

FROM ${LINUXSERVER_PROXY_IMG} as linuxserver_img
FROM ${DOCKER_IMG} as docker_img
FROM ${OS} as nginx_conf

COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

ARG SOCKET_PATH
ARG PROXY_PORT
ARG TMP_NGX
ARG ETC_NGX

ARG API_ENDPOINT_VERSION

RUN set -eux; \
    apk --no-cache add curl yq; \
    mkdir -p "${TMP_NGX}"; \
    GH_RAW='https://raw.githubusercontent.com'; \
    ENDPOINTS="$(curl -s "${GH_RAW}/moby/moby/master/docs/api/v$(docker version --format '{{ .Client.APIVersion }}').yaml" | yq '.paths | keys | .[]')"; \
    LOCATIONS="$( \
      for endpoint in ${ENDPOINTS}; \
      do \
        if [ "${endpoint#"${endpoint%?}"}" != '}' ]; \
        then \
          nginx_var="$(printf '%s\n' "${endpoint}" | sed 's@^/@@;s@/{\|}/\|/@_@g')"; \
          regex="$(printf '%s\n' "${endpoint}" | sed 's@/{id}$\|/{name}$@@;s@/{id}/\|/{name}/@/[a-zA-Z0-9_.-]+/@')"; \
          docker_varname="API_ENDPOINT_$(printf '%s\n' "${nginx_var}" | tr 'a-z' 'A-Z')"; \
          resolve_ref="$(eval "printf '%s' \"\${${docker_varname}:-0}\"")"; \
          printf '    set $%s %d;\n' "${nginx_var}" "${resolve_ref}"; \
          printf '    location ~* ^(/v[\d\.]+)?%s {if ($%s = 0){return 403 "[403] Forbidden API endpoint: %s";}proxy_pass http://unix:$dockersocket;}\n\n' "${regex}" "${nginx_var}" "'${endpoint}'"; \
        fi; \
      done \
    )"; \
    HEADER='    server_name _;'; \
    LISTEN="    listen ${PROXY_PORT} default_server;"; \
    TYPE='    default_type test/plain;'; \
    PROXY_CONF="    include ${ETC_NGX}/proxy.conf;"; \
    SOCKET="    set \$dockersocket ${SOCKET_PATH};"; \
    printf 'server {\n%s\n%s\n%s\n\n%b\n\n%s\n\n%s\n\n%s\n}\n' "${HEADER}" "${LISTEN}"\
      "${TYPE}" "${PROXY_CONF}" "${SOCKET}" "${LOCATIONS}" > "${TMP_NGX}/default.conf"

FROM ${OS}

ARG ETC_NGX
ARG TMP_NGX
COPY --from=linuxserver_img ${ETC_NGX}/nginx.conf ${ETC_NGX}/
COPY --from=linuxserver_img ${ETC_NGX}/proxy.conf ${ETC_NGX}/
COPY --from=nginx_conf ${TMP_NGX}/default.conf ${ETC_NGX}/

RUN set -eux; \
    apk add --no-cache nginx; \
    ENTRYPOINT='/docker_entrypoint.sh'; \
    printf '#!/bin/sh\nmv %s/default.conf /run/; exec /usr/sbin/nginx -e stderr\n' "${ETC_NGX}" > "${ENTRYPOINT}"; \
    chmod 0700 "${ENTRYPOINT}"; \
    rm -f "${ETC_NGX}/http.d/default.conf"

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}

ENTRYPOINT ["/docker_entrypoint.sh"]
