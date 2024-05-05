ARG BASH_IMG
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${BASH_IMG}
COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

ARG DOCKER_HOST

RUN set -eux; \
    apk --no-cache add openssh-server; \
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd; \
    printf 'export DOCKER_HOST=%s\n' "${DOCKER_HOST}" >> /etc/profile.d/env.sh; \
    printf 'PasswordAuthentication no\n' >> /etc/ssh/sshd_config; \
    ENTRYPOINT='/docker_entrypoint.sh'; \
    printf '#!/bin/sh\nexec /usr/sbin/sshd -D -e\n' > "${ENTRYPOINT}"; \
    chmod 0700 "${ENTRYPOINT}"; \
    ssh-keygen -A

ENTRYPOINT ["/docker_entrypoint.sh"]

EXPOSE 22
