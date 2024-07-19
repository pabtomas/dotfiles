package main

import (
  "runtime"
  "sync"
  "github.com/tiawl/exodia/logger"
)

func deferred (logger *Logger.Type, tasks *sync.WaitGroup) {
  logger.Stop ()
  tasks.Wait ()
}

func routine (logger *Logger.Type, tasks *sync.WaitGroup) {
  defer tasks.Done ()
  logger.Loop ()
}

func main () {
  var nproc int = runtime.NumCPU ()
  var logger *Logger.Type = Logger.New (nproc)
  var tasks sync.WaitGroup
  defer deferred (logger, &tasks)
  tasks.Add (1)
  go routine (logger, &tasks)
  logger.Warn ("Test")
  logger.Info ("TesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTestttttttttttttttttttttttttttttttttttttttttttttttTest")
}
