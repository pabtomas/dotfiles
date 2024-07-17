package VerbLogRequest

type Type struct {
  message string
}

func New (message string) Type {
  return Type {
    message: message,
  }
}
