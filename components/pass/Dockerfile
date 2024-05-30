ARG SSHD_COMPONENT_IMG
FROM ${SSHD_COMPONENT_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache pass git gpg-agent git-bash-completion pass-bash-completion
    _apk="$(command -v apk)"
    _gpg="$(command -v gpg)"
    _git="$(command -v git)"
    _pass="$(command -v pass)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check pass availability
  ${_gpg} --version
  ${_git} --version
  ${_pass} --version

  # check packages are available
  [ -n "\$(${_apk} info -q -L git-bash-completion)" ]
  [ -n "\$(${_apk} info -q -L pass-bash-completion)" ]
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
