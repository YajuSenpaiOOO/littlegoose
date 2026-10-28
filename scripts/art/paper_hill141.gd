extends "res://scripts/art/paper_hill139.gd"
const HILL140=preload("res://scripts/world/park_layout140.gd")
const VIEW141 := Vector2(-25.7,-28.3)
var fence_posts140 := 0
var fence_spans140 := 0
var fence_points140: Array[Vector2]=[]
var sit_point141: Marker3D
func rail141(p: Vector2) -> bool:
 # Three short incidental rail runs, instead of a ring-shaped arena boundary.
 return (p.x< -30.5 and p.y> -23. and p.y< -16.) or (p.y> -7.2 and p.x> -27. and p.x< -20.) or (p.x< -27.5 and p.y< -26.)
func _ready() -> void:
 super._ready()
 var points: Array[Vector3]=[];var usable: Array[bool]=[]
 for i in 52:
  var p := HILL140.rim140(TAU*float(i)/52.)
  var allowed := rail141(p)
  var at := point97(p);points.append(at);usable.append(allowed)
  if not allowed: continue
  _cylinder97(at-Vector3.UP*.12,at+Vector3.UP*(.78+.04*sin(i*2.1)),.085,wood97,true)
  fence_posts140+=1;fence_points140.append(p)
 for i in 52:
  var j := (i+1)%52
  if usable[i] and usable[j]:
   for height in [.32,.60]: _cylinder97(points[i]+Vector3.UP*height,points[j]+Vector3.UP*height,.048,wood97,true)
   fence_spans140+=1
 # Broad, rooted stone shoulders form the remaining open cliff-side boundary.
 # The north-facing seat is an opening, with a low natural stone lip behind it.
 for i in 26:
  var p := HILL140.rim140(TAU*float(i)/26.)
  if p.x> -21. or rail141(p) or p.distance_to(VIEW141)<4.1: continue
  _boulder99(point97(p,-.20),Vector3(1.35,.95,1.10),float(i)*2.1)
 for spec in [Vector3(-29.2,-27.8,1.3),Vector3(-22.8,-29.4,1.1),Vector3(-17.1,-22.5,1.5),Vector3(-18.4,-26.6,1.25),Vector3(-30.4,-10.,.9)]:
  _boulder99(point97(Vector2(spec.x,spec.y),-.22),Vector3(spec.z,spec.z*1.25,spec.z*.9),spec.x)
 sit_point141=Marker3D.new();sit_point141.name="FutureSitAndSeaView141";sit_point141.position=point97(VIEW141)
 sit_point141.set_meta("purpose","Reserved narrative seat: grass gives way to mossy bare stone; no automatic sitting yet.")
 add_child(sit_point141)
 # Low rocks at the outer lip read as terrain, leaving an unobstructed view.
 for x in [-1.65,-.55,.55,1.65]:
  _boulder99(point97(VIEW141+Vector2(x,-2.0),-.13),Vector3(.95,.65,.70),x+5.)
 name="PaperHill141_NaturalBordersAndMossyLookout"
