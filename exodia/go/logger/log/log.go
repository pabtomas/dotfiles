package Log

import (
  "time"
  "github.com/tiawl/exodia/logger/request/log"
  "github.com/tiawl/exodia/logger/const"
)

type Type struct {
  header string
  message string
}

func New (request *LogRequest.Type) *Type {
  return &Type {
    header: request.Header (),
    message: request.Message (),
  }
}

func (self *Type) Render (cols int) (string, bool) {
  var max_size int = len (self.message)
  var entry string = ""
  if cols > -1 {
    max_size = min (max_size, cols - constant.HeaderLength)
  }
  if len (self.header) > 0 {
    entry = self.header + " "
    self.header = ""
  } else {
    entry = "      "
  }
  entry = time.Now ().Format (time.TimeOnly) + " " + entry + self.message [:max_size]
  self.message = self.message [max_size:]
  return entry, len (self.message) > 0
}
