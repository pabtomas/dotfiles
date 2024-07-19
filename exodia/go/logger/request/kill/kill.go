package KillRequest

type Type struct {
  id string
}

func New (id string) *Type {
  return &Type {
    id: id,
  }
}

func (self Type) Id () string {
  return self.id
}
