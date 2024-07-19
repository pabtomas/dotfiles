package Spin

import (
  "fmt"
  "time"
)

var (
  colors = [30] string { "196", "202", "208", "214", "220", "226", "190",
    "154", "118", "82", "46", "47", "48", "49", "50", "51", "45", "39", "33",
    "27", "21", "57", "93", "128", "165", "201", "200", "199", "198", "197", }
  patterns = [34] string {
    " ⠄     ",
    " ⠔     ",
    " ⠐⠁    ",
    "  ⠉    ",
    "  ⠈⠂   ",
    "   ⠢   ",
    "   ⠠⠄  ",
    "    ⠔  ",
    "    ⠐⠁ ",
    "     ⠉ ",
    "     ⠘ ",
    "     ⠔ ",
    "    ⠠⠄ ",
    "    ⠢  ",
    "   ⠈⠂  ",
    "   ⠉   ",
    "  ⠐⠁   ",
    "  ⠔    ",
    " ⠠⠄    ",
    " ⠢     ",
    " ⠃     ",
    " ⠉     ",
    " ⠈⠂    ",
    "  ⠢    ",
    "  ⠠⠄   ",
    "   ⠔   ",
    "   ⠐⠁  ",
    "    ⠉  ",
    "    ⠈⠂ ",
    "     ⠢ ",
    "     ⠠ ",
    "       ",
    "       ",
    "       ",
  }
)

type Type struct {
  message string
  birth time.Time
}

func New (message string) *Type {
  return &Type {
    message: message,
    birth: time.Now (),
  }
}

func (self *Type) Chrono () (string, int64) {
  var delta int64 = int64 (time.Since (self.birth))
  const ns_per_s = int64 (time.Second)
  var ns int64 = delta % ns_per_s
  var sec int64 = delta / ns_per_s
  var days int64 = sec / 86400
  sec = sec % 86400
  var chrono string

  if days == 0 && sec < 60 {
    chrono = fmt.Sprintf ("%5d.%02d", sec, ns / 10_000_000)
  } else if days == 0 && sec < 3600 {
    chrono = fmt.Sprintf ("%5d:%02d", sec / 60, sec % 60)
  } else if days == 4 && sec < 14400 {
    chrono = fmt.Sprintf ("%2d:%02d:%02d", (days * 24) + (sec / 3600), (sec % 60) / 60, sec % 60)
  } else {
    chrono = "--:--:-- "
  }

  return chrono, (days * 86400 + sec) * 10 + (ns / 100_000_000);
}

func (self *Type) Pattern (elapsed int64) string {
  return patterns [elapsed % int64 (len (patterns))]
}

func (self *Type) Color (elapsed int64) string {
  return colors [(elapsed / 5) % int64 (len (colors))]
}

func (self Type) Message () string {
  return self.message
}
