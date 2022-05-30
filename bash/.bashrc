force_color_prompt=yes

git config --global core.editor vim
git config merge.tool vimdiff
git config merge.conflictstyle diff3
git config mergetool.prompt false

eval "$(direnv hook bash)"
