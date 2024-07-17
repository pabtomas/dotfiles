package main

import (
  "runtime"
  "github.com/tiawl/navy/logger"
  "github.com/tiawl/navy/logger/request/log/warn"
)

func main () {
  var l = logger.New (runtime.NumCPU ())
  l.Enqueue (WarnLogRequest.New ("Test"))
}
