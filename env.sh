#!/bin/sh

FALSE='0'
TRUE='1'
APK_PATHS='/sbin/apk /etc/apk /lib/apk /usr/share/apk /var/lib/apk'
API_PFX='API_ENDPOINT_'
COMPOSE_PROJECT_NAME='mywhalefleet'
ID_SEP='/'
SERVICE_SEP='.'
HOST_SEP='.'

### Ids ######################################################################
COLLECTOR_ID='collector'
CONTROLLER_ID='controller'
EDITOR_ID='editor'
JUMPER_ID='jumper'
OWNER_ID='tiawl'
PROXY_ID='proxy'
SAFEDEPOSIT_ID='safedeposit'
SCHOLAR_ID='scholar'
COMPONENT_ID='component'
EXPLORER_ID='explorer'
RUNNER_ID='runner'
SHELL_ID='shell'
SPACEPORN_ID='spaceporn'
BASH_ID='bash'
DOCKER_ID='docker'
GIT_ID='git'
LINGUIST_ID='linguist'
MAN_ID='man'
PASS_ID='pass'
SSHD_ID='sshd'
TMUX_ID='tmux'
VIM_ID='vim'
WORKSPACES_ID='workspaces'
ZIG_ID='zig'
component_id () { printf '%s%s%s\n' "${COMPONENT_ID}" "${ID_SEP}" "${1}"; }
BASH_COMPONENT_ID="$(component_id "${BASH_ID}")"
DOCKER_COMPONENT_ID="$(component_id "${DOCKER_ID}")"
GIT_COMPONENT_ID="$(component_id "${GIT_ID}")"
LINGUIST_COMPONENT_ID="$(component_id "${LINGUIST_ID}")"
MAN_COMPONENT_ID="$(component_id "${MAN_ID}")"
PASS_COMPONENT_ID="$(component_id "${PASS_ID}")"
SSHD_COMPONENT_ID="$(component_id "${SSHD_ID}")"
TMUX_COMPONENT_ID="$(component_id "${TMUX_ID}")"
VIM_COMPONENT_ID="$(component_id "${VIM_ID}")"
WORKSPACES_COMPONENT_ID="$(component_id "${WORKSPACES_ID}")"
ZIG_COMPONENT_ID="$(component_id "${ZIG_ID}")"
explorer_id () { printf '%s%s%s\n' "${EXPLORER_ID}" "${ID_SEP}" "${1}"; }
SHELL_EXPLORER_ID="$(explorer_id "${SHELL_ID}")"
ZIG_EXPLORER_ID="$(explorer_id "${ZIG_ID}")"
runner_id () { printf '%s%s%s\n' "${RUNNER_ID}" "${ID_SEP}" "${1}"; }
SPACEPORN_RUNNER_ID="$(runner_id "${SPACEPORN_ID}")"

### Services #################################################################
COLLECTOR_SERVICE="${COLLECTOR_ID}"
CONTROLLER_SERVICE="${CONTROLLER_ID}"
EDITOR_SERVICE="${EDITOR_ID}"
JUMPER_SERVICE="${JUMPER_ID}"
PROXY_SERVICE="${PROXY_ID}"
SAFEDEPOSIT_SERVICE="${SAFEDEPOSIT_ID}"
SCHOLAR_SERVICE="${SCHOLAR_ID}"
BASH_SERVICE="${BASH_ID}"
DOCKER_SERVICE="${DOCKER_ID}"
GIT_SERVICE="${GIT_ID}"
LINGUIST_SERVICE="${LINGUIST_ID}"
MAN_SERVICE="${MAN_ID}"
PASS_SERVICE="${PASS_ID}"
SSHD_SERVICE="${SSHD_ID}"
TMUX_SERVICE="${TMUX_ID}"
VIM_SERVICE="${VIM_ID}"
WORKSPACES_SERVICE="${WORKSPACES_ID}"
ZIG_SERVICE="${ZIG_ID}"
RUNNER_SERVICE="${RUNNER_ID}"
explorer_service () { printf '%s%s%s\n' "${EXPLORER_ID}" "${SERVICE_SEP}" "${1}"; }
SHELL_EXPLORER_SERVICE="$(explorer_service "${SHELL_ID}")"
ZIG_EXPLORER_SERVICE="$(explorer_service "${ZIG_ID}")"

### Hostnames ################################################################
COLLECTOR_HOST="${COLLECTOR_ID}"
CONTROLLER_HOST="${CONTROLLER_ID}"
EDITOR_HOST="${EDITOR_ID}"
JUMPER_HOST="${JUMPER_ID}"
MAN_HOST="${MAN_ID}"
PROXY_HOST="${PROXY_ID}"
SAFEDEPOSIT_HOST="${SAFEDEPOSIT_ID}"
SCHOLAR_HOST="${SCHOLAR_ID}"
explorer_host () { printf '%s%s%s\n' "${EXPLORER_ID}" "${HOST_SEP}" "${1}"; }
SHELL_EXPLORER_HOST="$(explorer_host "${SHELL_ID}")"
ZIG_EXPLORER_HOST="$(explorer_host "${ZIG_ID}")"

### Tags #####################################################################
ALPINE_TAG='3.19'
BASH_TAG='5.2'
COLLECTOR_TAG='latest'
CONTROLLER_TAG='latest'
DOCKER_TAG='dind'
JUMPER_TAG='latest'
LINUXSERVER_PROXY_TAG='latest'
PROXY_TAG='latest'
SPACEPORN_RUNNER_TAG='latest'
BASH_COMPONENT_TAG='latest'
DOCKER_COMPONENT_TAG='latest'
GIT_COMPONENT_TAG='latest'
LINGUIST_COMPONENT_TAG='latest'
MAN_COMPONENT_TAG='latest'
PASS_COMPONENT_TAG='latest'
SSHD_COMPONENT_TAG='latest'
SHELL_EXPLORER_TAG='latest'
TMUX_COMPONENT_TAG='latest'
VIM_COMPONENT_TAG='latest'
WORKSPACES_COMPONENT_TAG='latest'
ZIG_TAG='0.12.0'

### Extern Images ############################################################
image () { printf '%s/%s:%s\n' "${1}" "${2}" "${3}"; }
# into the shell: export http_proxy='https://you.custom.proxy:<port>'
#ALPINE_IMG='local_alpine'
#BASH_IMG='local_bash'
#DOCKER_IMG='local_docker'
#LINUXSERVER_PROXY_IMG='local_proxy'
ALPINE_IMG="$(image 'docker.io' 'alpine' "${ALPINE_TAG}")"
BASH_IMG="$(image 'docker.io' 'bash' "${BASH_TAG}")"
DOCKER_IMG="$(image 'docker.io' 'docker' "${DOCKER_TAG}")"
LINUXSERVER_PROXY_IMG="$(image 'lscr.io/linuxserver' 'socket-proxy' "${LINUXSERVER_PROXY_TAG}")"
OS_IMG="${ALPINE_IMG}"

### Intern Images ############################################################

### Final Images #############################################################
COLLECTOR_IMG="$(image "${OWNER_ID}" "${COLLECTOR_ID}" "${COLLECTOR_TAG}")"
CONTROLLER_IMG="$(image "${OWNER_ID}" "${CONTROLLER_ID}" "${CONTROLLER_TAG}")"
JUMPER_IMG="$(image "${OWNER_ID}" "${JUMPER_ID}" "${JUMPER_TAG}")"
PROXY_IMG="$(image "${OWNER_ID}" "${PROXY_ID}" "${PROXY_TAG}")"

### Runners Images ###########################################################
SPACEPORN_RUNNER_IMG="$(image "${OWNER_ID}" "${SPACEPORN_RUNNER_ID}:${SPACEPORN_RUNNER_TAG}")"

### Explorers Images #########################################################
SHELL_EXPLORER_IMG="$(image "${OWNER_ID}" "${SHELL_EXPLORER_ID}" "${SHELL_EXPLORER_TAG}")"
ZIG_EXPLORER_IMG="$(image "${OWNER_ID}" "${ZIG_EXPLORER_ID}" "${ZIG_TAG}")"

### Components Images ########################################################
BASH_COMPONENT_IMG="$(image "${OWNER_ID}" "${BASH_COMPONENT_ID}" "${BASH_COMPONENT_TAG}")"
DOCKER_COMPONENT_IMG="$(image "${OWNER_ID}" "${DOCKER_COMPONENT_ID}" "${DOCKER_COMPONENT_TAG}")"
GIT_COMPONENT_IMG="$(image "${OWNER_ID}" "${GIT_COMPONENT_ID}" "${GIT_COMPONENT_TAG}")"
LINGUIST_COMPONENT_IMG="$(image "${OWNER_ID}" "${LINGUIST_COMPONENT_ID}" "${LINGUIST_COMPONENT_TAG}")"
MAN_COMPONENT_IMG="$(image "${OWNER_ID}" "${MAN_COMPONENT_ID}" "${MAN_COMPONENT_TAG}")"
PASS_COMPONENT_IMG="$(image "${OWNER_ID}" "${PASS_COMPONENT_ID}" "${PASS_COMPONENT_TAG}")"
SSHD_COMPONENT_IMG="$(image "${OWNER_ID}" "${SSHD_COMPONENT_ID}" "${SSHD_COMPONENT_TAG}")"
TMUX_COMPONENT_IMG="$(image "${OWNER_ID}" "${TMUX_COMPONENT_ID}" "${TMUX_COMPONENT_TAG}")"
VIM_COMPONENT_IMG="$(image "${OWNER_ID}" "${VIM_COMPONENT_ID}" "${VIM_COMPONENT_TAG}")"
WORKSPACES_COMPONENT_IMG="$(image "${OWNER_ID}" "${WORKSPACES_COMPONENT_ID}" "${WORKSPACES_COMPONENT_TAG}")"
ZIG_COMPONENT_IMG="$(image "${OWNER_ID}" "${ZIG_COMPONENT_ID}" "${ZIG_TAG}")"

### Paths ####################################################################
BASH_ALIASES_PATH='/etc/profile.d/99aliases.d'
BASH_COMPLETION_PATH='/etc/profile.d/99completion.d'
DATA_PATH='/opt/data'
CRONTABS_PATH='/etc/crontabs'
CRONTABS_LOG_PATH='/var/log/cron.log'
ETC_NGX_PATH='/etc/nginx'
DOCKER_PATH='/usr/local/bin'
OPT_SCRIPTS_PATH='/opt/scripts'
OPT_SSH_PATH='/opt/ssh'
SAFEDEPOSIT_PATH='/root/.password-store'
SOCKET_PATH='/var/run/docker.sock'
SSH_ROOT_PATH='/root/.ssh'
TPM_PATH='/root/.tmux/plugins/tpm'
VAR_LOG_PATH='/var/log'
WORKSPACES_PATH='/workspaces'
COMPLETION_PATH="${DATA_PATH}/99completion"
ENTRYPOINT_PATH="${OPT_SCRIPTS_PATH}/docker_entrypoint.sh"
CRON_LOG_PATH="${VAR_LOG_PATH}/cron.log"
MY_WHALE_FLEET_PATH="${WORKSPACES_PATH}/${COMPOSE_PROJECT_NAME}"
SPACEPORN_PATH="${WORKSPACES_PATH}/${SPACEPORN_ID}"

### Volumes ##################################################################
DELETE_ME_SFX='-DELME'
MY_WHALE_FLEET_VOLUME="${COMPOSE_PROJECT_NAME}"
SPACEPORN_VOLUME="${SPACEPORN_ID}"
SAFEDEPOSIT_VOLUME="${SAFEDEPOSIT_ID}"
PROXY_NGX_FS_VOLUME="${PROXY_ID}-etc-nginx-fs${DELETE_ME_SFX}"
PROXY_SCRIPTS_FS_VOLUME="${PROXY_ID}-opt-scripts-fs${DELETE_ME_SFX}"
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
API_URL="https://raw.githubusercontent.com/moby/moby/master/docs/api/v${API_TAG}.yaml"
FIGLET_FONTS_URL='https://github.com/xero/figlet-fonts'
NERDTREE_URL='https://github.com/preservim/nerdtree'
POLYGLOT_URL='https://github.com/sheerun/vim-polyglot'
RAINBOW_URL='https://github.com/luochen1990/rainbow'
TPM_URL='https://github.com/tmux-plugins/tpm'
UNDOTREE_URL='https://github.com/mbbill/undotree'
TIG_COMPLETION_URL='https://raw.githubusercontent.com/jonas/tig/master/contrib/tig-completion.bash'
TMUX_COMPLETION_URL='https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux'
ZIG_BUILDS_URL='https://ziglang.org/builds'

### Docker host ##############################################################
DOCKER_HOST="${PROXY_ID}:${PROXY_PORT}"
HTTP_DOCKER_HOST="http://${DOCKER_HOST}"
TCP_DOCKER_HOST="tcp://${DOCKER_HOST}"
