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

export FFF_KEY_CHILD1='off'
export FFF_KEY_CHILD3='off'

export FFF_KEY_PARENT1='off'
export FFF_KEY_PARENT3='off'
export FFF_KEY_PARENT4='off'

export FFF_KEY_SCROLL_DOWN1='off'
export FFF_KEY_SCROLL_UP1='off'

export FLAGBOX_SIZE=4

export FLAGBOX_KEY1=","
export FLAGBOX_KEY2="?"

export FLAGBOX_ALIASES=true
export FLAGBOX_DECIMAL_NAVMODE=true
export FLAGBOX_BACKUPCONFIRM=true

export FLAGBOX_VINSERT=false
export FLAGBOX_VNAV=true
export FLAGBOX_VRESET=false
export FLAGBOX_VRESTORE=true

export FLAGBOX_FOLDLISTING=true
