ARG BASH_IMG

FROM ${BASH_IMG}

ARG SSH_ROOT

RUN set -eux; \
    apk --no-cache add openssh-client; \
    mkdir -p "${SSH_ROOT}"; \
    KEY="${SSH_ROOT}/id_rsa"; \
    ssh-keygen -q -t rsa -N '' -f "${KEY}"; \
    cp "${KEY}.pub" ${SSH_ROOT}/authorized_keys

ENTRYPOINT ["bash"]
