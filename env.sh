#!/bin/sh

FALSE='0'
TRUE='1'
APK_PATHS='/sbin/apk /etc/apk /lib/apk /usr/share/apk /var/lib/apk'
API_PFX='API_ENDPOINT_'

### Ids ######################################################################
COLLECTOR_ID='collector'
CONTROLLER_ID='controller'
EDITOR_ID='editor'
JUMPER_ID='jumper'
OWNER_ID='tiawl'
PROXY_ID='proxy'
COMPONENT_ID='component'
EXPLORER_ID='explorer'
RUNNER_ID='runner'
SHELL_ID='shell'
SPACEPORN_ID='spaceporn'
BASH_ID='bash'
GIT_ID='git'
SSHD_ID='sshd'
TMUX_ID='tmux'
ZIG_ID='zig'
SPACEPORN_RUNNER_ID="${RUNNER_ID}/${SPACEPORN_ID}"
BASH_COMPONENT_ID="${COMPONENT_ID}/${BASH_ID}"
GIT_COMPONENT_ID="${COMPONENT_ID}/${GIT_ID}"
SSHD_COMPONENT_ID="${COMPONENT_ID}/${SSHD_ID}"
TMUX_COMPONENT_ID="${COMPONENT_ID}/${TMUX_ID}"
ZIG_COMPONENT_ID="${COMPONENT_ID}/${ZIG_ID}"
SHELL_EXPLORER_ID="${EXPLORER_ID}/${SHELL_ID}"
ZIG_EXPLORER_ID="${EXPLORER_ID}/${ZIG_ID}"

### Services #################################################################
COLLECTOR_SERVICE="${COLLECTOR_ID}"
CONTROLLER_SERVICE="${CONTROLLER_ID}"
EDITOR_SERVICE="${EDITOR_ID}"
JUMPER_SERVICE="${JUMPER_ID}"
PROXY_SERVICE="${PROXY_ID}"
BASH_SERVICE="${BASH_ID}"
GIT_SERVICE="${GIT_ID}"
SSHD_SERVICE="${SSHD_ID}"
TMUX_SERVICE="${TMUX_ID}"
ZIG_SERVICE="${ZIG_ID}"
RUNNER_SERVICE="${RUNNER_ID}"
SHELL_EXPLORER_SERVICE="$(printf '%s\n' "${SHELL_EXPLORER_ID}" | sed 's@/@.@')"

### Hostnames ################################################################
COLLECTOR_HOST="${COLLECTOR_ID}"
CONTROLLER_HOST="${CONTROLLER_ID}"
EDITOR_HOST="${EDITOR_ID}"
JUMPER_HOST="${JUMPER_ID}"
PROXY_HOST="${PROXY_ID}"
SHELL_EXPLORER_HOST="${SHELL_EXPLORER_SERVICE}"

### Tags #####################################################################
ALPINE_TAG='3.19'
BASH_TAG='5.2'
COLLECTOR_TAG='latest'
CONTROLLER_TAG='latest'
DOCKER_TAG='dind'
EDITOR_TAG='latest'
JUMPER_TAG='latest'
LINUXSERVER_PROXY_TAG='latest'
PROXY_TAG='latest'
SPACEPORN_RUNNER_TAG='latest'
BASH_COMPONENT_TAG='latest'
GIT_COMPONENT_TAG='latest'
SSHD_COMPONENT_TAG='latest'
SHELL_EXPLORER_TAG='latest'
TMUX_COMPONENT_TAG='latest'
ZIG_TAG='0.12.0'

### Extern Images ############################################################
# into the shell: export http_proxy='https://you.custom.proxy:<port>'
#ALPINE_IMG='local_alpine'
#BASH_IMG='local_bash'
#DOCKER_IMG='local_docker'
#LINUXSERVER_PROXY_IMG='local_proxy'
ALPINE_IMG="docker.io/alpine:${ALPINE_TAG}"
BASH_IMG="docker.io/bash:${BASH_TAG}"
DOCKER_IMG="docker.io/docker:${DOCKER_TAG}"
LINUXSERVER_PROXY_IMG="lscr.io/linuxserver/socket-proxy:${LINUXSERVER_PROXY_TAG}"
OS_IMG="${ALPINE_IMG}"

### Intern Images ############################################################

### Final Images #############################################################
COLLECTOR_IMG="${OWNER_ID}/${COLLECTOR_ID}:${COLLECTOR_TAG}"
CONTROLLER_IMG="${OWNER_ID}/${CONTROLLER_ID}:${CONTROLLER_TAG}"
EDITOR_IMG="${OWNER_ID}/${EDITOR_ID}:${EDITOR_TAG}"
JUMPER_IMG="${OWNER_ID}/${JUMPER_ID}:${JUMPER_TAG}"
PROXY_IMG="${OWNER_ID}/${PROXY_ID}:${PROXY_TAG}"

### Runners Images ###########################################################
SPACEPORN_RUNNER_IMG="${OWNER_ID}/${SPACEPORN_RUNNER_ID}:${SPACEPORN_RUNNER_TAG}"

### Explorers Images #########################################################
SHELL_EXPLORER_IMG="${OWNER_ID}/${SHELL_EXPLORER_ID}:${SHELL_EXPLORER_TAG}"
ZIG_EXPLORER_IMG="${OWNER_ID}/${ZIG_EXPLORER_ID}:${ZIG_TAG}"

### Components Images ########################################################
BASH_COMPONENT_IMG="${OWNER_ID}/${BASH_COMPONENT_ID}:${BASH_COMPONENT_TAG}"
GIT_COMPONENT_IMG="${OWNER_ID}/${GIT_COMPONENT_ID}:${GIT_COMPONENT_TAG}"
SSHD_COMPONENT_IMG="${OWNER_ID}/${SSHD_COMPONENT_ID}:${SSHD_COMPONENT_TAG}"
TMUX_COMPONENT_IMG="${OWNER_ID}/${TMUX_COMPONENT_ID}:${TMUX_COMPONENT_TAG}"
ZIG_COMPONENT_IMG="${OWNER_ID}/${ZIG_COMPONENT_ID}:${ZIG_TAG}"

### Paths ####################################################################
DATA_PATH='/opt/data'
CRONTABS_PATH='/etc/crontabs'
CRONTABS_LOG_PATH='/var/log/cron.log'
ETC_NGX_PATH='/etc/nginx'
DOCKER_PATH='/usr/local/bin'
OPT_SCRIPTS_PATH='/opt/scripts'
OPT_SSH_PATH='/opt/ssh'
SOCKET_PATH='/var/run/docker.sock'
SSH_ROOT_PATH='/root/.ssh'
TPM_PATH='/root/.tmux/plugins/tpm'
VAR_LOG_PATH='/var/log'
WORKSPACES_PATH='/workspaces'
COMPLETION_PATH="${DATA_PATH}/99completion"
ENTRYPOINT_PATH="${OPT_SCRIPTS_PATH}/docker_entrypoint.sh"
CRON_LOG_PATH="${VAR_LOG_PATH}/cron.log"
MY_WHALE_FLEET_PATH="${WORKSPACES_PATH}/my-whale-fleet"

### Volumes ##################################################################
DELETE_ME_SFX='-DELME'
MY_WHALE_FLEET_VOLUME='my-whale-fleet'
PROXY_FS_VOLUME="${PROXY_ID}-fs${DELETE_ME_SFX}"
COLLECTOR_VAR_LOG_VOLUME="${COLLECTOR_ID}-var-log-fs${DELETE_ME_SFX}"
COLLECTOR_ETC_CRONTABS_VOLUME="${COLLECTOR_ID}-etc-crontabs-fs${DELETE_ME_SFX}"
COLLECTOR_OPT_DATA_VOLUME="${COLLECTOR_ID}-opt-data-fs${DELETE_ME_SFX}"
COLLECTOR_OPT_SCRIPTS_VOLUME="${COLLECTOR_ID}-opt-scripts-fs${DELETE_ME_SFX}"
SSH_VOLUME="shared-ssh${DELETE_ME_SFX}"

### Networks #################################################################
JUMP_AREA_NET='jump-area'
PROXIFIED_SOCKET_NET='proxified-socket'
NET_PFX='172.17'
SUBNET_MASK='/24'

### Subnets ##################################################################
PROXIFIED_SOCKET_PFX="${NET_PFX}.1"
JUMP_AREA_PFX="${NET_PFX}.2"
PROXIFIED_SOCKET_SUB="${PROXIFIED_SOCKET_PFX}.0${SUBNET_MASK}"
JUMP_AREA_SUB="${JUMP_AREA_PFX}.0${SUBNET_MASK}"

### IPs ######################################################################
PROXIFIED_SOCKET_GATEWAY_IP="${PROXIFIED_SOCKET_PFX}.1"
JUMP_AREA_GATEWAY_IP="${JUMP_AREA_PFX}.1"
PROXY_IP="${PROXIFIED_SOCKET_PFX}.2"
COLLECTOR_IP="${PROXIFIED_SOCKET_PFX}.3"
CONTROLLER_IP="${PROXIFIED_SOCKET_PFX}.4"

### Ports ####################################################################
PROXY_PORT='2363'

### Users ####################################################################
UNPRIVILEGED_USER='visitor'

### URLs #####################################################################
API_URL='https://raw.githubusercontent.com/moby/moby/master/docs/api'
MY_WHALE_FLEET_URL='https://github.com/tiawl/my-whale-fleet'
TPM_URL='https://github.com/tmux-plugins/tpm'
ZIG_BUILDS_URL='https://ziglang.org/builds'

### Docker host ##############################################################
DOCKER_HOST="${PROXY_ID}:${PROXY_PORT}"
HTTP_DOCKER_HOST="http://${DOCKER_HOST}"
TCP_DOCKER_HOST="tcp://${DOCKER_HOST}"
