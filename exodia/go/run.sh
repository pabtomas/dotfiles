#! /bin/sh

set -x
go mod init github.com/tiawl/navy
for module in $(find . -mindepth 1 -type d -printf '%d %P\n' | sort -n -r -k 1 | cut -d' ' -f2)
do
  if ! [ -e "${module}/$(basename -- "${module}").go" ]; then continue; fi
  if [ -e "${module}/go.mod" ]; then continue; fi
  env -C "./${module}" go mod init "github.com/tiawl/navy/${module}"
  go mod edit -replace "github.com/tiawl/navy/${module}=./${module}"
  go get "github.com/tiawl/navy/${module}"
done
go run .
