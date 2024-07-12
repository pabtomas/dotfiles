#! /usr/bin/env ash

alias not='! '
alias source='. '

eq () { if [ "${1}" = "${2}" ];  then return 0; else return 1; fi; }
gt () { return "$(( ${1} > ${2} ? 0 : 1 ))"; }
lt () { return "$(( ${1} < ${2} ? 0 : 1 ))"; }
ge () { if not lt "${1}" "${2}"; then return 0; else return 1; fi; }
le () { if not gt "${1}" "${2}"; then return 0; else return 1; fi; }

is ()
{
  case "${1}" in
  ( dir )      if [ -d "${2}" ]; then return 0; else return 1; fi ;;
  ( nonempty ) if [ -s "${2}" ]; then return 0; else return 1; fi ;;
  ( present )  if [ -e "${2}" ]; then return 0; else return 1; fi ;;
  ( sym )      if [ -L "${2}" ]; then return 0; else return 1; fi ;;
  esac
}

can ()
{
  case "${1}" in
  ( read ) if [ -r "${2}" ]; then return 0; else return 1; fi ;;
  ( exec ) if [ -x "${2}" ]; then return 0; else return 1; fi ;;
  esac
}

str ()
{
  case "${1}" in
  ( empty )  if [ -z "${2}" ]; then return 0; else return 1; fi ;;
  ( in )     case "${3}" in ( *" ${2} "* ) return 0 ;; ( * ) return 1 ;; esac ;;
  ( join )   eval "${2}=\"\${${2}}\"' ${3}'" ;;
  esac
}

dir ()
{
  local dir min max type success
  case "${1}" in
  ( empty ) dir="${2}"; min='1'; max='1'; success='1' ;;
  esac
  if xtrace_safe "command find '${dir}' ${min:+"-mindepth ${min}"} ${max:+"-maxdepth ${max}"} ${type:+"-type ${type}"} | read dummy || handle_pipefails \"\${?}\""; then return "${success:-0}"; else return "$(( 1 - ${success:-0} ))"; fi
}

# ignore exit code 141 from command pipes when reader exits before writer
handle_pipefails ()
{
  if eq "${1}" '141'; then set -- '0'; fi
  return "${1}"
}

# commands in a same pipe can make xtrace messy
xtrace_safe ()
{
  local status
  if not eval "${1}"; then status='1'; fi
  return "${status:-0}"
} 2> /dev/null

##############################################################################
##################################   RUNNER   ################################
##############################################################################

_send ()
{
  pfx="${buffered:+"${exodia_bufreq}${exodia_reqsep}${pid}${exodia_reqsep}"}${pfx}"
  if str empty "${cat:-}" && eq "${#}" '0'; then sed "s@^@${pfx}@"
  elif str empty "${cat:-}"; then printf -- "${pfx}%b\n" "${@}"
  elif is nonempty "${cat}"; then sed "s@^@${pfx}@" "${cat}"; fi 1>&3;
  unset buffered cat
}

send () { if ge "${exodia_loglevel}" "${lvl}"; then pfx="${lvl}" _send "${@}"; fi; }

send_raw   ()    { pfx="${exodia_rawlevel}"   _send "${@}"; }
send_error ()    { pfx="${exodia_errorlevel}" _send "${@}"; }
send_warn  ()    { lvl="${exodia_warnlevel}"   send "${@}"; }
send_info  ()    { lvl="${exodia_infolevel}"   send "${@}"; }
send_note  ()    { lvl="${exodia_notelevel}"   send "${@}"; }
send_debug ()    { lvl="${exodia_debuglevel}"  send "${@}"; }
send_verb  ()    { lvl="${exodia_verblevel}"   send "${@}"; }

send_flush ()    { printf '%s%s\n' "${exodia_flushreq}" "${pid}" 1>&3; }

send_spin ()     { printf '%s%s%s%s%s\n' "${exodia_spinreq}" "${exodia_reqsep}" "${1}" "${exodia_reqsep}" "${2}" 1>&3; }
send_stop  ()    { printf '%s%s\n' "${exodia_stopreq}" "${1}" 1>&3; }

send_bar ()      { printf '%s%s\n' "${exodia_barreq}" "${1}" 1>&3; }
send_progress () { printf '%s\n' "${exodia_progreq}" 1>&3; }

help ()
{
  set -f
  IFS=$'\n'
  send_raw 'A Docker Engine orchestrator'                                      \
           ''                                                                  \
           'Usage:'                                                            \
           '  exodia [options] [rules]'                                        \
           ''                                                                  \
           'Rules:'                                                            \
           $(yq '.rules as $rules | $rules[] | "  " + key + " " + (" " * (([$rules[] | key | length] | max) - (key | length))) + "- " + .description' "${exodia_cache_rendered}") \
           ''                                                                  \
           'Options:'                                                          \
           '  -f, --file file       exodia main file (default: ./exodia.yaml)' \
           '  -r, --reset-cache     reset the cache'                           \
           '  -q                    reduce log level, reusable 2 times'        \
           '  -v                    increase log level, reusable 4 times'      \
           '  -h, --help            help for exodia'                           \
           '  -V, --version         version for exodia'
  IFS="${exodia_ifs}"
  set +f
  return 1
}

version ()
{
  send_raw 'exodia 0.1.0'
  return 1
}

help_option ()
{
  exodia_help='true'
}

version_option ()
{
  exodia_version='true'
}

reset_cache_option ()
{
  exodia_resetcache='true'
}

file_option ()
{
  if not is present "${1}"
  then
    send_error "${1} does not exist"
    return 1
  elif not can read "${1}"
  then
    send_error "You do not have the permission to read ${1}"
    return 1
  fi
  exodia_file="${1}"
}

q_option ()
{
  if eq "${exodia_ignore_qopt:-}" 'true'; then return 0; fi
  if le "${exodia_loglevel:-"${exodia_infolevel}"}" "${exodia_infolevel}" && gt "${exodia_loglevel:-"${exodia_infolevel}"}" "${exodia_errorlevel}"
  then exodia_loglevel="$(( ${exodia_loglevel:-"${exodia_infolevel}"} - 1 ))"
  elif eq "${exodia_loglevel:-"${exodia_infolevel}"}" "${exodia_errorlevel}"
  then exodia_loglevel="${exodia_warnlevel}" send_warn '-q can not be used more than 2 times'; exodia_ignore_qopt='true'
  else send_error '-q and -v options can not be combined'; return 1; fi
}

v_option ()
{
  if eq "${exodia_ignore_vopt:-}" 'true'; then return 0; fi
  if ge "${exodia_loglevel:-"${exodia_infolevel}"}" "${exodia_infolevel}" && lt "${exodia_loglevel:-"${exodia_infolevel}"}" "${exodia_verblevel}"
  then exodia_loglevel="$(( ${exodia_loglevel:-"${exodia_infolevel}"} + 1 ))"
  elif eq "${exodia_loglevel:-"${exodia_infolevel}"}" "${exodia_verblevel}"
  then send_warn '-v can not be used more than 4 times'; exodia_ignore_vopt='true'
  else send_error '-q and -v options can not be combined'; return 1; fi
}

add_rule ()
{
  exodia_userrules="${exodia_userrules:-}${1} "
}

unknown_option ()
{
  send_error "Unknown rule/option: '${1}'"
  return 1
}

parse_options ()
{
  until eq "${#}" '0'
  do
    case "${1}" in

    # Handle '-abc' the same as '-a -bc' for short-form no-arg options
    ( -[hrqvV]?* )
      IFS=' '
      set -f
      set -- "${1%"${1#??}"}" "-${1#??}" $(shift; printf '%s\n' "${@}")
      set +f
      IFS="${exodia_ifs}"
      continue ;;

    # Handle '-foo' the same as '-f oo' for short-form 1-arg options
    ( -[f]?* )
      IFS=' '
      set -f
      set -- "${1%"${1#??}"}" "${1#??}" $(shift; printf '%s\n' "${@}")
      set +f
      IFS="${exodia_ifs}"
      continue ;;

    # Handle '--file=file1' the same as '--file file1' for long-form 1-arg options
    ( --file=* )
      IFS=' '
      set -f
      set -- "${1%%=*}" "${1#*=}" $(shift; printf '%s\n' "${@}")
      set +f
      IFS="${exodia_ifs}"
      continue ;;

    ( -r|--reset-cache ) reset_cache_option        ;;
    ( -f|--file )        file_option "${2}"; shift ;;
    ( -q )               q_option                  ;;
    ( -v )               v_option                  ;;
    ( -h|--help )        help_option               ;;
    ( -V|--version )     version_option            ;;
    ( * )                add_rule "${1}"           ;;
    esac
    shift
  done

  unset exodia_ignore_qopt exodia_ignore_vopt
}

prepare_curl ()
{
  exodia_curlreqheader='http:/'
  exodia_curlresp="${EXODIA_RUN_PATH}/curlresponse.json"
  exodia_curlopts="${exodia_curlopts:+"${exodia_curlopts:-}" }--silent --write-out %{http_code} --output ${exodia_curlresp}"

  if str empty "${DOCKER_HOST:-}"
  then exodia_curlopts="${exodia_curlopts:+"${exodia_curlopts}" }--unix-socket /var/run/docker.sock"
  else exodia_curlreqheader="${exodia_curlreqheader}/${DOCKER_HOST#*://}"; fi

  readonly exodia_curlreqheader exodia_curlresp exodia_curlopts
}

verbose_mode ()
{
  coreutils ()
  {
    local prog
    prog="${1}"
    shift
    case "${prog}" in
    ( *=cp|*=mkdir|*=mv|*=rm ) if not command coreutils "${prog}" -v "${@}" 2>&1 | send_verb; then return 1; fi ;;
    ( * ) if not command coreutils "${prog}" "${@}"; then return 1; fi ;;
    esac
  } 2> /dev/null
  find () { if not command find -D exec -D search "${@}"; then return 1; fi; } 2> /dev/null
  yq () { if not command yq -v -M "${@}"; then return 1; fi; } 2> /dev/null
  gomplate () { if not command gomplate -V "${@}"; then return 1; fi; } 2> /dev/null
  exodia_mkdiropts='-v'
  readonly exodia_mkdiropts
}

prepare_logging ()
{
  if ge "${exodia_loglevel}" "${exodia_tracelevel}"; then set -x; fi
  if ge "${exodia_loglevel}" "${exodia_debuglevel}"; then exodia_curlopts='--verbose'; fi
  if ge "${exodia_loglevel}" "${exodia_verblevel}"; then verbose_mode; fi
}

prepare ()
{
  exodia_file="${exodia_file:-exodia.yaml}"
  exodia_file_abs="${PWD}/${exodia_file}"
  exodia_loglevel="${exodia_loglevel:-"${exodia_infolevel}"}"

  send_note "Main file found: ${exodia_file}"

  # total = nproc + 1 - listener - logger - runner
  exodia_nproc="$(( $(nproc --all) - 2 ))"

  readonly exodia_resetcache exodia_file exodia_file_abs exodia_loglevel exodia_help exodia_version exodia_userrules exodia_nproc

  prepare_logging
  prepare_curl
}

reset_buffer ()
{
  read -r pid < /proc/self/stat
  pid="${pid%% *}"
  coreutils --coreutils-prog=rm -rf "${exodia_run_buffers}/${pid}"
  coreutils --coreutils-prog=mkdir -p "${exodia_run_buffers}/${pid}"
  stderr="${exodia_run_buffers}/${pid}/0"
  readonly pid
}

_curl ()
{
  local pid stderr out
  reset_buffer
  readonly req

  if not out="$(set -f; curl ${exodia_curlopts} --stderr "${stderr}" "${@}" "${req}")"
  then
    buffered='true' send_error "'${req}' HTTP response: ${out}"
    if is nonempty "${stderr}"
    then buffered='true' cat="${stderr}" send_error; fi
    send_flush
    return 1
  fi

  if not eq "${out%"${out#?}"}" '2'
  then
    buffered='true' send_warn "'${req}' HTTP response: ${out}"
    send_flush
  fi

  if is nonempty "${stderr}"
  then
    buffered='true' send_debug '[CURL] HTTP exchange between Exodia and Docker Engine:'
    buffered='true' cat="${stderr}" send_debug
    buffered='true' send_debug '[CURL] JSON response from Docker Engine:'
    xtrace_safe "command yq -M -p 'json' -o 'json' ${exodia_curlresp} | buffered='true' send_debug"
    send_flush
  fi
}

_find ()
{
  local pid stderr
  reset_buffer

  if not find "${@}" 2> "${stderr}" 1>&"${fd:-1}"
  then
    if is nonempty "${stderr}"
    then cat="${stderr}" send_error; fi
    return 1
  elif lt "${exodia_loglevel}" "${exodia_verblevel}" && is nonempty "${stderr}"
  then cat="${stderr}" send_warn
  elif is nonempty "${stderr}"
  then cat="${stderr}" send_verb; fi
}

_yq ()
{
  local pid stderr
  reset_buffer

  if not yq -M "${@}" 2> "${stderr}"
  then
    if is nonempty "${stderr}"
    then
      send_error 'The YAML parser failed with this error:'
      cat="${stderr}" send_error
    else send_error 'The YAML parser failed'; fi
    return 1
  elif lt "${exodia_loglevel}" "${exodia_verblevel}" && is nonempty "${stderr}"
  then
    send_warn 'The YAML parser succeed but returns this warning:'
    cat="${stderr}" send_warn
  elif is nonempty "${stderr}"
  then cat="${stderr}" send_verb; fi
}

_gom ()
{
  local pid stderr
  reset_buffer

  if not gomplate "${@}" 2> "${stderr}"
  then
    if is nonempty "${stderr}"
    then
      send_error 'The Golang Template processor failed with this error:'
      xtrace_safe "command yq -M -p 'json' -o 'json' ${stderr} | send_error"
    else send_error 'The Golang Template processor failed'; fi
    return 1
  elif lt "${exodia_loglevel}" "${exodia_verblevel}" && is nonempty "${stderr}"
  then
    send_warn 'The Golang Template processor succeed but returns this warning:'
    xtrace_safe "command yq -M -p 'json' -o 'json' ${stderr} | send_warn"
  elif is nonempty "${stderr}"
  then xtrace_safe "command yq -M -p 'json' -o 'json' ${stderr} | send_verb"; fi
}

add_filters ()
{
  # map each datasource as a variable in Golang templates
  exodia_filter_write_datasources_header='[.datasources[] | "{{ $" + .id + " := index (datasource \"header\") \"" + .source + "\" }}"]' \
  # add INFO & VERSION special variables
  str join exodia_filter_write_datasources_header '+ ["{{ $INFO := (datasource \"info\") }}{{ $VERSION := (datasource \"version\") }}"]' \
  # join to remove new lines without tr
  str join exodia_filter_write_datasources_header '| join("")'

  exodia_filter_expand_datasources_into_datasources='(..'
  # escape keys
  str join exodia_filter_expand_datasources_into_datasources '| key = "{{ print \"" + key + "\" }}"'
  # add datasources as variables at the top of the file
  str join exodia_filter_expand_datasources_into_datasources '| (select((key | line) == 1) | key = (load_str("'"${exodia_cache_header}"'") | trim) + key)) |= .'

  exodia_filter_expand_datasources_into_main='(..'
  # escape keys
  str join exodia_filter_expand_datasources_into_main '| key = "{{ print \"" + key + "\" }}") |= .'
  # select recursively values into rules[].run[] array
  str join exodia_filter_expand_datasources_into_main '| ((select(has("{{ print \"rules\" }}")) | .["{{ print \"rules\" }}"][]) |='
  str join exodia_filter_expand_datasources_into_main '(select(has("{{ print \"run\" }}")) | .["{{ print \"run\" }}"]) |='
  str join exodia_filter_expand_datasources_into_main '(.. | select(type == "!!str") |= (.'
  # escape backslashes and double quotes characters
  str join exodia_filter_expand_datasources_into_main '| sub("\\\\", "\\\\") | sub("\"", "\\\"")'
  # split on new line because Golang templates annotations are onelined
  str join exodia_filter_expand_datasources_into_main '| split("\n") | .[] |='
  # escape each line of the value
  str join exodia_filter_expand_datasources_into_main '"{{ print \"" + (. | select(. | length > 0)) + "\" }}"'
  # then join everything again with removed new lines
  str join exodia_filter_expand_datasources_into_main '| join("\n"))))'

  exodia_filter_explode_extern_anchors='.explode[] | .in as $in'
  # load files where extern anchors are defined, remove trailing --- and ..., and join them as a string
  str join exodia_filter_explode_extern_anchors '| ([(.anchors[] | load_str(.) | trim | sub("^---", "") | sub("\.\.\.$", "") | trim)] | join("\n")) + "\n" +'
  # load file where extern anchors are needed as a string, remove trailing --- and ..., and concat it to the previous string
  str join exodia_filter_explode_extern_anchors '(load_str(.in) | trim | sub("^---", "") | sub("\.\.\.$", "") | trim)'
  # parse the string result and evaluate it as YAML content
  str join exodia_filter_explode_extern_anchors '| @yamld'
  # explode extern aliases
  str join exodia_filter_explode_extern_anchors '| explode(.) | .[] |='
  # delete unnecessary keys
  str join exodia_filter_explode_extern_anchors 'del(select(key != "rules" and key != "include"))'
  # needed to split the exploded content into separated files
  str join exodia_filter_explode_extern_anchors '| . * {"file": $in}'

  exodia_filter_resolve_includes='explode(.)'
  # workaround to re-evaluate the result of the last filter
  str join exodia_filter_resolve_includes '| @yaml | @yamld'
  # escape keys
  str join exodia_filter_resolve_includes '| (.. | key = "{{ print \"" + key + "\" }}") |= .'
  # select recursively values into rules[].run[] array
  str join exodia_filter_resolve_includes '| ((select(has("{{ print \"rules\" }}")) | .["{{ print \"rules\" }}"][]) |='
  str join exodia_filter_resolve_includes '(select(has("{{ print \"run\" }}")) | .["{{ print \"run\" }}"]) |='
  str join exodia_filter_resolve_includes '(.. | select(type == "!!str") |='
  # escape backslashes and double quotes characters
  str join exodia_filter_resolve_includes '(. | sub("\\\\", "\\\\") | sub("\"", "\\\"")'
  # split on new line because Golang templates annotations are onelined
  str join exodia_filter_resolve_includes '| split("\n") | .[] |='
  # escape each line of the value
  str join exodia_filter_resolve_includes '"{{ print \"" + (. | select(. | length > 0)) + "\" }}"'
  # then join everything again with removed new lines
  str join exodia_filter_resolve_includes '| join("\n"))))'

  # remove unnecessary fields
  exodia_filter_convert_to_objects='| (del(.[] | select(key != "versions" and key != "rules"))'
  # escape keys
  str join exodia_filter_convert_to_objects '| (.. | key = "{{ print \"" + key + "\" }}") |='
  # select keys different of `id`, `depends_on` and `extends`
  str join exodia_filter_convert_to_objects 'select(type == "!!str" and key != "{{ print \"id\" }}"'
  str join exodia_filter_convert_to_objects 'and parent | key != "{{ print \"extends\" }}"'
  str join exodia_filter_convert_to_objects 'and parent | key != "{{ print \"depends_on\" }}") |='
  # escape backslashes and double quotes characters
  str join exodia_filter_convert_to_objects '(. | sub("\\\\", "\\\\") | sub("\"", "\\\"")'
  # split on new line because Golang templates annotations are onelined
  str join exodia_filter_convert_to_objects '| split("\n") | .[] |='
  # escape each line of the value
  str join exodia_filter_convert_to_objects '"{{ print \"" + (. | select(. | length > 0)) + "\" }}"'
  # then join everything again with removed new lines
  str join exodia_filter_convert_to_objects '| join("\n")))'
  # convert rules[] array into an object
  str join exodia_filter_convert_to_objects '| ((.["{{ print \"rules\" }}"] |= (.[] as $i ireduce({}; . *+ {$i.["{{ print \"id\" }}"]: ($i | del(.["{{ print \"id\" }}"]))})))'
  # before converting it as an object: into rules[].run[] array:
  str join exodia_filter_convert_to_objects '|   .["{{ print \"rules\" }}"][].["{{ print \"run\" }}"] |= (.[] as $i ireduce([]; .'
  # copy rules[].run[].from.id to rules[].run[].id
  str join exodia_filter_convert_to_objects '+ [$i + {"{{ print \"id\" }}": $i.["{{ print \"from\" }}"].["{{ print \"id\" }}"]}'
  # copy rules[].run[].from.depends_on to rules[].run[].depends_on
  str join exodia_filter_convert_to_objects '+ {"{{ print \"depends_on\" }}": $i.["{{ print \"from\" }}"].["{{ print \"depends_on\" }}"] // []}'
  # delete rules[].run[].from.id and rules[].run[].from.depends_on
  str join exodia_filter_convert_to_objects '| del(.["{{ print \"from\" }}"].["{{ print \"id\" }}"]) | del(.["{{ print \"from\" }}"].["{{ print \"depends_on\" }}"])]'
  # move rules[].run[].register.id to rules[].run[].id
  str join exodia_filter_convert_to_objects '+ [$i + {"{{ print \"id\" }}": $i.["{{ print \"register\" }}"].["{{ print \"id\" }}"]}'
  # copy rules[].run[].register.depends_on to rules[].run[].depends_on
  str join exodia_filter_convert_to_objects '+ {"{{ print \"depends_on\" }}": $i.["{{ print \"register\" }}"].["{{ print \"depends_on\" }}"] // []}'
  # delete rules[].run[].register.id and rules[].run[].register.depends_on
  str join exodia_filter_convert_to_objects '| del(.["{{ print \"register\" }}"].["{{ print \"id\" }}"]) | del(.["{{ print \"register\" }}"].["{{ print \"depends_on\" }}"])]'
  # convert rules[].run[].loop[] array into an object
  str join exodia_filter_convert_to_objects '+ [$i | (.["{{ print \"loop\" }}"][] + ($i | del(.["{{ print \"loop\" }}"])))]))'
  # convert rules[].run[] array into an object
  str join exodia_filter_convert_to_objects '|   .["{{ print \"rules\" }}"][].["{{ print \"run\" }}"] |= (.[] as $i ireduce({}; . *+ {$i.["{{ print \"id\" }}"]: ($i | del(.["{{ print \"id\" }}"]))})))'

  exodia_filter_expand_extends='. as $root | .rules[].run |= .[] |= ((select(.extends | length > 0) | .extends[] as $id ireduce({}; $root.rules[].run[$id] as $extend'
  # from an other Body, the extended Body will inherit these attributes: `query`, `path`, `context` (and `depends_on` for virtual)
  str join exodia_filter_expand_extends '| .depends_on = (.depends_on *+ ($extend | select(.virtual) | .depends_on))'
  str join exodia_filter_expand_extends '| .query = (.query * $extend.query)'
  str join exodia_filter_expand_extends '| .path = (.path * $extend.path)'
  str join exodia_filter_expand_extends '| .context = $extend.context)) *+ . | del(.extends))'
  # remove virtuals
  str join exodia_filter_expand_extends '| .rules.[].run[] |= (select(.virtual) | del(.))'

  readonly exodia_filter_write_datasources_header exodia_filter_expand_datasources_into_datasources exodia_filter_expand_datasources_into_main exodia_filter_expand_datasources_into_datasources exodia_filter_resolve_includes exodia_filter_convert_to_objects exodia_filter_expand_extends
}

prepare_cache ()
{
  add_filters

  coreutils --coreutils-prog=mkdir -p "${exodia_cache_context}" "${exodia_cache_datasources}" "${exodia_cache_explode}" "${exodia_cache_include}" "${exodia_cache_neighbors}" "${exodia_cache_topological}"

  send_note 'Preprocessing: Cache prepared'
}

explode_main_file ()
{
  _yq 'explode(.)' "${exodia_file}" > "${exodia_cache_rendered}"
  send_note "Preprocessing: Anchors into ${exodia_file} exploded"
}

build_request ()
{
  printf '%s/v%s%s\n' "${exodia_curlreqheader}" "${exodia_apiversion:-1.25}" "${1}"
}

get ()
{
  req="$(build_request "${req}")" _curl --request GET "${@}"
}

define_context_datasources ()
{
  req='/version' get
  coreutils --coreutils-prog=mv -f "${exodia_curlresp}" "${exodia_cache_version_json}"

  exodia_apiversion="$(_gom --datasource "version=${exodia_cache_version_json}" --in '{{ (datasource "version").ApiVersion }}')"
  req='/version' get
  coreutils --coreutils-prog=mv -f "${exodia_curlresp}" "${exodia_cache_version_json}"

  req='/info' get
  coreutils --coreutils-prog=mv -f "${exodia_curlresp}" "${exodia_cache_info_json}"

  send_note 'Preprocessing: Context datasources defined'
}

write_datasources_header ()
{
  _yq "${exodia_filter_write_datasources_header}" "${exodia_cache_rendered}" > "${exodia_cache_header}"
  send_note 'Preprocessing: Datasources header written'
}

expand_datasources_into_datasources ()
{
  local datasources last shas
  datasources="$(_yq '[.datasources[].source] | join(" ")' "${exodia_cache_rendered}")"
  _yq -i 'del(.datasources)' "${exodia_cache_rendered}"

  set -f
  # gather datasources into one 1 file
  _yq -N '{filename: explode(.)} | ... style="single"' ${datasources} > "${exodia_cache_datasources}/0.yaml"
  set +f

  last="$(sha256sum "${exodia_cache_datasources}/0.yaml")"

  until eq "${shas:+"${shas##* }"}" "${last}"
  do
    i="$(( ${i:-0} + 1 ))"
    shas="${shas:+"${shas}" }${last}"

    _yq "${exodia_filter_expand_datasources_into_datasources}" "${exodia_cache_datasources}/$(( ${i} - 1 )).yaml" > "${exodia_cache_datasources}/${i}.gom.yaml"
    _gom --datasource "header=${exodia_cache_datasources}/$(( ${i} - 1 )).yaml" --datasource "info=${exodia_cache_info_json}" --datasource "version=${exodia_cache_version_json}" --file "${exodia_cache_datasources}/${i}.gom.yaml" --out "${exodia_cache_datasources}/${i}.yaml"

    last="$(sha256sum "${exodia_cache_datasources}/${i}.yaml")"
    last="${last%% *}"
  done

  if rg -q "^\s*'[^']+'\s*:\s*'[^'{]*\{\{[^'}]*\}\}.*'" "${exodia_cache_datasources}/${i}.yaml"
  then send_error 'Circular Golang template reference detected into datasources'; return 1; fi

  coreutils --coreutils-prog=cp -f "${exodia_cache_datasources}/${i}.yaml" "${exodia_cache_dsrendered}"

  send_note 'Preprocessing: Datasources fully expanded'
}

expand_datasources_into_main ()
{
  # cp is necessary because header content is not valid YAML content (yq will return an error)
  coreutils --coreutils-prog=cp -f "${exodia_cache_header}" "${exodia_cache_escaped}"

  _yq "${exodia_filter_expand_datasources_into_main}" "${exodia_cache_rendered}" >> "${exodia_cache_escaped}"
  _gom --datasource "header=${exodia_cache_dsrendered}" --datasource "info=${exodia_cache_info_json}" --datasource "version=${exodia_cache_version_json}" --file "${exodia_cache_escaped}" --out "${exodia_cache_rendered}"

  send_note "Preprocessing: Datasources expanded into ${exodia_file}"
}

explode_extern_anchors ()
{
  # copy the filetree of the project
  set -f
  fd='2' _find "$(dirname -- "${exodia_file}")" -mindepth 1 -not -path '*/.*' -type d -exec coreutils --coreutils-prog=mkdir ${exodia_mkdiropts:-} -p "${exodia_cache_explode}/"{} \;
  set +f

  _yq "${exodia_filter_explode_extern_anchors}" -s "\"${exodia_cache_explode}/\" + .file" "${exodia_cache_rendered}"

  # needed because the previous yq execution use the rendered.yaml content to build new files.
  # An other call is needed to edit rendered.yaml with its own content
  _yq -i 'del(.explode)' "${exodia_cache_rendered}"

  send_note 'Preprocessing: Extern anchors exploded'
}

# TODO: refactoring
resolve_includes ()
{
  if eq "${#}" '0'
  then
    coreutils --coreutils-prog=rm -rf "${exodia_cache_include}/"*
    coreutils --coreutils-prog=cp -f "${exodia_cache_rendered}" "${exodia_cache_include}/exodia.yaml"
  fi

  # use `set` instead of `local` for recursive functions is safer
  set -- "${1:-"${exodia_cache_include}/exodia.yaml"}" "$(dirname -- "${1:-"${exodia_cache_include}/exodia.yaml"}")" "${PWD}"
  cd "${2}"
  set -- "${1}" "$(coreutils --coreutils-prog=realpath -s --relative-to="${exodia_cache_include}" "${2}")" "${3}"
  local file yq_in
  for file in $(_yq '.include[]' "${1}")
  do
    coreutils --coreutils-prog=mkdir -p "$(dirname -- "${file}")"
    if is present "${exodia_cache_include}/${2}/${file}"
    then send_error "Circular include detected into ${1} for ${file}"; return 1; fi
    if is present "${exodia_cache_explode}/${2}/${file}"
    then yq_in="${exodia_cache_explode}/${2}/${file}"
    else yq_in="$(dirname -- "${exodia_file_abs}")/${2}/${file}"; fi
    coreutils --coreutils-prog=cp -f "${exodia_cache_header}" "${exodia_cache_include}/${2}/${file}.gom"

    _yq "${exodia_filter_resolve_includes}" "${yq_in}" >> "${exodia_cache_include}/${2}/${file}.gom"
    _gom --datasource "header=${exodia_cache_dsrendered}" --datasource "info=${exodia_cache_info_json}" --datasource "version=${exodia_cache_version_json}" --file "${exodia_cache_include}/${2}/${file}.gom" --out "${exodia_cache_include}/${2}/${file}"

    resolve_includes "${exodia_cache_include}/${2}/${file}"

    send_note "Preprocessing: Datasources expanded into ${2}/${file}"
  done
  cd "${3}"
}

convert_to_objects ()
{
  local load includes

  includes="$(_find "${exodia_cache_include}" -type f -not -name *.gom -not -name exodia.yaml -printf '%p ')"
  if not str empty "${includes}"; then load="$(set -f; printf ' *+ load("%s")' ${includes})"; fi

  # cp is necessary because header content is not valid YAML content (yq will return an error)
  coreutils --coreutils-prog=cp -f "${exodia_cache_header}" "${exodia_cache_escaped}"

  _yq ". ${load:-}${exodia_filter_convert_to_objects}" "${exodia_cache_rendered}" >> "${exodia_cache_escaped}"
  _gom --datasource "header=${exodia_cache_dsrendered}" --datasource "info=${exodia_cache_info_json}" --datasource "version=${exodia_cache_version_json}" --file "${exodia_cache_escaped}" --out "${exodia_cache_rendered}"

  send_note 'Preprocessing: YAML arrays converted into objects'
}

expand_extends ()
{
  _yq -i "${exodia_filter_expand_extends}" "${exodia_cache_rendered}"
  send_note 'Preprocessing: Extends expanded'
}

topological_sort ()
{
  exodia_rules="$(_yq '.rules | keys | join(" ")' "${exodia_cache_rendered}")"

  local rule sorted absrule queue
  for rule in ${exodia_rules}
  do
    sorted=''
    absrule="${exodia_cache_neighbors}/${rule}"
    set -f
    coreutils --coreutils-prog=mkdir -p $(_yq '.rules["'"${rule}"'"].run[] | "'"${absrule}/"'" + key' "${exodia_cache_rendered}")
    set +f
    _yq '.rules["'"${rule}"'"].run[] | "'"${absrule}/"'" + key + "/" + .depends_on[] + ".yaml"' -s '.' "${exodia_cache_rendered}"
    queue="$(_find "${absrule}" -mindepth 1 -maxdepth 1 -type d -empty -delete -printf '%P ')"

    until str empty "${queue:-}"
    do
      sorted="${sorted:+"${sorted} "}${queue%% *}"
      queue="${queue#* }"
      queue="${queue#"${queue%%[![:space:]]*}"}"
      if not dir empty "${absrule}"
      then
        coreutils --coreutils-prog=rm -f "${absrule}"/*/"${sorted##* }.yaml"
        queue="${queue}$(_find "${absrule}" -mindepth 1 -maxdepth 1 -type d -empty -delete -printf '%P ')"
      fi
    done

    if not dir empty "${absrule}"; then send_error 'Circular dependencies detected'; return 1; fi

    printf '%s\n' "${sorted}" > "${exodia_cache_topological}/${rule}"
    send_note "Preprocessing: [${rule}] Topological sort succeed"
  done
}

generate_rules ()
{
  # TODO: here a simplified version of the YQ filter for development purposes

  local random mod
  random="[$(shuf -n15 -r -i1-5 | tr '\n' ',')]"
  mod="$(shuf -n1 -i5-15)"
  export random mod
  _yq 'env(random) as $rd | . as $root | ($root.rules | keys | keys | .[]) as $index | ($root.rules | keys | .[$index]) as $rule_id | $root.rules.[$rule_id] as $rule | $rule.run | "exodia_" + $index + " ()\n{\n  {\n    local pid\n    read -r pid < /proc/self/stat\n    pid=\"${pid%% *}\"\n    PS4=\"${exodia_bufreq}${exodia_reqsep}${pid}${exodia_reqsep}${PS4}\"\n  } 2> /dev/null\n  case \"${1}\" in\n" + ([$rule.run[] | "  ( \"" + key + "\" )\n    send_spin \"" + key + "\" \"[" + $rule_id + "] " + key + " ...\"\n" + (([.depends_on[] | "is present \"${exodia_run_rules}/" + $rule_id + "/" + . + "\""] | join(" && \\n          ") | select(. | length > 0) | "    until " + . + "\n    do usleep 10; done\n") // "") + ("    sleep " + $rd[line % env(mod)] + "\n") + "    : > \"${exodia_run_rules}/" + $rule_id + "/" + key + "\"\n    send_stop \"" + key + "\"\n    send_info \"[" + $rule_id + "] " + key + " succeed\" ;;" ] | join("\n")) + "\n  ( * ) ;;\n  esac\n  send_progress\n  {\n    PS4=\"${exodia_tracelevel}\"\n    send_flush\n  } 2> /dev/null\n}"' "${exodia_cache_rendered}" > "${exodia_cache_rules}"

  send_note "Preprocessing: Rules shell script generated"
}

not_cached ()
{
  if eq "${exodia_resetcache:-}" 'true' || not is present "${exodia_run_done}"; then return 0; else return 1; fi
}

init_runner ()
{
  exec 3>&2
  coreutils --coreutils-prog=rm -r -f "${EXODIA_RUN_PATH}/"*
  coreutils --coreutils-prog=mkdir -p "${exodia_cache}" "${exodia_run_buffers}"
}

preprocess ()
{
  if not_cached
  then
    # TODO: use cache when failure: do not compute the cache again
    send_spin 'cache' 'Preprocessing ...'
    prepare_cache
    explode_main_file
    define_context_datasources
    write_datasources_header
    expand_datasources_into_datasources
    expand_datasources_into_main
    explode_extern_anchors
    resolve_includes
    convert_to_objects
    expand_extends
    topological_sort
    generate_rules
    send_stop 'cache'
    send_info 'Preprocessing succeed'
  fi
}

njobs ()
{
  # `jobs -p` keeps finished jobs into its list, `jobs` refreshes this list
  jobs > /dev/null
  jobs -p > "${exodia_run_ppid}"
  rg -c '\w+' "${exodia_run_ppid}" > "${exodia_run_njobs}"
  read -r n < "${exodia_run_njobs}"
}

# GNU parallel can not be used with unexported functions. Dash does not have this
# feature so we have to make our own parallel utility
parallel ()
{
  # TODO: fix -vvv with parallel
  { "${@}" & } 2> /dev/null
  #"${@}" || { send_error "ID failed"; kill -s INT 0; } &

  local n
  njobs
  if ge "${n}" "${exodia_nproc}"; then wait -n; fi
}

run ()
{
  # current CLI:
  # CWD="${PWD}" ./exodia -v up

  local sort id
  if not str empty "${exodia_help:-}"; then help
  elif not str empty "${exodia_version:-}"; then version
  elif str empty "${exodia_userrules:-}"
  then send_error 'Missing rule'; return 1
  else
    IFS=' '
    set -f
    set -- ${exodia_userrules:-}
    set +f
    IFS="${exodia_ifs}"
    until eq "${#}" '0'
    do
      case " ${exodia_rules:-} " in
      ( *" ${1} "* )
        source "${exodia_cache_rules}"
        coreutils --coreutils-prog=rm -rf "${exodia_run_rules}"
        coreutils --coreutils-prog=mkdir -p "${exodia_run_rules}/${1}"
        read -r sort < "${exodia_cache_topological}/${1}"
        send_bar "${1}"
        set -f
        for id in ${sort}
        do
          parallel "exodia_$(_yq '. as $root | $root.rules | keys | keys | .[] as $index ireduce({}; . + { ($root.rules | keys | .[$index]): $index }) | .["'"${1}"'"]' "${exodia_cache_rendered}")" "${id}"
        done
        set +f ;;
      ( * ) unknown_option "${1}" ;;
      esac
      shift
    done
  fi
}

runner ()
{
  init_runner
  parse_options "${@}"
  prepare
  preprocess
  run
}

##############################################################################
###################################   MAIN   #################################
##############################################################################

add_style ()
{
  exodia_esc="$(printf '\033')"
  exodia_orange="${exodia_esc}[38;5;215m"
  exodia_bold="${exodia_esc}[1m"
  exodia_reset="${exodia_esc}[m"

  readonly exodia_orange exodia_bold exodia_reset
}

fatal ()
{
  printf '%b%bFATAL%b %s\n' "${exodia_orange}" "${exodia_bold}" "${exodia_reset}" "${1}" | ts '%T'
}

add_logger_reqchars ()
{
  exodia_rawlevel='-'
  exodia_errorlevel='0'
  exodia_warnlevel='1'
  exodia_infolevel='2'
  exodia_notelevel='3'
  exodia_debuglevel='4'
  exodia_tracelevel='5'
  exodia_verblevel='6'
  exodia_spinreq='S'
  exodia_stopreq='K'
  exodia_bufreq='B'
  exodia_flushreq='F'
  exodia_barreq='P'
  exodia_progreq='p'
  exodia_reqsep=$'\7'
  readonly exodia_rawlevel exodia_errorlevel exodia_warnlevel exodia_infolevel exodia_notelevel exodia_debuglevel exodia_tracelevel exodia_verblevel \
           exodia_spinreq exodia_stopreq exodia_bufreq exodia_flushreq exodia_reqsep exodia_barreq exodia_progreq
}

add_cache ()
{
  EXODIA_CACHE_PATH="${EXODIA_CACHE_PATH:-/var/cache/exodia}"
  exodia_sha="$(find . -type f -not -path '*/.*' -exec sha256sum {} \; | sha256sum)"
  exodia_sha="${exodia_sha%% *}"
  exodia_cache="${EXODIA_CACHE_PATH}/${exodia_sha}"

  exodia_cache_escaped="${exodia_cache}/escaped.yaml"
  exodia_cache_rendered="${exodia_cache}/rendered.yaml"

  exodia_cache_context="${exodia_cache}/context"
  exodia_cache_version_json="${exodia_cache_context}/version.json"
  exodia_cache_info_json="${exodia_cache_context}/info.json"

  exodia_cache_datasources="${exodia_cache}/datasources"
  exodia_cache_header="${exodia_cache_datasources}/header"
  exodia_cache_dsrendered="${exodia_cache_datasources}/rendered.yaml"

  exodia_cache_explode="${exodia_cache}/explode"

  exodia_cache_include="${exodia_cache}/include"

  exodia_cache_neighbors="${exodia_cache}/neighbors"
  exodia_cache_topological="${exodia_cache}/topological"

  exodia_cache_rules="${exodia_cache}/rules.sh"

  readonly EXODIA_CACHE_PATH exodia_sha exodia_cache \
           exodia_cache_escaped exodia_cache_rendered \
           exodia_cache_context exodia_cache_version_json exodia_cache_info_json \
           exodia_cache_datasources exodia_cache_header exodia_cache_dsrendered \
           exodia_cache_explode \
           exodia_cache_include \
           exodia_cache_neighbors exodia_cache_topological \
           exodia_cache_rules
}

add_run ()
{
  EXODIA_RUN_PATH="${EXODIA_RUN_PATH:-/var/run/exodia}"
  exodia_run_stop="${EXODIA_RUN_PATH}/stop"
  exodia_run_buffers="${EXODIA_RUN_PATH}/buffers"
  exodia_run_ppid="${EXODIA_RUN_PATH}/ppid"
  exodia_run_njobs="${EXODIA_RUN_PATH}/njobs"
  exodia_run_rules="${EXODIA_RUN_PATH}/rules"
  exodia_run_done="${EXODIA_RUN_PATH}/done"

  readonly EXODIA_RUN_PATH exodia_run_stop exodia_run_buffers exodia_run_ppid exodia_run_njobs exodia_run_rules exodia_run_done
}

harden ()
{
  local bin flag

  IFS=':'
  set -f
  for bin in ${PATH}
  do
    case "${busybox:+busybox}${coreutils:+coreutils}${gnu:+gnu}" in
    ( busybox|coreutils )
      if can exec "${bin}/${1}" && \
         is sym "${bin}/${1}" && \
         eq "$(command basename -- "$(command readlink -f "${bin}/${1}")")" "${busybox:+busybox}${coreutils:+coreutils}"
      then flag='true'; break; fi ;;
    ( gnu )
      if can exec "${bin}/${1}" && \
         eq "$(command basename -- "$(command readlink -f "${bin}/${1}")")" "${1}"
      then flag='true'; break; fi ;;
    ( * )
      if can exec "${bin}/${1}"; then flag='true'; break; fi ;;
    esac
  done
  set +f
  IFS="${exodia_ifs}"

  if not eq "${flag:-}" 'true'
  then fatal "${busybox:+Busybox }${coreutils:+Coreutils }${gnu:+GNU }${1} not found"; return 1; fi
}

check_externals ()
{
  # GNU `find` is really faster than Busybox `find` and have debug options
  gnu='true' harden 'find'

  # GNU `sed` is a little bit slower than Busybox `sed`
  busybox='true' harden 'sed'

  # Coreutils `cp`, `mkdir`, `mv`  and `rm` have verbose option
  coreutils='true' harden 'cp'
  coreutils='true' harden 'mkdir'
  coreutils='true' harden 'mv'
  coreutils='true' harden 'rm'

  # Coreutils `realpath` has -s and --relative-to options
  coreutils='true' harden 'realpath'

  # remove this for the next YQ release
  harden 'ansi2txt'
  harden 'stdbuf'

  harden 'curl'
  harden 'gomplate'
  harden 'exodia-logger'
  harden 'rg'
  harden 'ts'
  harden 'yq'

  # check it with: grep -o -E '\w+' exodia | sort | uniq -c | sort -n
  harden 'basename'
  harden 'dirname'
  harden 'nproc'
  harden 'sha256sum'
  harden 'usleep'
}

init ()
{
  set -euo pipefail

  exodia_ifs="${IFS}"
  readonly exodia_ifs

  add_cache
  add_run
  add_logger_reqchars
  add_style

  check_externals

  GOMPLATE_LEFT_DELIM='{{'
  GOMPLATE_RIGHT_DELIM='}}'
  PS4="${exodia_tracelevel}"

  readonly GOMPLATE_LEFT_DELIM GOMPLATE_RIGHT_DELIM
  export GOMPLATE_LEFT_DELIM GOMPLATE_RIGHT_DELIM

  coreutils --coreutils-prog=mkdir -p "${EXODIA_CACHE_PATH}" "${EXODIA_RUN_PATH}"
}

main ()
{
  init
  { runner "${@}"; } 2>&1 | stdbuf -oL ansi2txt | exodia-logger
}

main "${@}"

# ----------------------------------------------------------------------------
# MEMO
# ----------------------------------------------------------------------------
#
# regular:
# curl -s --unix-socket /var/run/docker.sock -X DELETE http://v1.45/containers/hardcore_jang?force=true
#
# filters/urlencode:
# curl -s --unix-socket /var/run/docker.sock 'http://1.45/images/json' -X GET -G --data-urlencode 'filters={"reference":{"172.17.2.3:5000/mywhalefleet/tiawl.local.*":true}}'
#
# attach: curl -s -N -T - -X POST --unix-socket ./docker.sock 'http://1.45/containers/aaebdff75c380b80556b9c2ce65b2c62ba4cdd59427d3f269d5a61d7b8a087b0/attach?stdout=1&stdin=1&stderr=1&stream=1' -H 'Upgrade: tcp' -H 'Connection: Upgrade'
#
# build:
# tar c -f context.tar -C /tmp .
# curl -s --data-binary @- --header 'Content-Type: application/x-tar' --no-buffer --unix-socket /var/run/docker.sock -X POST http://v1.45/build?dockerfile=Dockerfile&t=reg/proj/my-img:my-tag < context.tar
