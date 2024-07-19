package Bar

import (
  "strconv"
  "strings"
  "time"
)

var (
  colors = [10] string { "204", "203", "209", "215", "221", "227", "191", "155", "119", "83", }
  offsets = [8] string { " ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", }
)

type Type struct {
  max int
  progress int
  term_cursor int
  running bool
  last time.Time
}

func New (max int) *Type {
  return &Type {
    max: max,
    progress: 0,
    term_cursor: 0,
    running: true,
    last: time.Now (),
  }
}

func (self Type) Max () int {
  return self.max
}

func (self Type) Progress () int {
  return self.progress
}

func (self Type) Cursor () int {
  return self.term_cursor
}

func (self *Type) SetCursor (cursor int) {
  self.term_cursor = cursor
}

func (self Type) Running () bool {
  return self.running && self.max > 0
}

func (self Type) Last () *time.Time {
  return &self.last
}

func (self *Type) Incr () {
  self.progress = self.progress + 1
}

func (self *Type) SetLast (now *time.Time) {
  self.last = (*now)
}

func (self *Type) Update (term_max int) {
  if self.term_cursor >= term_max { self.running = false }
}

func (self Type) Color (percent int) string {
  return colors [min (percent / len (colors), len (colors) - 1)]
}

func (self Type) Top (cols int, first bool) string {
  var top string = ""
  if !first { top = "\n" }
  return top + " " + strings.Repeat ("▁", cols - 6)
}

func (self Type) MiddleStart () string {
  return "\n▕"
}

func (self Type) MiddleFilled () string {
  return strings.Repeat (" ", self.term_cursor / 8)
}

func (self Type) MiddleEmpty (term_max int) string {
  var offset_index int = self.term_cursor % len (offsets)
  var empty string = ""
  if self.term_cursor < term_max { empty = offsets [offset_index] }
  var count = (term_max - self.term_cursor) / 8
  if offset_index == 0 { count = max (1, count) - 1 }
  return empty + strings.Repeat (" ", count)
}

func (self Type) MiddleEnd (percent int) string {
  return "▎" + strconv.Itoa (percent) + "%"
}

func (self Type) Bottom (cols int) string {
  return "\n " + strings.Repeat ("▔", cols - 6)
}
