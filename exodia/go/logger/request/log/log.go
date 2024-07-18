package LogRequest

import (
)

type Type struct {
  header string
  message string
}

func New (header string, message string) Type {
  return Type {
    header: header,
    message: message,
  }
}

func (self Type) Message () string {
  return self.message
}

func (self Type) Header () string {
  return self.header
}
