redshift -x > /dev/null
redshift -O 5500k > /dev/null
force_color_prompt=yes

alias ls='ls --color'
alias ll='ls -lA --color'
alias grep='grep --color'

cd () {
  command cd "$@"
  if [ $? -eq 0 ]; then
    command timeout 0.1 bash -c \
\ \ \ 'SZ=0;'\
\ \ \ 'DSZ=$(( (('${LINES}' / 2) * ('${COLUMNS}' / ((('\
\ \ \ '  $(command ls -fl'\
\ \ \ '    | command awk "{printf \"%s %s %s\n\", \$9, \$10, \$11}"'\
\ \ \ '    | command wc -L) / 8) + 1) * 8))) + 3 ));'\
\ \ \ 'SZ=$(command ls -f'\
\ \ \ '     | (while command read -r file && [ ${SZ} -lt ${DSZ} ]; do'\
\ \ \ '          ((SZ+=1));'\
\ \ \ '        done; command echo ${SZ}));'\
\ \ \ 'if [ ${SZ} -lt ${DSZ} ]; then'\
\ \ \ '  command ls -lA --color | command tail -n+2'\
\ \ \ '    | command awk "{printf \"%s %s %s\n\", \$9, \$10, \$11}"'\
\ \ \ '    | command column;'\
\ \ \ 'else'\
\ \ \ '  COL="\033[1;33m";'\
\ \ \ '  NC="\033[0m";'\
\ \ \ '  command echo -e ${COL}"Huge current directory."'\
\ \ \ '    "Use listing commands carrefully."${NC};'\
\ \ \ 'fi'
    if [ $? -eq 124 ]; then
      local COL="\033[1;31m"
      local NC="\033[0m"
      command echo -e ${COL}"Timeout occured."\
        "Avoid listing commands in current directory."${NC}
    fi
  fi
}

alias ga='git add'
alias gam='git add -A && git commit -m'
alias gb='git branch'
alias gc='git clone'
alias gd='git diff --color | sed "s/^\([^-+ ]*\)[-+ ]/\\1/" | less -r'
alias gh='git checkout'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gm='git commit -m'
alias gp='git pull'
alias gP='git push'
alias gr='git remote'
alias gs='git status -s'
alias gu='git reset --soft HEAD^'
