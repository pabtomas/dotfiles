force_color_prompt=yes

export PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "

export VIMRUNTIME="${HOME}/.local/sources/vim/runtime"

export GIT_TEMPLATE_DIR="/usr/share/git-core/templates"
git config --global core.editor vim

source ${HOME}/.local/bin/flagbox.sh
