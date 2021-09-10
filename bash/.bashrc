redshift -x
redshift -O 5500k

function cd () {
  command cd "$@"
  if [ $? -eq 0 ]; then
    local SZ=0
    local DSZ=$(( ${LINES} + 2 ))
    local SZ=$(ls -f | (while read -r file && [ ${SZ} -lt ${DSZ} ]; do \
                          ((SZ+=1)); \
                        done; echo ${SZ}))
    if [ ${SZ} -lt ${DSZ} ]; then
      ls -la --color | tail -n+4 | awk '{printf "- %s %s %s\n", $9, $10, $11}'
    else
      local COL='\033[1;33m'
      local NC='\033[0m'
      echo -e ${COL}"Huge current directory."\
        "Use listing commands carrefully."${NC}
    fi
  fi
}
