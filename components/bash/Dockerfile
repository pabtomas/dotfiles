ARG BASH_LOCAL_IMG
ARG ENTRYPOINT_COMPONENT_IMG
FROM ${ENTRYPOINT_COMPONENT_IMG} as entrypoint_image
FROM ${BASH_LOCAL_IMG}

COPY etc/ /etc/

ARG BASH_ALIASES_PATH
ARG BASH_COMPLETION_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk update
    apk add --no-cache coreutils bash-completion tree
    mkdir -p "${BASH_ALIASES_PATH}" "${BASH_COMPLETION_PATH}"
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd
    cat << TEMPLATING >> "$(dirname "${BASH_ALIASES_PATH}")/$(basename -s '.d' "${BASH_ALIASES_PATH}").sh"
main ()
{
  unalias -a

  if [ -d ${BASH_ALIASES_PATH} ]
  then
    for file in ${BASH_ALIASES_PATH}/*.sh
    do
      if [ -r "\${file}" ]
      then
        . "\${file}"
      fi
    done
    unset file
  fi
}

main
TEMPLATING
    cat << TEMPLATING >> "$(dirname "${BASH_COMPLETION_PATH}")/$(basename -s '.d' "${BASH_COMPLETION_PATH}").sh"
main ()
{
  unalias -a

  if [ -d ${BASH_COMPLETION_PATH} ]
  then
    for file in ${BASH_COMPLETION_PATH}/*.sh
    do
      if [ -r "\${file}" ]
      then
        . "\${file}"
      fi
    done
    unset file
  fi
}

main
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

ARG OPT_SCRIPTS_PATH
COPY --from=entrypoint_image ${OPT_SCRIPTS_PATH}/ ${OPT_SCRIPTS_PATH}/

ARG ENTRYPOINT_PATH
ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
