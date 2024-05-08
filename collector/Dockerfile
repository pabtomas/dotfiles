ARG OS_IMG

FROM ${OS_IMG}

ARG APK_PATHS
ARG COMPLETION_PATH
ARG CRON_LOG_PATH
ARG CRONTABS_PATH
ARG DATA_PATH
ARG ENTRYPOINT_PATH
ARG HTTP_DOCKER_HOST
ARG NET
ARG OPT_SCRIPTS_PATH
ARG PROXY_ID
ARG HTTP_PROXY
ARG HTTPS_PROXY

RUN <<END_OF_RUN
    set -eux
    if [ -n "${HTTP_PROXY}" ]; then export http_proxy="${HTTP_PROXY}"; fi
    if [ -n "${HTTPS_PROXY}" ]; then export https_proxy="${HTTPS_PROXY}"; fi
    apk add --no-cache jq
    rm -rf ${APK_PATHS}
    mkdir -p "${OPT_SCRIPTS_PATH}" "${DATA_PATH}"
    _jq="$(command -v jq)"
    _wget="$(command -v wget)"
    read -r -d '' wget_script << TEMPLATING || :
id="\$(${_wget} -q -O- '${HTTP_DOCKER_HOST}/networks' | ${_jq} -r '.[] | select(.Name=="${NET}") | .Id')"
${_wget} -q -O- "${HTTP_DOCKER_HOST}/networks/\${id}" | ${_jq} -r '.Containers | to_entries[] | .value.Name' > '${COMPLETION_PATH}'
TEMPLATING
    completion_collector_script="${OPT_SCRIPTS_PATH}/completion_collector.sh"
    cat << TEMPLATING > "${completion_collector_script}"
#!/bin/sh
prefix="\$(date '+[%F %T] ${completion_collector_script}: ')"
${wget_script} 2>&1 && printf 'success\n' | sed "s@^@\${prefix}@" >> '${CRON_LOG_PATH}'
TEMPLATING
    chmod 0700 "${completion_collector_script}"
    cat << TEMPLATING > "${CRONTABS_PATH}/root"
* * * * * ${completion_collector_script}
TEMPLATING
    _crond="$(command -v crond)"
    cat << TEMPLATING > "${ENTRYPOINT_PATH}"
#!/bin/sh
${wget_script}
exec ${_crond} -f
TEMPLATING
    chmod 0700 "${ENTRYPOINT_PATH}"
    if [ -n "${HTTP_PROXY}" ]; then unset http_proxy; fi
    if [ -n "${HTTPS_PROXY}" ]; then unset https_proxy; fi
END_OF_RUN

ENV ENTRYPOINT_PATH ${ENTRYPOINT_PATH}
ENTRYPOINT ${ENTRYPOINT_PATH}
