ipsec ()
{
  [ ${#} -ne 1 ] && printf "ipsec needs 1 parameter\n" && return 1
  px='pfrie-std.proxy.e2.rie.gouv.fr:8080'
  case "${1}" in
    'gitlab') ssh -D 3129 bdx.bastion0.cs.e2.rie.gouv.fr ;;
    'up') if command ip route show dev eno1 | grep -E '10.132.0.' > /dev/null
          then
            # px='proxycs.ac.cs:3128'
            printf '\nAjout des proxies Parisiens\n'
            sudo bash -c "printf 'Acquire::http::Proxy \"http://${px}\";\nAcquire::https::Proxy \"http://${px}\";\n' > /etc/apt/apt.conf.d/99proxy"
            printf 'function FindProxyForURL(url, host) {\n// Proxy.pac Pas Authentifie Intranet MTES et DDI SNUM/MSP/DIS/Paris-Bordeaux 2023-09-04 (FBH)\n\n// Pas de proxy pour les domaines internes suivants et si le host n est pas un nom DNS (ie WINS):\nif (shExpMatch(host,"*.i2")\n || shExpMatch(host,"*.p2")\n || shExpMatch(host,"*.rie.min-e2.fr")\n || shExpMatch(host,"*.din.developpement-durable.gouv.fr")\n || shExpMatch(host,"*.proxy.developpement-durable.gouv.fr")\n || shExpMatch(host,"*.ader.gouv.fr")\n || shExpMatch(host,"*.ader.elysee.fr")\n || shExpMatch(host,"*.ader.senat.fr")\n || shExpMatch(host,"*.rie.gouv.fr")\n || shExpMatch(host,"*.testa.eu")\n || shExpMatch(host,"*.eu-admin.net")\n || shExpMatch(host,"isis*.telepac.agriculture.gouv.fr")\n// || shExpMatch(host,"*.cnasea.fr")\n// || shExpMatch(host,"www.meteo.fr")\n || shExpMatch(host,"*.asscap.ants.gouv.fr")\n || shExpMatch(host,"*.asscap-qualif.ants.gouv.fr")\n || shExpMatch(host,"raos.eprintel.fr")\n || shExpMatch(host,"*.geoportail.gouv.fr")\n || shExpMatch(host,"wmts-remonterletemps.ign.fr")\n || shExpMatch(host,"wxs.ign.fr")\n || shExpMatch(host,"gpp3-wxs.ign.fr")\n || shExpMatch(host,"portail-intranet.franceagrimer.fr")\n || shExpMatch(host,"*.webconf.numerique.gouv.fr")\n || shExpMatch(host,"webconf.numerique.gouv.fr")\n || shExpMatch(host,"local.lifesizecloud.com")\n || dnsDomainLevels(host) == 0\n) {\n        return "DIRECT";\n}\n\n// Pas de proxy dès lors que le port est indiqué et n est pas 21,22,443,999,80,8080,8082,8088,8443,10000 - ce qui doit correspondre à des dérogations flux hors proxy\nif (\nshExpMatch(url, "*://" + host + ":*")\n&& (!shExpMatch(url, "*://" + host + ":21/*"))\n&& (!shExpMatch(url, "*://" + host + ":22/*"))\n&& (!shExpMatch(url, "*://" + host + ":999/*"))\n&& (!shExpMatch(url, "*://" + host + ":80/*"))\n&& (!shExpMatch(url, "*://" + host + ":443/*"))\n&& (!shExpMatch(url, "*://" + host + ":8080/*"))\n&& (!shExpMatch(url, "*://" + host + ":8082/*"))\n&& (!shExpMatch(url, "*://" + host + ":8088/*"))\n&& (!shExpMatch(url, "*://" + host + ":8443/*"))\n&& (!shExpMatch(url, "*://" + host + ":10000/*"))\n) {\n        return "DIRECT";\n}\n\n// Proxy obligatoire pour les extranet pour la tracabilité :\nif (shExpMatch(host,"*.aviation")\n || shExpMatch(host,"*.agri")\n || shExpMatch(host,"*.agriculture")\n// || shExpMatch(host,"isis*.telepac.agriculture.gouv.fr")\n || shExpMatch(host,"*.mi")\n || shExpMatch(host,"*.minint.fr")\n || shExpMatch(host,"*.intranet.jeunesse-social.sante-sports.gouv.fr")\n || shExpMatch(host,"*.intranet.sante.gouv.fr")\n || shExpMatch(host,"*.intranet.social.gouv.fr")\n || shExpMatch(host,"*.intranet.jeunesse-sports.gouv.fr")\n || shExpMatch(host,"*.dgccrf")\n) {\n        return "PROXY partenaire.proxy.e2.rie.gouv.fr:3128";\n}\n\n// pas de proxy pour toutes les autres adresses réseaux internes sur Moréa et le RIE (afin de test)...\nif (shExpMatch(host, "10.*")\n || shExpMatch(host, "100.64.*")\n || shExpMatch(host, "100.65.*")\n || shExpMatch(host, "100.66.*")\n || shExpMatch(host, "100.67.*")\n || shExpMatch(host, "100.68.*")\n || shExpMatch(host, "100.69.*")\n || shExpMatch(host, "100.77.*")\n || shExpMatch(host, "192.168.*")\n || shExpMatch(host, "172.16.*")\n || shExpMatch(host, "172.17.*")\n || shExpMatch(host, "172.18.*")\n || shExpMatch(host, "172.19.*")\n || shExpMatch(host, "172.2*")\n || shExpMatch(host, "172.30.*")\n || shExpMatch(host, "172.31.*")\n || shExpMatch(host, "localhost")\n || shExpMatch(host, "127.0.0.1")\n) {\n        return "DIRECT";\n}\n\n// proxy spécifique pour le domaine .reate\nif (shExpMatch(host,"*.var.reate")\n) {\n        return "PROXY 10.83.91.67:3128";\n}\n\n// pilote proxy webconf internet\n//\nif (shExpMatch(host,"*.lifesize.com")\n || shExpMatch(host,"lifesize.com")\n || shExpMatch(host,"*.lifesizecloud.com")\n || shExpMatch(host,"zoom.us")\n || shExpMatch(host,"*.zoom.us")\n || shExpMatch(host,"visio.education.fr")\n || shExpMatch(host,"*.visio.education.fr")\n || shExpMatch(host,"webinaire.numerique.gouv.fr")\n || shExpMatch(host,"*.webinaire.numerique.gouv.fr")\n || shExpMatch(host,"meet.conseil-etat.fr")\n || shExpMatch(host,"ovp.orange-business.com")\n || shExpMatch(host,"openvideopresenceadvanced.orange-business.com")\n || shExpMatch(host,"*.classilio.com")\n || shExpMatch(host,"*.comu.gouv.fr")\n || shExpMatch(host,"teams.events.data.microsoft.com")\n || shExpMatch(host,"teams.live.com")\n || shExpMatch(host,"*.teams.live.com")\n || shExpMatch(host,"*.teams.microsoft.com")\n || shExpMatch(host,"*.trouter.skype.com")\n || shExpMatch(host,"*.relay.skype.com")\n || shExpMatch(host,"api.flightproxy.skype.com")\n) {\n        return "PROXY webconf.proxy.e2.rie.gouv.fr:8080";\n}\n//\n// Sinon en fin qd c est pour internet...\nreturn "PROXY %s";\n\n}\n' "${px}" > "${HOME}"/.proxy.pac
            chmod 0644 "${HOME}"/.proxy.pac
            printf '\nRetrait du DNS menteur\n'
            sudo bash -c "printf '# Generated by NetworkManager\nsearch edcs.fr\nnameserver 127.0.0.53\n' > /etc/resolv.conf"
            printf '\nRetrait des clés chargées dans l'"'"'agent SSH\n'
            ssh-add -e /usr/lib/in_p11/libidop11.so
            printf '\nAjout des clés de la carte dans l'"'"'agent SSH\n'
            ssh-add -s /usr/lib/in_p11/libidop11.so
            printf '\nArret du service Strongswan\n'
            sudo systemctl stop strongswan
            printf '\nAjout des proxies pour le service DOCKER\n'
            sudo bash -c "printf '[Service]\nEnvironment=\"HTTP_PROXY=http://${px}\"\nEnvironment=\"HTTPS_PROXY=http://${px}\"\n' > /etc/systemd/system/docker.service.d/service-env.conf"
            printf '\nAjout des proxies pour git\n'
            git config --global http.proxy "${px}"
            git config --global https.proxy "${px}"
            printf "\nAjout des proxies dans l'environnment\n"
            export http_proxy="http://${px}"
            export https_proxy="http://${px}"
            printf '\nPassage du MTU a 1500\n'
            sudo ifconfig wlo1 mtu 1500 up
          else
            printf 'Ajout des proxies parisiens\n'
            sudo bash -c "printf 'Acquire {\n  http {\n    Proxy \"http://${px}\";\n    Timeout \"120\";\n    Pipeline-Depth \"5\";\n\n    No-Cache \"false\";\n    Max-Age \"86400\";        // 1 Day age on index files\n    No-Store \"false\";       // Prevent the cache from storing archives\n  }\n};\n' > /etc/apt/apt.conf.d/99proxy"
            #printf 'function FindProxyForURL(url, host){\n  if (dnsDomainIs(host, "gitlab.edcs.fr")) {return "SOCKS5 localhost:3129";}\n  if (dnsDomainIs(host, ".edcs.fr")) {return "DIRECT";}\n  if (shExpMatch(host, "172.22.0.0/16")) {return "DIRECT";}\n  return "PROXY ha1-cspx-astreinte.sen.centre-serveur.i2:8380";\n}\n' > "${HOME}"/.proxy.pac
            printf 'function FindProxyForURL(url, host) {\n// Proxy.pac Pas Authentifie Intranet MTES et DDI SNUM/MSP/DIS/Paris-Bordeaux 2023-09-04 (FBH)\n\n// Pas de proxy pour les domaines internes suivants et si le host n est pas un nom DNS (ie WINS):\nif (shExpMatch(host,"*.i2")\n || shExpMatch(host,"*.p2")\n || shExpMatch(host,"*.rie.min-e2.fr")\n || shExpMatch(host,"*.din.developpement-durable.gouv.fr")\n || shExpMatch(host,"*.proxy.developpement-durable.gouv.fr")\n || shExpMatch(host,"*.ader.gouv.fr")\n || shExpMatch(host,"*.ader.elysee.fr")\n || shExpMatch(host,"*.ader.senat.fr")\n || shExpMatch(host,"*.rie.gouv.fr")\n || shExpMatch(host,"*.testa.eu")\n || shExpMatch(host,"*.eu-admin.net")\n || shExpMatch(host,"isis*.telepac.agriculture.gouv.fr")\n// || shExpMatch(host,"*.cnasea.fr")\n// || shExpMatch(host,"www.meteo.fr")\n || shExpMatch(host,"*.asscap.ants.gouv.fr")\n || shExpMatch(host,"*.asscap-qualif.ants.gouv.fr")\n || shExpMatch(host,"raos.eprintel.fr")\n || shExpMatch(host,"*.geoportail.gouv.fr")\n || shExpMatch(host,"wmts-remonterletemps.ign.fr")\n || shExpMatch(host,"wxs.ign.fr")\n || shExpMatch(host,"gpp3-wxs.ign.fr")\n || shExpMatch(host,"portail-intranet.franceagrimer.fr")\n || shExpMatch(host,"*.webconf.numerique.gouv.fr")\n || shExpMatch(host,"webconf.numerique.gouv.fr")\n || shExpMatch(host,"local.lifesizecloud.com")\n || dnsDomainLevels(host) == 0\n) {\n        return "DIRECT";\n}\n\n// Pas de proxy dès lors que le port est indiqué et n est pas 21,22,443,999,80,8080,8082,8088,8443,10000 - ce qui doit correspondre à des dérogations flux hors proxy\nif (\nshExpMatch(url, "*://" + host + ":*")\n&& (!shExpMatch(url, "*://" + host + ":21/*"))\n&& (!shExpMatch(url, "*://" + host + ":22/*"))\n&& (!shExpMatch(url, "*://" + host + ":999/*"))\n&& (!shExpMatch(url, "*://" + host + ":80/*"))\n&& (!shExpMatch(url, "*://" + host + ":443/*"))\n&& (!shExpMatch(url, "*://" + host + ":8080/*"))\n&& (!shExpMatch(url, "*://" + host + ":8082/*"))\n&& (!shExpMatch(url, "*://" + host + ":8088/*"))\n&& (!shExpMatch(url, "*://" + host + ":8443/*"))\n&& (!shExpMatch(url, "*://" + host + ":10000/*"))\n) {\n        return "DIRECT";\n}\n\n// Proxy obligatoire pour les extranet pour la tracabilité :\nif (shExpMatch(host,"*.aviation")\n || shExpMatch(host,"*.agri")\n || shExpMatch(host,"*.agriculture")\n// || shExpMatch(host,"isis*.telepac.agriculture.gouv.fr")\n || shExpMatch(host,"*.mi")\n || shExpMatch(host,"*.minint.fr")\n || shExpMatch(host,"*.intranet.jeunesse-social.sante-sports.gouv.fr")\n || shExpMatch(host,"*.intranet.sante.gouv.fr")\n || shExpMatch(host,"*.intranet.social.gouv.fr")\n || shExpMatch(host,"*.intranet.jeunesse-sports.gouv.fr")\n || shExpMatch(host,"*.dgccrf")\n) {\n        return "PROXY partenaire.proxy.e2.rie.gouv.fr:3128";\n}\n\n// pas de proxy pour toutes les autres adresses réseaux internes sur Moréa et le RIE (afin de test)...\nif (shExpMatch(host, "10.*")\n || shExpMatch(host, "100.64.*")\n || shExpMatch(host, "100.65.*")\n || shExpMatch(host, "100.66.*")\n || shExpMatch(host, "100.67.*")\n || shExpMatch(host, "100.68.*")\n || shExpMatch(host, "100.69.*")\n || shExpMatch(host, "100.77.*")\n || shExpMatch(host, "192.168.*")\n || shExpMatch(host, "172.16.*")\n || shExpMatch(host, "172.17.*")\n || shExpMatch(host, "172.18.*")\n || shExpMatch(host, "172.19.*")\n || shExpMatch(host, "172.2*")\n || shExpMatch(host, "172.30.*")\n || shExpMatch(host, "172.31.*")\n || shExpMatch(host, "localhost")\n || shExpMatch(host, "127.0.0.1")\n) {\n        return "DIRECT";\n}\n\n// proxy spécifique pour le domaine .reate\nif (shExpMatch(host,"*.var.reate")\n) {\n        return "PROXY 10.83.91.67:3128";\n}\n\n// pilote proxy webconf internet\n//\nif (shExpMatch(host,"*.lifesize.com")\n || shExpMatch(host,"lifesize.com")\n || shExpMatch(host,"*.lifesizecloud.com")\n || shExpMatch(host,"zoom.us")\n || shExpMatch(host,"*.zoom.us")\n || shExpMatch(host,"visio.education.fr")\n || shExpMatch(host,"*.visio.education.fr")\n || shExpMatch(host,"webinaire.numerique.gouv.fr")\n || shExpMatch(host,"*.webinaire.numerique.gouv.fr")\n || shExpMatch(host,"meet.conseil-etat.fr")\n || shExpMatch(host,"ovp.orange-business.com")\n || shExpMatch(host,"openvideopresenceadvanced.orange-business.com")\n || shExpMatch(host,"*.classilio.com")\n || shExpMatch(host,"*.comu.gouv.fr")\n || shExpMatch(host,"teams.events.data.microsoft.com")\n || shExpMatch(host,"teams.live.com")\n || shExpMatch(host,"*.teams.live.com")\n || shExpMatch(host,"*.teams.microsoft.com")\n || shExpMatch(host,"*.trouter.skype.com")\n || shExpMatch(host,"*.relay.skype.com")\n || shExpMatch(host,"api.flightproxy.skype.com")\n) {\n        return "PROXY webconf.proxy.e2.rie.gouv.fr:8080";\n}\n//\n// Sinon en fin qd c est pour internet...\nreturn "PROXY %s";\n\n}\n' "${px}" > "${HOME}"/.proxy.pac
            chmod 0644 "${HOME}"/.proxy.pac
            printf 'Démarrage du service Strongswan\n'
            sudo systemctl restart strongswan
            printf '\nEntrez votre code PIN de carte agent aux 2 demandes de mot de passe qui vont suivre\n\nDéblocage de la carte agent pour le tunnel\n'
            sudo swanctl --load-creds 1> /dev/null
            # if ! sudo swanctl --initiate --child safita_ipsec_child > /dev/null
            if ! sudo swanctl --initiate --child ecureuil_child > /dev/null
            then
              printf '\nProblème lors de l'"'"'établissement du tunnel - ABANDON\n'
              sudo systemctl stop strongswan
              return 1
            fi
            printf '\nRetrait des clés chargées dans l'"'"'agent SSH\n'
            ssh-add -e /usr/lib/in_p11/libidop11.so
            printf '\nAjout des clés de la carte dans l'"'"'agent SSH\n'
            ssh-add -s /usr/lib/in_p11/libidop11.so
            printf '\nAjout des proxies pour le service DOCKER\n'
            sudo bash -c "printf '[Service]\nEnvironment=\"HTTP_PROXY=http://${px}\"\nEnvironment=\"HTTPS_PROXY=http://${px}\"\n' > /etc/systemd/system/docker.service.d/service-env.conf"
            printf '\nAjout des proxies pour git\n'
            git config --global http.proxy "${px}"
            git config --global https.proxy "${px}"
            printf "\nAjout des proxies dans l'environnment\n"
            export http_proxy="http://${px}"
            export https_proxy="http://${px}"
            set -- '1400'
            printf '\nPassage du MTU a %s\n' "${1}"
            sudo ifconfig wlo1 mtu "${1}" up
          fi
          printf '\nRedémarrage du service DOCKER\n'
          sudo systemctl daemon-reload
          sudo systemctl restart docker
          ;;
    'down') if ! command ip route show dev eno1 | grep -E '10.132.0.' > /dev/null
            then
              printf 'Disconnect through IPSEC\n'
              # sudo swanctl -t --ike safita_ipsec >/dev/null
              sudo swanctl -t --ike ecureuil >/dev/null

              pkill -f proxycs
            fi

            printf '\nRetrait des proxies Parisiens\n'
            sudo bash -c "printf '#Acquire::http::Proxy \"http://127.0.0.1:3128\";\n#Acquire::https::Proxy \"http://127.0.0.1:3128\";\n' > /etc/apt/apt.conf.d/99proxy"
            printf 'function FindProxyForURL(url, host){\n  return "DIRECT";\n}\n' > "${HOME}"/.proxy.pac
            chmod 0644 "${HOME}"/.proxy.pac
            printf '\nRetrait du DNS menteur\n'
            sudo bash -c "printf '# Generated by NetworkManager\nsearch edcs.fr\nnameserver 127.0.0.53\n' > /etc/resolv.conf"
            printf '\nRetrait des clés chargées dans l'"'"'agent SSH\n'
            ssh-add -e /usr/lib/in_p11/libidop11.so
            printf '\nArret du service Strongswan\n'
            sudo systemctl stop strongswan
            printf '\nPassage du MTU a 1500\n'
            sudo ifconfig wlo1 mtu 1500 up
            sudo rm -f /etc/systemd/system/docker.service.d/service-env.conf
            printf '\nRedémarrage du service DOCKER\n'
            sudo systemctl daemon-reload
            sudo systemctl restart docker
            unset http_proxy https_proxy
            git config --global --unset https.proxy
            git config --global --unset http.proxy
            ;;
    *) ssh ptomas@bastion"${1}".cs.e2.rie.gouv.fr ;;
    # *) ssh ptomas@bastion"${1}".edcs.fr ;;
    # *) ssh ptomas@bdx.bastion"${1}".edcs.fr ;;
  esac
}

git ()
{
  if [[ ${1} == push ]]
  then
    if command git rev-parse --git-dir > /dev/null 2>&1
    then
      local git_dir
      git_dir="$(command git rev-parse --git-dir)"
      readonly git_dir
      [[ -x ${git_dir}/hooks/pre-push ]] && "${git_dir}"/hooks/pre-push
      shift
      if command git push --no-verify "${@}"
      then
        [[ -x ${git_dir}/hooks/post-push ]] && "${git_dir}"/hooks/post-push
      fi
    else
      return 1
    fi
  else
    command git "${@}"
  fi
}

git config --global --replace-all alias.ranking "!bash -c \"
git_ranking () {
  if [[ \${#} -eq 0 ]]; then
    git ls-files \
      | command xargs -n1 \git blame --line-porcelain | command sed -n 's/^author //p' \
      | command sort -f | command uniq -i -c | command sort -n -r
  else
    git blame --line-porcelain \${*} | command sed -n 's/^author //p' | command sort -f \
      | command uniq -i -c | command sort -n -r
  fi
  echo
  command github-linguist \${*}
}
git_ranking\""

git config --global --replace-all alias.root 'rev-parse --show-toplevel'
git config --global --replace-all alias.clear "!bash -c \"git_clear () { command git reset --hard; command git clean -f -x -d :/; }; git_clear\""

ga () { git add "${@}" && git status -s -uall; }
gaa () { git add -A "${@}" && git status -s -uall; }
gam () { git add -A && git commit -m "${@}"; }
gamp () { git add -A && git commit -m "${@}" && git pull && git push; }
gb () { git branch "${@}"; }
gbd () { git branch -D "${@}"; }
gbm () { git branch -M "${@}"; }
gc () { git clone --recurse-submodules "${@}"; }
gg () { git ranking; }
gk () { git checkout --recurse-submodules "${@}"; }
gkf () { git checkout --recurse-submodules --force "${@}"; }
gm () { git commit -m "${@}"; }
gma () { git commit --amend "${@}"; }
gp () { git push "${@}"; }
gpf () { git push --force origin "${@}"; }
gpp () { git pull "${@}"; }
gr () { git reset --soft HEAD~"${1:-1}"; }
grr () { git restore "${@}"; }
grs () { git restore --staged "${@}"; }
gs () { git status -s -uall; }
gsa () { git stash apply; }
gsd () { git stash drop; }
gsp () { git stash push; }
gsu () { git submodule update --init --recursive --remote; }

du () { command docker compose up -d "${@}"; }
dub () { command docker compose up -d --build "${@}"; }
dd () { command docker compose down "${@}"; }
dls () { command docker ps -a "${@}"; }
dlsi () { command docker image ls "${@}"; }
dlsv () { command docker volume ls "${@}"; }
drm () { command docker rm -f $(command docker ps -a -q); }
drmi () { command docker rmi -f $(command docker images -a -q); }
drmv () { command docker volume rm -f $(command docker volume ls -f dangling=true -q); }
ds () { command docker compose start; }
dt () { if [[ ${dt_USER} ]]; then command docker exec -it --user "${dt_USER}" "${@}"; else command docker exec -it "${@}"; fi; }
dy () { command docker system prune -a -f; }
