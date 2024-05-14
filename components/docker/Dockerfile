ARG SSHD_COMPONENT_IMG
ARG DOCKER_IMG

FROM ${DOCKER_IMG} as docker_img
FROM ${SSHD_COMPONENT_IMG}

ARG DOCKER_PATH
COPY --from=docker_img ${DOCKER_PATH}/docker ${DOCKER_PATH}/

ARG NET
ARG TCP_DOCKER_HOST
ARG TRASH_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache docker-bash-completion
    cat << TEMPLATING > /etc/profile.d/99env.sh
main ()
{
  DOCKER_HOST='${TCP_DOCKER_HOST}'
  TRASH_PATH='${TRASH_PATH}'

  export DOCKER_HOST TRASH_PATH
}

main
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
