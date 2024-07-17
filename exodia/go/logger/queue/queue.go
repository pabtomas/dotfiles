package logger_queue

import (
  "container/list"
  "errors"
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

type Queue struct {
  id string
  list *list.List
}

func New (id string) Queue {
  return Queue {
    id: id,
    list: list.New (),
  }
}

func (self *Queue) Append (request interface {}) error {
  switch request.(type) {
    case BarRequest.Type, BufferRequest.Type, FlushRequest.Type,
         KillRequest.Type, DebugLogRequest.Type, ErrorLogRequest.Type,
         InfoLogRequest.Type, NoteLogRequest.Type, RawLogRequest.Type,
         TraceLogRequest.Type, VerbLogRequest.Type, WarnLogRequest.Type,
         ProgressRequest.Type, SpinRequest.Type:
      self.list.PushBack (request)
      return nil
    default:
      return errors.New ("Unknown Request type")
  }
}

func (self Queue) Len () int {
  return self.list.Len ()
}

func (self Queue) PopFront () interface {} {
  return self.list.Remove (self.list.Front ())
}
