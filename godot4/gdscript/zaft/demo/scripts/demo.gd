extends Node2D

@onready var spawner : Node2D = $Spawner

const PLAYER_GROUP := &'players'
const PLAYER := preload('res://demo/scenes/player.tscn')

func _ready() -> void:
  child_lines_to_bodies(self)
  spawn_player()

func _input(event: InputEvent) -> void:
  if event.is_action_pressed(&'respawn'):
    spawn_player()

func spawn_player():
  var existing := get_tree().get_first_node_in_group(PLAYER_GROUP)
  if existing:
    existing.queue_free()
    await existing.tree_exited

  var p := PLAYER.instantiate()
  add_child(p)
  p.add_to_group(PLAYER_GROUP)
  p.global_position = spawner.global_position

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
