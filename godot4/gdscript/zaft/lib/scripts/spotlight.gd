extends Node

func _ready() -> void:
  call_deferred('check_for_camera')

func check_for_camera():
  var cam := get_viewport().get_camera_2d()
  if not cam:
    spawn_camera()

func spawn_camera():
  var node := get_tree().get_first_node_in_group('camera-follow')
  node.add_child(Camera2D.new())

