redshift -x > /dev/null
redshift -O 5500k > /dev/null
force_color_prompt=yes

if [ -e ${HOME}/.bash_aliases ]; then
  source ${HOME}/.bash_aliases
fi

cd .
