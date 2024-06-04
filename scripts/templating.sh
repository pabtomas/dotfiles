#! /bin/sh

## factorize reusable code
generate_variables ()
{
  API_TAG="$(docker version --format '{{ .Server.APIVersion }}')"
  export API_TAG
}

## Posix shell: no local variables => subshell instead of braces
## resolve shell templates
templating ()
(
  ## oksh/loksh: debugtrace does not follow in functions
  if [ -n "${DEBUG:-}" ]; then set -x; fi

  if [ -n "${1}" ]
  then
    root="${1}"
  else
    root="$(CDPATH='' cd -- "$(dirname -- "${0}")" > /dev/null 2>&1; pwd)/.."
  fi
  readonly root

  generate_variables
  set -a -- "${root}"
  . "${root}/env.sh"

  ## generate anchors first, then compose files and at the very end, other templates
  for template in "${root}/anchors/compose.yaml.in" $(match="${root}" find "${root}" -type f -name 'compose.yaml.in' -not -path "${root}/anchors/*" -printf '%d %p\n' | sort -n -r | cut -d ' ' -f 2) $(match="${root}" find "${root}" -type f -name '*.in' -not -name '*.yaml.in')
  do
    cat="$(IFS='
'; while read -r line; do printf '%s\n' "${line}"; done < "${template}")"
    eval "printf '%s\\n' \"${cat}\"" > "${template%.*}"
  done

  ## add anchors before each compose.yaml because anchors' YAML can not be shared accross different files:
  ## https://github.com/docker/compose/issues/5621
  # shellcheck disable=2016
  # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
  match="${root}" find "${root}" -type f -name 'compose.yaml' -not -path "${root}/anchors/*" -exec sh -c '
    IFS="
"
    while read -r line
    do
      file="${file:-}${file:+
}${line}"
    done < "${2}/anchors/compose.yaml"
    while read -r line
    do
      file="${file:-}${file:+
}${line}"
    done < "${1}"
    printf "%s\n" "${file}" | yq "explode(.)" > "${1}"
  ' sh {} "${root}" \;
)

templating "${@}"
