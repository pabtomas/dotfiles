package KillRequest

type Type struct {
  id string
}

func New (id string, message string) Type {
  return Type {
    id: id,
  }
}
