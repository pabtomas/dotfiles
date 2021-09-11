redshift -x
redshift -O 5500k

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
\ \ \ '  command ls -la --color | command tail -n+4'\
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
