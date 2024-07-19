package Queue

import (
  "container/list"
  "errors"
  "github.com/tiawl/exodia/logger/request/bar"
  "github.com/tiawl/exodia/logger/request/progress"
  "github.com/tiawl/exodia/logger/request/buffer"
  "github.com/tiawl/exodia/logger/request/flush"
  "github.com/tiawl/exodia/logger/request/spin"
  "github.com/tiawl/exodia/logger/request/kill"
  "github.com/tiawl/exodia/logger/request/log"
)

type Type struct {
  id string
  list *list.List
}

func New (id string) *Type {
  return &Type {
    id: id,
    list: list.New (),
  }
}

func (self *Type) Append (request interface {}) {
  switch request.(type) {
    case *BarRequest.Type, *BufferRequest.Type, *FlushRequest.Type,
         *KillRequest.Type, *LogRequest.Type, *ProgressRequest.Type,
         *SpinRequest.Type:
      _ = self.list.PushBack (request)
    default:
      panic (errors.New ("Unknown Request type"))
  }
}

func (self Type) Len () int {
  return self.list.Len ()
}

func (self Type) PopFront () interface {} {
  return self.list.Remove (self.list.Front ())
}
