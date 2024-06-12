ARG SSHD_LAYER_IMG
FROM ${SSHD_LAYER_IMG}

ARG CHECK_ENTRYPOINT_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    pkg='pass git gpg-agent git-bash-completion pass-bash-completion'
    apk add --no-cache ${pkg}
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
  for _pkg in ${pkg}
  do
    ${_apk} info --installed "\${_pkg}"
  done
}

main
TEMPLATING
    chmod 0700 "${CHECK_ENTRYPOINT_PATH}"
    unset http_proxy https_proxy
END_OF_RUN
