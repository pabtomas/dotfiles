ARG SSHD_COMPONENT_IMG
ARG _DOCKER_LOCAL_IMG

FROM ${_DOCKER_LOCAL_IMG} as docker_img
FROM ${SSHD_COMPONENT_IMG}

ARG _DOCKER_PATH
COPY --from=docker_img ${_DOCKER_PATH}/docker ${_DOCKER_PATH}/

ARG NET
ARG TCP_DOCKER_HOST
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/community docker-cli-compose docker-bash-completion
    cat << TEMPLATING > /etc/profile.d/99env.sh
main ()
{
  DOCKER_HOST='${TCP_DOCKER_HOST}'

  export DOCKER_HOST
}

main
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
