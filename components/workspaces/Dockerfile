ARG SSHD_COMPONENT_IMG
FROM ${SSHD_COMPONENT_IMG}

ARG OPT_SCRIPTS_PATH
ARG OWNER_URL
ARG SPACEPORN_ID
ARG WORKSPACES_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    spaceporn_scripts="${OPT_SCRIPTS_PATH}/${SPACEPORN_ID}"
    mkdir -p "${WORKSPACES_PATH}" "${spaceporn_scripts}"
    cat << TEMPLATING >> /etc/profile.d/99default_dir.sh
main ()
{
  set -eu

  cd '${WORKSPACES_PATH}'
}

main
TEMPLATING
    cat << TEMPLATING >> "${spaceporn_scripts}/init.sh"
#! /usr/bin/env bash

main ()
{
  set -eux

  local repo spaceporn_workspace bindings_dir actions_dir
  spaceporn_workspace='${WORKSPACES_PATH}/${SPACEPORN_ID}'
  bindings_dir="\${spaceporn_workspace}/bindings"
  actions_dir="\${spaceporn_workspace}/actions"
  readonly spaceporn_workspace bindings_dir actions_dir

  mkdir -p "\${bindings_dir}" "\${actions_dir}"

  for repo in 'env' 'bot' 'ci' 'cd-ping' 'cd-pong'
  do
    git clone "${OWNER_URL}/${SPACEPORN_ID}-action-\${repo}.git" "\${actions_dir}/"
  done

  for repo in 'vulkan' 'wayland' 'X11' 'glfw' 'cimgui' 'spirv' 'glslang' 'shaderc'
  do
    git clone "${OWNER_URL}/\${repo}.zig.git" "\${bindings_dir}/"
  done

  git clone '${OWNER_URL}/${SPACEPORN_ID}.git' "\${spaceporn_workspace}"
}

main \${@}
TEMPLATING
    for script in "${spaceporn_scripts}"/*.sh
    do
      chmod 0700 "${script}"
    done
    unset http_proxy https_proxy
END_OF_RUN

WORKDIR ${WORKSPACES_PATH}
