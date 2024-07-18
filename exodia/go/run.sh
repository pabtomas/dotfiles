#! /bin/sh

set -x
if ! [ -e ./go.mod ]; then go mod init github.com/tiawl/exodia; fi
for module in $(find . -mindepth 1 -type d -printf '%d %P\n' | sort -n -r -k 1 | cut -d' ' -f2)
do
  if ! [ -e "${module}/$(basename -- "${module}").go" ]; then continue; fi
  if [ -e "${module}/go.mod" ]; then continue; fi
  env -C "./${module}" go mod init "github.com/tiawl/exodia/${module}"
  go mod edit -replace "github.com/tiawl/exodia/${module}=./${module}"
  go get "github.com/tiawl/exodia/${module}"
done
go get "github.com/muesli/termenv"
go get "golang.org/x/term"
go run .
