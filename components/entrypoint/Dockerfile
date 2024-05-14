ARG BASH_IMG
FROM ${BASH_IMG}

ARG ENTRYPOINT_PATH
ARG ENTRYPOINTD_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    mkdir -p "${ENTRYPOINTD_PATH}"
    cat << TEMPLATING > "${ENTRYPOINT_PATH}"
#! /usr/bin/env bash
set -eux
if [[ -d ${ENTRYPOINTD_PATH} ]]
then
  for file in ${ENTRYPOINTD_PATH}/*.sh
  do
    if [[ -r "\${file}" ]]
    then
      source "\${file}"
    fi
  done
  unset file
fi
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
