ARG WORKSPACES_LAYER_IMG
FROM ${WORKSPACES_LAYER_IMG}

ARG BASH_COMPLETION_PATH
ARG CHECK_ENTRYPOINT_PATH
ARG TIG_COMPLETION_URL
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache git tig ripgrep git-bash-completion ripgrep-bash-completion
    wget -q -O "${BASH_COMPLETION_PATH}/99tig.sh" "${TIG_COMPLETION_URL}"
    _apk="$(command -v apk)"
    _git="$(command -v git)"
    _tig="$(command -v tig)"
    _ripgrep="$(command -v rg)"
    cat << TEMPLATING > "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check git tig & ripgrep are available
  ${_git} --version
  ${_tig} --version
  ${_ripgrep} --version

  # check packages are available
  [ -n "\$(${_apk} info -q -L git-bash-completion)" ]
  [ -n "\$(${_apk} info -q -L ripgrep-bash-completion)" ]
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
