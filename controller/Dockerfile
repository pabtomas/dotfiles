ARG BASH_IMG
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${BASH_IMG}
COPY --from=docker_img /usr/local/bin/docker /usr/local/bin/

RUN set -eux; \
    apk --no-cache add openssh-server; \
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd; \
    echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config; \
    ssh-keygen -A

ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]

EXPOSE 22
