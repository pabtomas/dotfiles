package Logger

import (
  "bufio"
  "errors"
  "os"
  "sync"
  "github.com/muesli/termenv"
  "github.com/tiawl/exodia/logger/bar"
  "github.com/tiawl/exodia/logger/log"
  "github.com/tiawl/exodia/logger/queue"
  "github.com/tiawl/exodia/logger/spin"
  "github.com/tiawl/exodia/logger/request/bar"
  "github.com/tiawl/exodia/logger/request/progress"
  "github.com/tiawl/exodia/logger/request/buffer"
  "github.com/tiawl/exodia/logger/request/flush"
  "github.com/tiawl/exodia/logger/request/spin"
  "github.com/tiawl/exodia/logger/request/kill"
  "github.com/tiawl/exodia/logger/request/log"
)
import "fmt"

type Type struct {
  mutex sync.Mutex
  requests LoggerQueue.Type
  spins map [string] LoggerSpin.Type
  buffers map [string] LoggerQueue.Type
  bar LoggerBar.Type
  looping bool
  cols uint16
  writer *bufio.Writer
  output *termenv.Output
  restoreConsole func () error
}

func New (nproc int) Type {
  var self Type = Type {
    mutex: sync.Mutex {},
    requests: LoggerQueue.New ("root"),
    spins: make (map [string] LoggerSpin.Type, nproc),
    buffers: make (map [string] LoggerQueue.Type, nproc),
    bar: LoggerBar.New (0),
    looping: true,
    cols: 0,
    writer: bufio.NewWriter (os.Stderr),
  }
  var err error
  self.restoreConsole, err = termenv.EnableVirtualTerminalProcessing (termenv.DefaultOutput ())
  if err != nil {
    panic (err)
  }
  self.output = termenv.NewOutput (os.Stderr, termenv.WithProfile (termenv.ANSI256))
  return self
}

func (self *Type) Deinit () {
  self.restoreConsole ()
}

func (self *Type) Enqueue (request interface {}) {
  self.mutex.Lock ()
  defer self.mutex.Unlock ()
  self.requests.Append (request)
}

func (self *Type) Log (message string, level string, color string) {
  var header termenv.Style = self.output.String (level)
  if (len (color) > 0) {
    header = header.Bold ().Foreground (self.output.Color (color))
  }
  self.Enqueue (LogRequest.New (header.String (), message))
}

func (self *Type) Error (message string) {
  self.Log (message, "ERROR", "204")
}

func (self *Type) Warn (message string) {
  self.Log (message, " WARN", "227")
}

func (self *Type) Info (message string) {
  self.Log (message, " INFO", "119")
}

func (self *Type) Note (message string) {
  self.Log (message, " NOTE", "81")
}

func (self *Type) Debug (message string) {
  self.Log (message, "DEBUG", "69")
}

func (self *Type) Trace (message string) {
  self.Log (message, "TRACE", "135")
}

func (self *Type) Verb (message string) {
  self.Log (message, " VERB", "207")
}

func (self *Type) Raw (message string) {
  self.Log (message, "", "")
}

func (self *Type) Dequeue () bool {
  if !self.mutex.TryLock () {
    return false
  }
  defer self.mutex.Unlock ()
  var log_rendered bool = false
  for self.requests.Len () > 0 {
    log_rendered = self.Response (self.requests.PopFront ())
  }
  return log_rendered
}

func (self *Type) BarResponse (request *BarRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Type) BufferResponse (request *BufferRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Type) FlushResponse (request *FlushRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Type) SpinResponse (request *SpinRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Type) KillResponse (request *KillRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Type) LogResponse (request *LogRequest.Type) {
  var log Log.Type = Log.New (request)
  var looping bool = true
  var entry string

  for looping {
    entry, looping = log.Render ()
    _, err := self.writer.WriteString (entry + "\n")
    if err != nil {
      panic (err)
    }
    err = self.writer.Flush ()
    if err != nil {
      panic (err)
    }
  }
}

func (self *Type) ProgressResponse (request *ProgressRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Type) Response (request interface {}) bool {
  var log_rendered bool = false
  switch cast := request.(type) {
    case BufferRequest.Type:
      self.BufferResponse (&cast)
    case FlushRequest.Type:
      self.FlushResponse (&cast)
    case SpinRequest.Type:
      self.SpinResponse (&cast)
    case KillRequest.Type:
      self.KillResponse (&cast)
    case BarRequest.Type:
      self.BarResponse (&cast)
    case ProgressRequest.Type:
      self.ProgressResponse (&cast)
    case LogRequest.Type:
      self.LogResponse (&cast)
      log_rendered = true
    default:
      panic (errors.New ("Unknown Request type"))
  }
  return log_rendered
}
