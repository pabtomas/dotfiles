package BarRequest

type Type struct {
  max uint32
}

func New (max uint32) Type {
  return Type {
    max: max,
  }
}
