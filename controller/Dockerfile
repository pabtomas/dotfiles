ARG SSHD_COMPONENT_IMG
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${SSHD_COMPONENT_IMG}

ARG DOCKER_PATH
COPY --from=docker_img ${DOCKER_PATH}/docker ${DOCKER_PATH}/

ARG NET
ARG TCP_DOCKER_HOST
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    cat << TEMPLATING > /etc/profile.d/env.sh
export DOCKER_HOST=${TCP_DOCKER_HOST}
TEMPLATING
    cat << TEMPLATING >> "/etc/ssh/sshd_config.d/${NET}.conf"
PermitUserEnvironment yes
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN
