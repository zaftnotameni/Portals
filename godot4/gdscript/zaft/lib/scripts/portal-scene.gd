@tool
class_name MC_PortalScene extends Node2D

const PORTALS_GROUP := 'portals'

var current_body : Node2D
var current_dummy : Node2D
var baseline : Node2D

var _the_path : Path2D
var the_path : Path2D :
  get():
    if not _the_path: resolve_path()
    return _the_path

var _other_portal : MC_PortalScene
var other_portal : MC_PortalScene :
  get():
    if not _other_portal: resolve_other_portal()
    return _other_portal

var current_visuals : Node2D :
  get(): return current_body.get_node("Visuals")

func _physics_process(_delta: float) -> void:
  if not other_portal: return
  if not current_dummy: return
  if not current_body: return
  if not current_visuals: return
  var delta_self := baseline.to_local(current_visuals.global_position)
  current_dummy.global_position = other_portal.baseline.to_global(delta_self)
  current_dummy.rotation = current_visuals.rotation + (other_portal.baseline.rotation - baseline.rotation)

func on_body_exited(n:Node):
  if not n: return
  if current_body != n: return
  current_body = null
  current_dummy.queue_free()

func on_body_entered(n:Node):
  if not n: return
  if not other_portal: return
  if not n.has_node("Visuals"): return
  var visuals := n.get_node("Visuals") as Node2D
  if not visuals: return
  current_body = n
  current_dummy = visuals.duplicate(0)
  other_portal.add_child(current_dummy)

func _enter_tree() -> void:
  add_to_group(PORTALS_GROUP)

func _ready() -> void:
  var area := Area2D.new()
  var col := CollisionShape2D.new()
  var seg := SegmentShape2D.new()
  var late := the_path.curve.tessellate();
  seg.a = late[0]
  seg.b = late[late.size() - 1]
  col.shape = seg
  area.add_child(col)
  add_child(area)
  area.body_entered.connect(on_body_entered)
  area.body_exited.connect(on_body_exited)
  baseline = Node2D.new()
  add_child(baseline)
  baseline.global_position = col.to_global(seg.a)
  baseline.rotation = seg.a.angle_to_point(seg.b)

func _get_configuration_warnings() -> PackedStringArray:
  if not the_path:
    return ['Must have a child of type Path2D']
  if not the_path.curve.point_count == 2:
    return ['Must have a child of type Path2D, containing exactly 2 points in its curve']
  return []

func resolve_other_portal():
  for p in get_tree().get_nodes_in_group(PORTALS_GROUP):
    if p and p is MC_PortalScene and p != self:
      _other_portal = p

func resolve_path():
  for c in get_children():
    if c is Path2D:
      _the_path = c
      return
