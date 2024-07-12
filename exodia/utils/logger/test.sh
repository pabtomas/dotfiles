#!/usr/bin/env bash

init ()
{
  if ! command -v openssl > /dev/null; then apk add --no-cache openssl; fi

  s=0
  k=0

  S () { printf 'S\7test%d\7%s ...\n' "${s}" "$(openssl rand -base64 15)"; s="$((s+1))"; };
  K () { printf 'Ktest%d\n' "${k}"; k="$((k+1))"; };
  P () { printf 'P%d\n' "${1}"; }
  p () { sleep "0.$(shuf -i 1-9 -n 1)"; printf 'p\n'; }
  info () { sed 's/^/2/'; }
}

test1 ()
{
  S; sleep 2
  S; sleep 2
  S; sleep 2
  max=10
  P "${max}"
  for i in $(seq "${max}"); do p; done
  K
  sleep 2; K
  sleep 2; K
}

test2 ()
{
  S
  seq 100000 | info
  K
}

test3 ()
{
  for i in $(seq 30); do printf '%s%s\n' "$(shuf -n1 -i0-7 | tr '7' '-')" "$(openssl rand -base64 15)"; done
}

main ()
{
  init
  start=1
  end=3
  for i in $(seq "${start}" "${end}"); do test"${i}" | exodia-logger; done
}

main
