ARG BASH_IMG

FROM ${BASH_IMG}

ARG CONTROLLER
ARG HOSTNAME
ARG NET
ARG OPT_SSH

RUN <<END_OF_RUN
    set -eux
    apk --no-cache add openssh-client
    mkdir -p /root/.ssh "${OPT_SSH}"
    KEY='/root/.ssh/id_rsa'
    ssh-keygen -q -t rsa -N '' -f "${KEY}"
    printf 'StrictHostKeyChecking accept-new\n' > "/etc/ssh/ssh_config.d/${NET}.conf"
    cp "${KEY}.pub" "${OPT_SSH}/authorized_keys"
    ENTRYPOINT='/docker_entrypoint.sh'
    cat << TEMPLATING > "${ENTRYPOINT}"
#!/bin/sh
printf '_ssh ()
{
  declare -a -g COMPREPLY;
  COMPREPLY=( \$(compgen -W "%s" -- "\${COMP_WORDS["\${COMP_CWORD}"]}" ) )
}
complete -F _ssh ssh\n' "\$(ssh '${CONTROLLER}' "docker network inspect -f '{{ range .Containers }}{{ printf \" %s \" .Name }}{{ end }}'" '${NET}' 2> /dev/null | sed 's@\s${HOSTNAME}\s@@')" > /etc/profile.d/completion.sh
/usr/local/bin/bash -l
TEMPLATING
    chmod 0700 "${ENTRYPOINT}"
END_OF_RUN

ENTRYPOINT ["/docker_entrypoint.sh"]
