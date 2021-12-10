export PATH="$PATH:/home/user/.local/bin"

export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"

export SHELL="/bin/bash"

if [ "x${TERM}" = "x" ]; then
  export TERM="xterm-256color"
fi

tput init

export VIMRUNTIME="${HOME}/.local/sources/vim/runtime"

export GIT_TEMPLATE_DIR="/usr/share/git-core/templates"

# Allow tmux to source .bashrc each time a pane or a window is created
source $HOME/.bashrc
