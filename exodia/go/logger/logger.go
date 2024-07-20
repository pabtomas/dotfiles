package Logger

import (
  "bufio"
  "container/list"
  "errors"
  "math"
  "os"
  "sync"
  "time"
  "golang.org/x/term"
  "github.com/muesli/termenv"
  "github.com/tiawl/exodia/logger/color"
  "github.com/tiawl/exodia/logger/bar"
  "github.com/tiawl/exodia/logger/log"
  "github.com/tiawl/exodia/logger/queue"
  "github.com/tiawl/exodia/logger/spin"
  "github.com/tiawl/exodia/logger/request/bar"
  "github.com/tiawl/exodia/logger/request/progress"
  "github.com/tiawl/exodia/logger/request/spin"
  "github.com/tiawl/exodia/logger/request/kill"
  "github.com/tiawl/exodia/logger/request/log"
)

const (
  ClearCursorUntilScreenEndSeq = "J"
  CursorHorizontalSeq = "G"
)

type Type struct {
  nproc int
  mutex sync.Mutex
  requests *Queue.Type
  spins *list.List
  elements map [string] *list.Element
  bar *Bar.Type
  looping bool
  cols int
  writer *bufio.Writer
  output *termenv.Output
  restoreConsole func () error
}

func New (nproc int) *Type {
  var self *Type = &Type {
    nproc: nproc,
    mutex: sync.Mutex {},
    requests: Queue.New ("root"),
    elements: make (map [string] *list.Element, nproc),
    spins: list.New (),
    bar: Bar.New (0),
    looping: true,
    cols: -1,
    writer: bufio.NewWriter (os.Stderr),
  }
  var err error
  self.restoreConsole, err = termenv.EnableVirtualTerminalProcessing (termenv.DefaultOutput ())
  if err != nil { panic (err) }
  if term.IsTerminal (0) { self.cols = 0 }
  self.output = termenv.NewOutput (self.writer, termenv.WithProfile (termenv.ANSI256))
  return self
}

func (self *Type) Stop () {
  self.looping = false
}

func (self *Type) Enqueue (request interface {}) {
  self.mutex.Lock ()
  defer self.mutex.Unlock ()
  self.requests.Append (request)
}

func (self *Type) Log (message string, level string, color string) {
  var header termenv.Style = self.output.String (level)
  if (len (color) > 0) { header = header.Bold ().Foreground (self.output.Color (color)) }
  self.Enqueue (LogRequest.New (header.String (), message))
}

func (self *Type) Error (message string) {
  self.Log (message, "ERROR", Color.Red)
}

func (self *Type) Warn (message string) {
  self.Log (message, " WARN", Color.Yellow)
}

func (self *Type) Info (message string) {
  self.Log (message, " INFO", Color.Green)
}

func (self *Type) Note (message string) {
  self.Log (message, " NOTE", Color.Cyan)
}

func (self *Type) Debug (message string) {
  self.Log (message, "DEBUG", Color.Blue)
}

func (self *Type) Trace (message string) {
  self.Log (message, "TRACE", Color.Purple)
}

func (self *Type) Verb (message string) {
  self.Log (message, " VERB", Color.Pink)
}

func (self *Type) Raw (message string) {
  self.Log (message, "", "")
}

func (self *Type) Dequeue () bool {
  if !self.mutex.TryLock () { return false }
  defer self.mutex.Unlock ()
  var log_rendered bool = false
  for self.requests.Len () > 0 { log_rendered = self.Response (self.requests.PopFront ()) }
  return log_rendered
}

func (self *Type) BarResponse (request *BarRequest.Type) {
  self.bar = Bar.New (request.Max ())
}

func (self *Type) SpinResponse (request *SpinRequest.Type) *list.Element {
  // TODO: check Length before insert
  return self.spins.PushBack (Spin.New (request.Message ()))
}

func (self *Type) KillResponse (request *KillRequest.Type) {
  _ = self.spins.Remove (self.elements [request.Id ()])
  delete (self.elements, request.Id ())
}

func (self *Type) LogRender (log *Log.Type) bool {
  var entry string
  var looping bool
  entry, looping = log.Render (self.cols)
  self.WriteString (entry + "\n")
  return looping
}

func (self *Type) SpinRender (spin *Spin.Type, first bool) {
  if self.cols < 0 { return }
  if !first { self.WriteByte ('\n') }
  var chrono, pattern, message string
  var elapsed int64
  chrono, elapsed = spin.Chrono ()
  chrono = self.output.String (chrono).Bold ().Foreground (self.output.Color (Color.White)).String ()
  pattern = self.output.String (spin.Pattern (elapsed)).Bold ().Foreground (self.output.Color (spin.Color (elapsed))).String ()
  message = self.output.String (spin.Message ()).Bold ().Foreground (self.output.Color (Color.White)).String ()
  self.WriteString (chrono + pattern + message)
  self.output.ClearLineRight ()
}

func (self *Type) BarRender (first bool) bool {
  if self.cols < 0 { return false }
  var term_max int = (self.cols - 6) * 8
  self.bar.Update (term_max)
  if !self.bar.Running () { return false }

  var term_progress int = (self.bar.Progress () * term_max) / self.bar.Max ()

  var now time.Time = time.Now ()
  var ns int64 = int64 (now.Sub ((*self.bar.Last ())) % time.Second)
  if self.bar.Cursor () < term_progress && ns > 10_000_000 {
    var gap float64 = float64 ((term_progress - self.bar.Cursor ()) / 10)
    var log float64 = math.Log2 (math.Max (gap, 2)) - 1
    var shift int = int (math.Min (gap, log))
    self.bar.SetCursor (self.bar.Cursor () + (1 << shift))
    self.bar.SetLast (&now)
  }

  self.WriteString (self.output.String (self.bar.Top (self.cols, first)).Bold ().Foreground (self.output.Color (Color.White)).String ())
  self.output.ClearLineRight ()

  var percent int = (self.bar.Cursor () * 100) / term_max
  var color termenv.Color = self.output.Color (self.bar.Color (percent))
  self.WriteString (self.output.String (self.bar.MiddleStart ()).Bold ().Foreground (self.output.Color (Color.White)).String ())
  self.WriteString (self.output.String (self.bar.MiddleFilled ()).Bold ().Background (color).String ())
  self.WriteString (self.output.String (self.bar.MiddleEmpty (term_max)).Bold ().Foreground (color).String ())
  self.WriteString (self.output.String (self.bar.MiddleEnd (percent)).Bold ().Foreground (self.output.Color (Color.White)).String ())
  self.output.ClearLineRight ()

  self.WriteString (self.output.String (self.bar.Bottom (self.cols)).Bold ().Foreground (self.output.Color (Color.White)).String ())
  self.output.ClearLineRight ()

  return true
}

func (self *Type) LogResponse (request *LogRequest.Type) {
  var log *Log.Type = Log.New (request)
  var looping bool = true
  var err error

  for looping {
    looping = self.LogRender (log)
    err = self.writer.Flush ()
    if err != nil { panic (err) }
  }
}

func (self *Type) ProgressResponse (request *ProgressRequest.Type) {
  self.bar.Incr ()
}

func (self *Type) Response (request interface {}) bool {
  var log_rendered bool = false
  switch cast := request.(type) {
    case *SpinRequest.Type:
      self.elements [cast.Id ()] = self.SpinResponse (cast)
    case *KillRequest.Type:
      self.KillResponse (cast)
    case *BarRequest.Type:
      self.BarResponse (cast)
    case *ProgressRequest.Type:
      self.ProgressResponse (cast)
    case *LogRequest.Type:
      self.LogResponse (cast)
      log_rendered = true
    default:
      panic (errors.New ("Unknown Request type"))
  }
  return log_rendered
}

func (self *Type) UpdateCols () {
  if self.cols > -1 {
    var err error
    self.cols, _, err = term.GetSize (0)
    if err != nil { panic (err) }
  }
}

func (self *Type) WriteByte (b byte) {
  var err error = self.writer.WriteByte (b)
  if err != nil { panic (err) }
}

func (self *Type) WriteString (str string) {
  var err error
  _, err = self.writer.WriteString (str)
  if err != nil { panic (err) }
}

func (self *Type) CursorStartLine () {
  self.WriteString (termenv.CSI + "1" + CursorHorizontalSeq)
}

func (self *Type) ClearCursorUntilScreenEnd () {
  self.WriteString (termenv.CSI + ClearCursorUntilScreenEndSeq)
}

func (self *Type) GoUp (cond bool) {
  if cond { self.CursorStartLine ()
  } else { self.output.CursorPrevLine (1) }
}

func (self *Type) Animation () {
  var spin_rendered bool = false
  var err error
  for e := self.spins.Front (); e != nil; e = e.Next () {
    self.SpinRender (e.Value.(*Spin.Type), !spin_rendered)
    spin_rendered = true
  }
  var bar_rendered bool = self.BarRender (!spin_rendered)
  self.ClearCursorUntilScreenEnd ()
  for e := self.spins.Front (); e != nil; e = e.Next () {
    self.GoUp (e == self.spins.Front ())
  }
  if bar_rendered {
    for i := 0; i < 3; i++ {
      self.GoUp (i == 0 && !spin_rendered)
    }
  }
  err = self.writer.Flush ()
  if err != nil { panic (err) }
}

func (self *Type) Deferred () {
  var err error
  self.ClearCursorUntilScreenEnd ()
  self.output.ShowCursor ()
  err = self.restoreConsole ()
  if err != nil { panic (err) }
  err = self.writer.Flush ()
  if err != nil { panic (err) }
}

func (self *Type) Loop () {
  self.output.HideCursor ()
  defer self.Deferred ()
  for self.looping || self.requests.Len () > 0 || self.bar.Running () || self.spins.Len () > 0 {
    self.UpdateCols ()
    if !self.Dequeue () { self.Animation () }
  }
}
