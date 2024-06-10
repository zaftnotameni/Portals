@tool
class_name MC_PortalScene extends Node2D

@export var color: Color = Color.RED

const PORTAL_GROUP := &'portals'

var area : Area2D
var current_body : Node2D
var current_dummy : Node2D
var baseline : Node2D
var normal_a: Vector2
var normal_b: Vector2
var a: Vector2
var b: Vector2
var c: Vector2

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
  current_dummy.rotation = current_body.rotation + (other_portal.baseline.rotation - baseline.rotation)

func on_body_exited(n:Node):
  if not n: return
  if current_body != n: return
  current_body.rotation = current_dummy.rotation
  current_body.global_position = current_dummy.global_position
  current_body = null
  current_dummy.queue_free()
  other_portal.cooldown_for_a_bit()

func cooldown_for_a_bit():
  process_mode = PROCESS_MODE_DISABLED
  await get_tree().create_timer(0.1).timeout
  process_mode = PROCESS_MODE_INHERIT

func on_body_entered(n:Node):
  if not n: return
  if not other_portal: return
  if not n.has_node("Visuals"): return
  var visuals := n.get_node("Visuals") as Node2D
  if not visuals: return
  current_body = n
  current_dummy = visuals.duplicate(0)
  current_dummy.rotation = current_body.rotation + (other_portal.baseline.rotation - baseline.rotation)
  other_portal.add_child(current_dummy)

func _enter_tree() -> void:
  add_to_group(PORTAL_GROUP)

func _ready() -> void:
  area = Area2D.new()
  var col := CollisionShape2D.new()
  var seg := SegmentShape2D.new()
  var late := the_path.curve.tessellate();
  seg.a = late[0]
  seg.b = late[late.size() - 1]
  a = seg.a
  b = seg.b
  c = (a + b) * 0.5
  normal_a = (a - b).orthogonal().normalized()
  normal_b = normal_a.rotated(PI)
  col.shape = seg
  area.add_child(col)
  add_child(area)
  area.body_entered.connect(on_body_entered)
  area.body_exited.connect(on_body_exited)
  baseline = Node2D.new()
  add_child(baseline)
  baseline.global_position = col.to_global(seg.a)
  baseline.rotation = seg.a.angle_to_point(seg.b)

func _draw() -> void:
  draw_line(c, c + (normal_a * 64.0), Color.BLUE, 8.0)
  draw_line(c, c + (normal_b * 64.0), Color.GREEN, 8.0)
  draw_line((a), (b), color, 8.0)

func resolve_other_portal():
  for p in get_tree().get_nodes_in_group(PORTAL_GROUP):
    if p and p is MC_PortalScene and p != self:
      _other_portal = p

func resolve_path():
  for ch in get_children():
    if ch is Path2D:
      _the_path = ch
      return

func _get_configuration_warnings() -> PackedStringArray:
  if not the_path:
    return ['Must have a child of type Path2D']
  if not the_path.curve.point_count == 2:
    return ['Must have a child of type Path2D, containing exactly 2 points in its curve']
  return []

