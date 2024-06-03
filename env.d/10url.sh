#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

_url 'api' "https://raw.githubusercontent.com/moby/moby/master/docs/api/v${API_TAG}.yaml"
_url 'dockle_download' 'https://github.com/goodwithtech/dockle/releases/download'
_url 'figlet_fonts' 'https://github.com/xero/figlet-fonts'
_url 'nerdtree' 'https://github.com/preservim/nerdtree'
_url 'owner' "https://github.com/${OWNER_ID}"
_url 'polyglot' 'https://github.com/sheerun/vim-polyglot'
_url 'rainbow' 'https://github.com/luochen1990/rainbow'
_url 'regbot' 'https://github.com/regclient/regclient/releases/latest/download/regbot-linux-amd64'
_url 'regctl' 'https://github.com/regclient/regclient/releases/latest/download/regctl-linux-amd64'
_url 'regsync' 'https://github.com/regclient/regclient/releases/latest/download/regsync-linux-amd64'
_url 'tig_completion' 'https://raw.githubusercontent.com/jonas/tig/master/contrib/tig-completion.bash'
_url 'tmux_completion' 'https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux'
_url 'tpm' 'https://github.com/tmux-plugins/tpm'
_url 'undotree' 'https://github.com/mbbill/undotree'
_url 'zig_builds' 'https://ziglang.org/builds'
_url 'zig_completion' 'https://raw.githubusercontent.com/ziglang/shell-completions/master/_zig.bash'
