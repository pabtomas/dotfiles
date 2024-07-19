package main

import (
  "math/rand"
  "runtime"
  "sync"
  "time"
  "github.com/tiawl/exodia/logger"
  "github.com/tiawl/exodia/logger/request/bar"
  "github.com/tiawl/exodia/logger/request/progress"
  "github.com/tiawl/exodia/logger/request/spin"
  "github.com/tiawl/exodia/logger/request/kill"
)

func deferred (logger *Logger.Type, tasks *sync.WaitGroup) {
  logger.Stop ()
  tasks.Wait ()
}

func routine (logger *Logger.Type, tasks *sync.WaitGroup) {
  defer tasks.Done ()
  logger.Loop ()
}

func test (logger *Logger.Type) {
  logger.Warn ("Test")
  logger.Info ("TesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTesTestttttttttttttttttttttttttttttttttttttttttttttttTest")
  logger.Enqueue (SpinRequest.New ("cache", "In Progress ..."))
  time.Sleep (1_000_000_000)
  logger.Enqueue (SpinRequest.New ("cache2", "In Progress 2 ..."))
  time.Sleep (1_000_000_000)
  logger.Enqueue (SpinRequest.New ("cache3", "In Progress 3 ..."))
  time.Sleep (1_000_000_000)
  logger.Enqueue (KillRequest.New ("cache"))
  time.Sleep (1_000_000_000)
  logger.Enqueue (KillRequest.New ("cache3"))
  time.Sleep (1_000_000_000)
  logger.Enqueue (KillRequest.New ("cache2"))
  logger.Enqueue (BarRequest.New (10))
  for i := 0; i < 10 ; i++ {
    time.Sleep (time.Duration ((rand.Intn (8) + 1) * 100_000_000))
    logger.Enqueue (ProgressRequest.New ())
  }
}

func main () {
  var nproc int = runtime.NumCPU ()
  var logger *Logger.Type = Logger.New (nproc)
  var tasks sync.WaitGroup
  defer deferred (logger, &tasks)
  tasks.Add (1)
  go routine (logger, &tasks)
  test (logger)
}
