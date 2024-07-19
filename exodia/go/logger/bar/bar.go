package LoggerBar

import (
  "time"
)

type Type struct {
  max uint32
  progress uint32
  term_cursor uint32
  running bool
  last time.Time
}

func New (max uint32) *Type {
  return &Type {
    max: max,
    progress: 0,
    term_cursor: 0,
    running: false,
  }
}

func (self Type) Running () bool {
  return self.running
}
