extends "res://scripts/art/paper_hill139.gd"
const HILL140=preload("res://scripts/world/park_layout140.gd")
var fence_posts140 := 0
var fence_spans140 := 0
var fence_points140: Array[Vector2]=[]
func _ready() -> void:
 super._ready()
 # A low, open rail marks the edge without turning the lookout into a cage.
 # Entrance stays wider than the stairs; all other perimeter sections join.
 var points: Array[Vector3]=[]
 var usable: Array[bool]=[]
 for i in 52:
  var p := HILL140.rim140(TAU*float(i)/52.)
  var entrance := p.x> -23. and HILL136.stair136(p).x<3.1
  var at := point97(p)
  points.append(at);usable.append(not entrance)
  if entrance: continue
  _cylinder97(at-Vector3.UP*.12,at+Vector3.UP*(.86+.045*sin(i*2.1)),.085,wood97,true)
  fence_posts140+=1;fence_points140.append(p)
 for i in 52:
  var j := (i+1)%52
  if not usable[i] or not usable[j]: continue
  for height in [.34,.66]: _cylinder97(points[i]+Vector3.UP*height,points[j]+Vector3.UP*height,.048,wood97,true)
  fence_spans140+=1
 # Keep the middle open. Small grouped stones belong to the raised back rim.
 for spec in [Vector3(-27.5,-27.3,1.0),Vector3(-28.4,-27.,.65),Vector3(-20.3,-28.2,.8),Vector3(-19.6,-28.,.45)]:
  var at := point97(Vector2(spec.x,spec.y),-.06)
  _boulder99(at,Vector3(spec.z,.65*spec.z,spec.z*.8),spec.x)
 name="PaperHill140_LayeredMeadowAndRail"
