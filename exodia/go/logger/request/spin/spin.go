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
