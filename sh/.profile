EDITOR='vim'
VISUAL='vim'
PAGER='less'

SHELL='/bin/bash'

PATH="${HOME}/.cabal/bin:${HOME}/.local/bin:${PATH}"

if [ "x${TERM}" = 'x' ]; then
  TERM="xterm-256color"
fi

export VISUAL EDITOR PAGER SHELL PATH TERM

tput init

export VIMRUNTIME="${HOME}/.local/src/vim/runtime"

export GIT_TEMPLATE_DIR='/usr/share/git-core/templates'

export FFF_KEY_CHILD1='off'
export FFF_KEY_CHILD3='off'

export FFF_KEY_PARENT1='off'
export FFF_KEY_PARENT3='off'
export FFF_KEY_PARENT4='off'

export FFF_KEY_SCROLL_DOWN1='off'
export FFF_KEY_SCROLL_UP1='off'

export VIMRUNTIME GIT_TEMPLATE_DIR FFF_KEY_CHILD1 FFF_KEY_CHILD3 \
  FFF_KEY_PARENT1 FFF_KEY_PARENT3 FFF_KEY_PARENT4 \
  FFF_KEY_SCROLL_DOWN1 FFF_KEY_SCROLL_UP1
