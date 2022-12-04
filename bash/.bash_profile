export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

export SHELL='/bin/bash'

export PATH="${HOME}/.cabal/bin:${HOME}/.local/bin:${PATH}"

if [ "x${TERM}" = 'x' ]; then
  export TERM="xterm-256color"
fi

tput init

export VIMRUNTIME="${HOME}/.local/sources/vim/runtime"

export GIT_TEMPLATE_DIR='/usr/share/git-core/templates'

export FFF_KEY_CHILD1='off'
export FFF_KEY_CHILD3='off'

export FFF_KEY_PARENT1='off'
export FFF_KEY_PARENT3='off'
export FFF_KEY_PARENT4='off'

export FFF_KEY_SCROLL_DOWN1='off'
export FFF_KEY_SCROLL_UP1='off'
