ARG BASH_LAYER_IMG
FROM ${BASH_LAYER_IMG}

ARG BASH_COMPLETION_PATH
ARG CHECK_ENTRYPOINT_PATH
ARG TMUX_COMPLETION_URL
ARG TPM_PATH
ARG TPM_URL
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY:-}"
    export https_proxy="${HTTPS_PROXY:-}"
    apk add --no-cache --virtual __install_plugins git
    git clone --depth 1 "${TPM_URL}" "${TPM_PATH}"
    apk del __install_plugins
    pkg='tmux tmuxinator tmuxinator-bash-completion'
    apk add --no-cache ${pkg}
    wget -O "${BASH_COMPLETION_PATH}/99tmux.sh" "${TMUX_COMPLETION_URL}"
    _apk="$(command -v apk)"
    _tmux="$(command -v tmux)"
    _tmuxinator="$(command -v tmuxinator)"
    cat << TEMPLATING >> "${CHECK_ENTRYPOINT_PATH}"
#! /bin/sh

main ()
{
  set -eux

  # check tmux availability
  ${_tmux} -V
  ${_tmuxinator} version

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

COPY .tmux.conf /root/
COPY etc/ /etc/
