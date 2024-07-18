package main

import (
  "runtime"
  "github.com/tiawl/exodia/logger"
)

func main () {
  var nproc int = runtime.NumCPU ()
  var logger Logger.Type = Logger.New (nproc)
  defer logger.Deinit ()
  logger.Warn ("Test")
  logger.Info ("TesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTestttttttttttttttttttttttttttttttttttttttttttttttTest")
  _ = logger.Dequeue ()
}
