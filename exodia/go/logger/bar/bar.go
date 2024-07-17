package logger_bar

import (
  "time"
)

type Bar struct {
  max uint32
  progress uint32
  term_cursor uint32
  running bool
  last time.Time
}

func New (max uint32) Bar {
  return Bar {
    max: max,
    progress: 0,
    term_cursor: 0,
    running: false,
  }
}
