ARG BASH_IMG
FROM ${BASH_IMG}

COPY etc/profile.d/* /etc/profile.d/

ARG NET_PFX
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    apk add --no-cache coreutils
    sed -i "s@^\(root:.*:\)[^:]\+\$@\1$(command -v bash)@" /etc/passwd
    themes="$(yes "$(printf '%s\n' '21' '27' '33' '39' '45' '46' '47' '48' '49' '50' '51' '82' '93' '118' '129' '154' '165' '190' '196' '197' '198' '199' '200' '201' '202' '208' '214' '220' '244' '15' | shuf)" | head -n 256)"
    cat << TEMPLATING >> /etc/profile.d/10themes.sh
THEMES=( ${themes} )
ID="\$(hostname -i | tr " " "\n" | grep "^${NET_PFX}")"
PROMPT_THEME="\${THEMES["\${ID##*.}"]}"
THEME="\${THEMES[0]}"
export THEMES PROMPT_THEME THEME
TEMPLATING
    unset http_proxy https_proxy
END_OF_RUN
