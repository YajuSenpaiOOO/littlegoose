extends RefCounted

# The junction is an existing sampled point on home_to_junction.
const JOIN := Vector2(-4.686759,-2.593792)
const ENTRY := [
 Vector2(-7.16,-4.64), Vector2(-7.16,-3.78), Vector2(-7.09,-3.36),
 Vector2(-6.87,-3.02), Vector2(-6.49,-2.78), Vector2(-6.02,-2.67),
 Vector2(-5.45,-2.65), JOIN,
]
const ENTRY_WIDTH := .79
const BOUNDS := Rect2(-10.,-5.7,6.7,4.1)
const KUMQUAT := Vector2(-9.08,-4.71)
const SHOE_CABINET := Vector2(-5.33,-5.04)
const KUMQUAT_GROUND := Rect2(KUMQUAT-Vector2(.33,.25),Vector2(.66,.55))
const CABINET_GROUND := Rect2(SHOE_CABINET-Vector2(.56,.26),Vector2(1.12,.53))
const WORKSHOP_SITE := Vector2(-10.55,3.95)
const BATH_SITE := Vector2(-1.45,3.65)
const BATH_FACING := -.28
const BATH_WELL := Vector2(2.60,4.16)
const FORK_LANTERN := Vector2(3.25,-1.61)
const BATH_PAD := Rect2(-1.625,-1.30,3.25,2.60)
const BATH_RACK := Vector3(2.12,0.,.35)
const BATH_PATH := [
 Vector2(-4.23,4.43),Vector2(-3.72,4.81),Vector2(-3.03,5.12),Vector2(-2.41,5.38),
 Vector2(-1.78,5.56),Vector2(-1.10,5.61),Vector2(-.41,5.64),Vector2(.31,5.61),
 Vector2(1.02,5.54),Vector2(1.70,5.37),Vector2(2.22,5.13),
]
const WORKSHOP_PAVING := Rect2(-1.57,-1.09,3.14,2.23)
const WORKSHOP_STEPS := [
 Vector2(-.04,1.37),Vector2(.20,1.84),Vector2(.49,2.26),Vector2(.83,2.73),
 Vector2(.73,1.99),
]

static func path_distance(at: Vector2,path: Array) -> float:
 var distance:=INF
 for i in range(1,path.size()):
  var point:=Geometry2D.get_closest_point_to_segment(at,path[i-1],path[i])
  distance=minf(distance,at.distance_to(point))
 return distance

static func workshop_paved(at: Vector2) -> bool:
 var local:=at-WORKSHOP_SITE
 if WORKSHOP_PAVING.grow(.08).has_point(local):return true
 if not Rect2(-.45,1.12,1.63,1.94).has_point(local):return false
 for step: Vector2 in WORKSHOP_STEPS:
  if local.distance_squared_to(step)<.045:return true
 return false

static func bath_paved(at: Vector2) -> bool:
 if at.distance_squared_to(BATH_SITE)>25.:return false
 var local:Vector2=(at-BATH_SITE).rotated(BATH_FACING)
 if BATH_PAD.grow(.16).has_point(local) or Rect2(Vector2(BATH_RACK.x-.45,BATH_RACK.z-.45),Vector2(.9,.9)).has_point(local):
  return true
 if at.distance_squared_to(BATH_WELL)<.68*.68:return true
 for step:Vector2 in BATH_PATH:
  if step.distance_squared_to(at)<.24*.24:return true
 return false

static func paint_segment(lines: PackedVector4Array,widths: PackedFloat32Array,a: Vector2,b: Vector2,width: float) -> void:
 lines.append(Vector4(a.x,a.y,b.x,b.y))
 widths.append(width)

static func paint_path(lines: PackedVector4Array,widths: PackedFloat32Array,area: Rect2,path: Array,width: float) -> void:
 for i in range(1,path.size()):
  var a: Vector2=path[i-1]
  var b: Vector2=path[i]
  if area.intersects(Rect2(a.min(b),a.max(b)-a.min(b)).grow(width+1.)):
   paint_segment(lines,widths,a,b,width)
