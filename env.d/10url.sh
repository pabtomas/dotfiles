#! /bin/sh
# shellcheck disable=2034,2154
# SC2034: VAR appears unused => VAR used for templating
# SC2154: VAR is referenced but not assigned => VAR is assigned with eval statement in 01init.sh function

url 'api' "https://raw.githubusercontent.com/moby/moby/master/docs/api/v${API_TAG}.yaml"
url 'figlet_fonts' 'https://github.com/xero/figlet-fonts'
url 'nerdtree' 'https://github.com/preservim/nerdtree'
url 'owner' "https://github.com/${OWNER_ID}"
url 'polyglot' 'https://github.com/sheerun/vim-polyglot'
url 'rainbow' 'https://github.com/luochen1990/rainbow'
url 'tig_completion' 'https://raw.githubusercontent.com/jonas/tig/master/contrib/tig-completion.bash'
url 'tmux_completion' 'https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux'
url 'tpm' 'https://github.com/tmux-plugins/tpm'
url 'undotree' 'https://github.com/mbbill/undotree'
url 'zig_builds' 'https://ziglang.org/builds'
url 'zig_completion' 'https://raw.githubusercontent.com/ziglang/shell-completions/master/_zig.bash'
