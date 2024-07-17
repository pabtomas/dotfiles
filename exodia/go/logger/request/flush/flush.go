package FlushRequest

type Type struct {
  id string
}

func New (id string) Type {
  return Type {
    id: id,
  }
}
