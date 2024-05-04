ARG OS
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${OS} as nginx_conf

COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

ARG SOCKET_PATH
ARG PROXY_PORT

ARG VERSION

RUN set -eux; \
    apk --no-cache add curl yq; \
    mkdir -p /tmp/nginx; \
    curl 'https://raw.githubusercontent.com/linuxserver/docker-socket-proxy/main/root/etc/nginx/nginx.conf' > /tmp/nginx/nginx.conf; \
    curl 'https://raw.githubusercontent.com/linuxserver/docker-socket-proxy/main/root/etc/nginx/proxy.conf' > /tmp/nginx/proxy.conf; \
    ENDPOINTS="$(curl -s "https://raw.githubusercontent.com/moby/moby/master/docs/api/v$(docker version --format '{{ .Client.APIVersion }}').yaml" | yq '.paths | keys | .[]')"; \
    LOCATIONS="$( \
      for endpoint in ${ENDPOINTS}; \
      do \
        if [ "${endpoint#"${endpoint%?}"}" != '}' ]; \
        then \
          nginx_var="$(printf '%s\n' "${endpoint}" | sed 's@^/@@;s@/{\|}/\|/@_@g')"; \
          regex="$(printf '%s\n' "${endpoint}" | sed 's@/{id}$\|/{name}$@@;s@/{id}/\|/{name}/@/[a-zA-Z0-9_.-]+/@')"; \
          docker_var="$(printf '%s\n' "${nginx_var}" | tr 'a-z' 'A-Z')"; \
          printf '    set $%s %d;\n' "${nginx_var}" "$(eval "printf '%s\\n' \"\${${docker_var}:-0}\"")"; \
          printf '    location ~* ^(/v[\d\.]+)?%s {if ($%s = 0){return 403;}proxy_pass http://unix:$dockersocket;}\n\n' "${regex}" "${nginx_var}"; \
        fi; \
      done \
    )"; \
    printf 'server {\n    listen %d default_server;\n\n    server_name _;\n\n    error_page 403 /403.html;\n    location = /403.html {root /var/www/html/;allow all;}\n\n    include /etc/nginx/proxy.conf;\n\n    set $dockersocket %s;\n\n%s\n}\n' "${PROXY_PORT}" "${SOCKET_PATH}" "${LOCATIONS}" > /tmp/nginx/default.conf

FROM ${OS}

COPY --from=nginx_conf /tmp/nginx/* /etc/nginx/

RUN set -eux; \
    apk add --no-cache nginx; \
    mkdir -p /var/www/html; \
    printf '[403 Forbidden]\n' > /var/www/html/403.html; \
    rm -f /etc/nginx/http.d/default.conf

ARG PROXY_PORT
EXPOSE ${PROXY_PORT}

ENTRYPOINT ["sh", "-c", "mv /etc/nginx/default.conf /run/; /usr/sbin/nginx -e stderr"]
