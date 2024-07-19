package BarRequest

type Type struct {
  max int
}

func New (max int) *Type {
  return &Type {
    max: max,
  }
}

func (self Type) Max () int {
  return self.max
}
