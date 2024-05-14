search ()
{
  set -eu
  apk search "${1}" | grep "${2:-doc}"
}
