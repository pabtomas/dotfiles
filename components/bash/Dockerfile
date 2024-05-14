ARG BASH_IMG
ARG ENTRYPOINT_COMPONENT_IMG
FROM ${ENTRYPOINT_COMPONENT_IMG} as entrypoint_image
FROM ${BASH_IMG}

COPY etc/ /etc/

ARG BASH_ALIASES_PATH
ARG BASH_COMPLETION_PATH
ARG NET_PFX
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk update
    apk add --no-cache coreutils bash-completion tree
    mkdir -p "${BASH_ALIASES_PATH}" "${BASH_COMPLETION_PATH}"
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd
    themes="$(yes "$(printf '%s\n' '21' '27' '33' '39' '45' '46' '47' '48' '49' '50' '51' '82' '93' '118' '129' '154' '165' '190' '196' '197' '198' '199' '200' '201' '202' '208' '214' '220' '244' '15' | shuf)" | head -n 256)"
    cat << TEMPLATING >> /etc/profile.d/10themes.sh
#! /bin/sh -eu

THEMES=( ${themes} )
ID="\$(hostname -i | tr ' ' '\n' | grep '^${NET_PFX}')"
PROMPT_THEME="\${THEMES["\${ID##*.}"]}"
THEME="\${THEMES[0]}"

export THEMES PROMPT_THEME THEME
TEMPLATING
    cat << TEMPLATING >> "$(dirname "${BASH_ALIASES_PATH}")/$(basename -s '.d' "${BASH_ALIASES_PATH}").sh"
#! /bin/sh -eu

unalias -a

if [ -d ${BASH_ALIASES_PATH} ]
then
  for file in ${BASH_ALIASES_PATH}/*.sh
  do
    if [ -r "\${file}" ]
    then
      . "\${file}"
    fi
  done
  unset file
fi
TEMPLATING
    cat << TEMPLATING >> "$(dirname "${BASH_COMPLETION_PATH}")/$(basename -s '.d' "${BASH_COMPLETION_PATH}").sh"
#! /bin/sh -eu

unalias -a

if [ -d ${BASH_COMPLETION_PATH} ]
then
  for file in ${BASH_COMPLETION_PATH}/*.sh
  do
    if [ -r "\${file}" ]
    then
      . "\${file}"
    fi
  done
  unset file
fi
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN

ARG OPT_SCRIPTS_PATH
COPY --from=entrypoint_image ${OPT_SCRIPTS_PATH}/ ${OPT_SCRIPTS_PATH}/

ARG ENTRYPOINT_PATH
ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
