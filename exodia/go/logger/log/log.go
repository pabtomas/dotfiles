package Log

import (
  "time"
  "golang.org/x/term"
  "github.com/tiawl/exodia/logger/request/log"
  "github.com/tiawl/exodia/logger/const"
)

type Type struct {
  header string
  message string
}

func New (request *LogRequest.Type) Type {
  return Type {
    header: request.Header (),
    message: request.Message (),
  }
}

func (self *Type) Render () (string, bool) {
  var max_size int = len (self.message)
  var entry string = ""
  if term.IsTerminal (0) {
    width, _, err := term.GetSize (0)
    if err != nil {
      panic (err)
    }
    max_size = min (max_size, width - constant.HeaderLength)
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
