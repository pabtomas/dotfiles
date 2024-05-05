ARG OS
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${OS} as nginx_conf

COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

ARG SOCKET_PATH
ARG PROXY_PORT
ARG TMP_NGX

ARG VERSION

RUN set -eux; \
    apk --no-cache add curl yq; \
    mkdir -p "${TMP_NGX}"; \
    GH_RAW='https://raw.githubusercontent.com'; \
    LINUXSRV_ETC_NGX="${GH_RAW}/linuxserver/docker-socket-proxy/main/root/etc/nginx"; \
    curl "${LINUXSRV_ETC_NGX}/nginx.conf" > "${TMP_NGX}/nginx.conf"; \
    curl "${LINUXSRV_ETC_NGX}/proxy.conf" > "${TMP_NGX}/proxy.conf"; \
    ENDPOINTS="$(curl -s "${GH_RAW}/moby/moby/master/docs/api/v$(docker version --format '{{ .Client.APIVersion }}').yaml" | yq '.paths | keys | .[]')"; \
    LOCATIONS="$( \
      for endpoint in ${ENDPOINTS}; \
      do \
        if [ "${endpoint#"${endpoint%?}"}" != '}' ]; \
        then \
          nginx_var="$(printf '%s\n' "${endpoint}" | sed 's@^/@@;s@/{\|}/\|/@_@g')"; \
          regex="$(printf '%s\n' "${endpoint}" | sed 's@/{id}$\|/{name}$@@;s@/{id}/\|/{name}/@/[a-zA-Z0-9_.-]+/@')"; \
          docker_varname="$(printf '%s\n' "${nginx_var}" | tr 'a-z' 'A-Z')"; \
          resolve_ref="$(eval "printf '%s' \"\${${docker_varname}:-0}\"")"; \
          printf '    set $%s %d;\n' "${nginx_var}" "${resolve_ref}"; \
          printf '    location ~* ^(/v[\d\.]+)?%s {if ($%s = 0){return 403;}proxy_pass http://unix:$dockersocket;}\n\n' "${regex}" "${nginx_var}"; \
        fi; \
      done \
    )"; \
    LISTEN="    listen ${PROXY_PORT} default_server;"; \
    E403='    error_page 403 /403.html;\n    location = /403.html {root /var/www/html/;allow all;}'; \
    PROXY_CONF='    include /etc/nginx/proxy.conf;'; \
    SOCKET="    set \$dockersocket ${SOCKET_PATH};"; \
    printf 'server {\n    server_name _;\n%s\n\n%b\n\n%s\n\n%s\n\n%s\n}\n' \
      "${LISTEN}" "${E403}" "${PROXY_CONF}" "${SOCKET}" "${LOCATIONS}" > "${TMP_NGX}/default.conf"

FROM ${OS}

ARG TMP_NGX
COPY --from=nginx_conf ${TMP_NGX}/* /etc/nginx/

RUN set -eux; \
    apk add --no-cache nginx; \
    HTML='/var/www/html'; \
    mkdir -p "${HTML}"; \
    printf '[403 Forbidden]\n' > "${HTML}/403.html"; \
    rm -f /etc/nginx/http.d/default.conf

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}

ENTRYPOINT ["sh", "-c", "mv /etc/nginx/default.conf /run/; /usr/sbin/nginx -e stderr"]
