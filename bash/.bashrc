force_color_prompt=yes

git config --global core.editor vim
git config merge.tool vimdiff
git config merge.conflictstyle diff3
git config mergetool.prompt false

if [[ -z "${TMUX+x}" ]]
then
  export GREEN='42'
  export GRAY_900='233'
  export GRAY_800='239'
  export GRAY_700='243'
  export GRAY_600='246'
  export GRAY_500='249'
  export GRAY_400='252'
  export ZINC='59'
  export WHITE='231'
  export THEME="$(( ${RANDOM} % 216 + 16 ))"
  export TIGRC_USER="$(sh "${HOME}/.local/sh/generate-tigrc.sh")"
fi

eval "$(direnv hook bash)"
