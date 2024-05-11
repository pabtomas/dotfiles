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

git config --global --replace-all alias.root 'rev-parse --show-toplevel'

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
