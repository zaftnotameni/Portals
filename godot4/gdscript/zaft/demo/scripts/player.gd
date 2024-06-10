class_name DemoPlayer extends CharacterBody2D

@onready var poly : Polygon2D = %Poly

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
  var col := CollisionPolygon2D.new()
  col.polygon = poly.polygon.duplicate() 
  add_child(col)
  motion_mode = MOTION_MODE_FLOATING

func _physics_process(_delta: float) -> void:
  var direction := read_direction()
  if not direction.is_zero_approx(): move(direction)
  else: stop()
  move_and_slide()

func move(direction:Vector2):
  velocity = direction * SPEED

func stop():
  velocity = velocity.move_toward(Vector2.ZERO, SPEED)

func read_direction() -> Vector2 : return Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()
