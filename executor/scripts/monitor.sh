#!/bin/bash

color () {
  local PERCENT=$1
  [ ${PERCENT} -lt 0 ] && PERCENT=0
  [ ${PERCENT} -gt 100 ] && PERCENT=100
  if [ ${PERCENT} -lt 50 ]; then
    PERCENT=$(( ${PERCENT} * 2 ))
    COLOR="$(echo "16o$(( 255 - $(echo "${PERCENT} 2.55 *p" | dc \
      | xargs -I {} printf '%.0f\n' {}) ))p" | dc)"
    while [ ${#COLOR} -lt 2 ]; do COLOR="0${COLOR}"; done
    COLOR="FFFF${COLOR}"
  else
    PERCENT=$(( (${PERCENT} - 50) * 2 ))
    COLOR="$(echo "16o$(( 255 - $(echo "${PERCENT} 2.55 *p" | dc \
      | xargs -I {} printf '%.0f\n' {}) ))p" | dc)"
    while [ ${#COLOR} -lt 2 ]; do COLOR="0${COLOR}"; done
    COLOR="FF${COLOR}00"
  fi
  echo ${COLOR}
}

UNICODE="\342\223\252"
IDX=0
TEXT="<executor.markup.true> "
for CPU in $(top -b -n 1 -1 | grep -E "^%Cpu[0-9]+" \
  | awk "{printf \"%s \", \$3}"); do
    if [ ${IDX} -gt 0 ]; then
      if [ ${IDX} -lt 11 ]; then
        UNICODE="\342\223\\"$(echo "8o$(( 180 + ${IDX} ))p" | dc)
      elif [ ${IDX} -lt 21 ]; then
        UNICODE="\342\221\\"$(echo "8o$(( 159 + ${IDX} ))p" | dc)
      elif [ ${IDX} -lt 36 ]; then
        UNICODE="\343\211\\"$(echo "8o$(( 124 + ${IDX} ))p" | dc)
      elif [ ${IDX} -lt 51 ]; then
        UNICODE="\343\212\\"$(echo "8o$(( 141 + ${IDX} ))p" | dc)
      else
        echo "More CPU core than exected." && exit
      fi
    fi
    PERCENT=$(printf '%.0f' $(echo ${CPU} | sed "s/,/./"))
    SPAN="<span foreground='#$(color ${PERCENT})'>${UNICODE} ${PERCENT}%</span>"
    TEXT="${TEXT} ${SPAN}"
    IDX=$(( ${IDX}+1 ))
done

echo "${TEXT}"
