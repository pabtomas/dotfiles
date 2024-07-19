package SpinRequest

type Type struct {
  id string
  message string
}

func New (id string, message string) *Type {
  return &Type {
    id: id,
    message: message,
  }
}

func (self Type) Id () string {
  return self.id
}

func (self Type) Message () string {
  return self.message
}
