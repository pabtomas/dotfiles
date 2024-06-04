#! /bin/sh

## Posix shell: no local variables => subshell instead of braces
## resolve shell templates
templating ()
(
  ## oksh/loksh: debugtrace does not follow in functions
  if [ -n "${DEBUG:-}" ]; then set -x; fi

  cwd="$(CDPATH='' cd -- "$(dirname -- "${0}")" > /dev/null 2>&1; pwd)/.."
  readonly cwd

  generate_variables
  set -a -- "${cwd}"
  . "${cwd}/env.sh"

  ## generate anchors first, then compose files and at the very end, other templates
  for template in "${cwd}/anchors/compose.yaml.in" $(match="${cwd}" find "${cwd}" -type f -name 'compose.yaml.in' -not -path "${cwd}/anchors/*" -printf '%d %p\n' | sort -n -r | cut -d ' ' -f 2) $(match="${cwd}" find "${cwd}" -type f -name '*.in' -not -name '*.yaml.in')
  do
    cat="$(IFS='
'; while read -r line; do printf '%s\n' "${line}"; done < "${template}")"
    eval "printf '%s\\n' \"${cat}\"" > "${template%.*}"
  done

  ## add anchors before each compose.yaml because anchors' YAML can not be shared accross different files:
  ## https://github.com/docker/compose/issues/5621
  # shellcheck disable=2016
  # SC2016: Expressions don't expand in single quotes, use double quotes for that => expansion not needed
  match="${cwd}" find "${cwd}" -type f -name 'compose.yaml' -not -path "${cwd}/anchors/*" -exec sh -c '
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
  ' sh {} "${cwd}" \;
)

templating
