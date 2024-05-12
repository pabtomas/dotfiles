ARG WORKSPACES_COMPONENT_IMG
FROM ${WORKSPACES_COMPONENT_IMG}

ARG BASH_COMPLETION_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache git tig ripgrep git-bash-completion ripgrep-bash-completion
    wget -q -O "${BASH_COMPLETION_PATH}/99tig.sh" https://raw.githubusercontent.com/jonas/tig/master/contrib/tig-completion.bash
    unset http_proxy https_proxy
END_OF_RUN

COPY etc/ /etc/
