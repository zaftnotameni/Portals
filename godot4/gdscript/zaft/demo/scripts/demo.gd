extends Node2D

func _ready() -> void:
  child_lines_to_bodies(self)

func segment_to_body(a, b) -> Variant:
  if not a: return b
  var body := StaticBody2D.new()
  var col := CollisionShape2D.new()
  var shape := SegmentShape2D.new()
  shape.a = a
  shape.b = b
  col.shape = shape
  body.add_child(col)
  add_child(body)
  return b

func line_to_bodies(line:Line2D):
  if not line: return
  Array(line.points).reduce(segment_to_body)

func child_lines_to_bodies(n:Node):
  if not n: return
  for c in n.get_children():
    if c is Line2D: line_to_bodies(c)
