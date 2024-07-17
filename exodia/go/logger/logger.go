package logger

import (
  "bufio"
  "errors"
  "os"
  "sync"
  "github.com/tiawl/navy/logger/bar"
  "github.com/tiawl/navy/logger/queue"
  "github.com/tiawl/navy/logger/spin"
  "github.com/tiawl/navy/logger/request/bar"
  "github.com/tiawl/navy/logger/request/progress"
  "github.com/tiawl/navy/logger/request/buffer"
  "github.com/tiawl/navy/logger/request/flush"
  "github.com/tiawl/navy/logger/request/spin"
  "github.com/tiawl/navy/logger/request/kill"
  "github.com/tiawl/navy/logger/request/log/debug"
  "github.com/tiawl/navy/logger/request/log/error"
  "github.com/tiawl/navy/logger/request/log/info"
  "github.com/tiawl/navy/logger/request/log/note"
  "github.com/tiawl/navy/logger/request/log/raw"
  "github.com/tiawl/navy/logger/request/log/trace"
  "github.com/tiawl/navy/logger/request/log/verb"
  "github.com/tiawl/navy/logger/request/log/warn"
)
import "fmt"

type Logger struct {
  mutex sync.Mutex
  requests logger_queue.Queue
  spins map [string] logger_spin.Spin
  buffers map [string] logger_queue.Queue
  bar logger_bar.Bar
  looping bool
  cols uint16
  writer *bufio.Writer
}

func New (nproc int) Logger {
  return Logger {
    mutex: sync.Mutex {},
    requests: logger_queue.New ("root"),
    spins: make (map [string] logger_spin.Spin, nproc),
    buffers: make (map [string] logger_queue.Queue, nproc),
    bar: logger_bar.New (0),
    looping: true,
    cols: 0,
    writer: bufio.NewWriter (os.Stderr),
  }
}

func (self *Logger) Enqueue (request interface {}) {
  self.mutex.Lock ()
  defer self.mutex.Unlock ()
  self.requests.Append (request)
}

func (self *Logger) Dequeue () (bool, error) {
  if !self.mutex.TryLock () {
    return false, nil
  }
  defer self.mutex.Unlock ()
  var log_rendered = false
  for self.requests.Len () > 0 {
    response, err := self.Response (self.requests.PopFront ())
    if err != nil {
      return false, err
    }
    log_rendered = response
  }
  return log_rendered, nil
}

func (self *Logger) BarResponse (request *BarRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Logger) BufferResponse (request *BufferRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Logger) FlushResponse (request *FlushRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Logger) SpinResponse (request *SpinRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Logger) KillResponse (request *KillRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Logger) LogResponse (request interface {}) {
  fmt.Println ("TODO")
}

func (self *Logger) ProgressResponse (request *ProgressRequest.Type) {
  fmt.Println ("TODO")
}

func (self *Logger) Response (request interface {}) (bool, error) {
  var log_rendered = false
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
    case DebugLogRequest.Type, ErrorLogRequest.Type, InfoLogRequest.Type,
         NoteLogRequest.Type, RawLogRequest.Type, TraceLogRequest.Type,
         VerbLogRequest.Type, WarnLogRequest.Type:
      self.LogResponse (request)
      log_rendered = true
    default:
      return log_rendered, errors.New ("Unknown Request type")
  }
  return log_rendered, nil
}

//  _, err := writer.WriteString ("Test\n")
//  if err != nil {
//    fmt.Printf ("writer.WriteString () failed with: %v\n", err)
//    return
//  }
//  err = writer.Flush ()
//  if err != nil {
//    fmt.Printf ("writer.Flush () failed with: %v\n", err)
//    return
//  }
