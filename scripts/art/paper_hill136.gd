extends "res://scripts/art/nature_park102.gd"
const HILL136=preload("res://scripts/world/park_layout136.gd")
var hill_treads136 := 0
func _ready() -> void:
 super._ready()
 var g: Vector2=world.meadow.landmarks.grove
 for segment in 3:
  var a: Vector2=HILL136.POINTS[segment];var b: Vector2=HILL136.POINTS[segment+1]
  var length := a.distance_to(b)
  var count := maxi(1,ceili(absf(HILL136.HEIGHTS[segment+1]-HILL136.HEIGHTS[segment])/.18))
  if segment==1: count=2
  var run := length/float(count)
  for i in count:
   var t := (float(i)+.5)/float(count)
   var at := g+a.lerp(b,t)
   var top := lerpf(HILL136.HEIGHTS[segment],HILL136.HEIGHTS[segment+1],float(i+1)/float(count))+.015
   var width := 1.17+.07*sin(i*2.4+segment)
   var poly := PackedVector2Array([Vector2(-width+.10,-run*.54),Vector2(width-.12,-run*.55),Vector2(width,-run*.30),Vector2(width-.04,run*.51),Vector2(-width+.07,run*.54),Vector2(-width-.06,run*.25)])
   var tread := _prism99(poly,Vector3(at.x,top,at.y),.30)
   tread.rotation.y=atan2((b-a).x,(b-a).y)
   hill_treads136+=1
 # Small rock shoulders define the turning landing without narrowing the tread.
 for local in [Vector2(-8.6,-7.2),Vector2(-12.6,-10.6),Vector2(-15.5,-15.4),Vector2(-22.3,-14.8)]:
  var p: Vector2=g+local
  _boulder99(Vector3(p.x,world.meadow.height_at(p.x,p.y,true)-.04,p.y),Vector3(.8,.7,.9),local.x)
 name="PaperHillAndForest136"
