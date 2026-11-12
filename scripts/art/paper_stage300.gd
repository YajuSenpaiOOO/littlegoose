extends "res://scripts/art/paper_stage299.gd"
const POSES300={"lean":preload("res://assets/paper_stage300/lean.png"),"fold":preload("res://assets/paper_stage300/fold.png"),"command":preload("res://assets/paper_stage300/command.png")}
var layout300: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper_stage300/layout.json"))
var ready300 := false
var pose300 := "idle"
var balcony300: MeshInstance3D
var balcony_shape300: CollisionShape3D
var actor_clock300 := 0.
const HOME300=Vector3(-3.15,2.12,-1.25)
func _ready() -> void:
 super._ready()
 castle.texture=preload("res://assets/paper_stage300/castle.png");castle.pixel_size=12./float(layout300.castle.span[0]);castle.offset=Vector2(castle.texture.get_width()*.5-float(layout300.castle.foot[0]),float(layout300.castle.foot[1])-castle.texture.get_height()*.5);castle.material_override.albedo_texture=castle.texture
 for i in 2:
  gates298[i].position.x=-2.1025 if i==0 else 2.1025
  (gates298[i].get_child(0) as Sprite3D).scale=Vector3.ONE*1.45
 # Match the larger real opening, keeping solid side walls and a separate door.
 for i in [0,2]:
  var side=-1. if i==0 else 1.;var shape=bodies[i];shape.get_parent().position.x=side*4.05;(shape.shape as BoxShape3D).size.x=3.85
 (door_shape298.shape as BoxShape3D).size=Vector3(4.205,3.2,.23);door_shape298.get_parent().position.y=ground298(0,0)+1.6
 # Fixed narrow backstage support; no moving floor or visible sliding actor.
 balcony300=box(self,Vector3(HOME300.x,HOME300.y-.06,HOME300.z),Vector3(1.1,.12,.65),Color("bca184"))
 for side in [-1.,1.]:box(balcony300,Vector3(side*.43,-1.1,0),Vector3(.1,2.2,.1),Color("bca184"))
 balcony_shape300=collider298(Vector3(HOME300.x,HOME300.y-.06,HOME300.z),Vector3(1.1,.12,.65))
 ready300=true;sample(0.)
func select300(t: float) -> String:
 if t<1.65:return "idle"
 if t<2.15:return "lean"
 if t<3.45:return "fold"
 if t<4.8:return "command"
 if t<8.6:return "lean"
 var u=fmod(t-8.6,5.4)
 if u<1.4:return "lean"
 if u<3.7:return "fold"
 if u<4.6:return "command"
 return "lean"
func act300(t: float) -> void:
 pose300=select300(t)
 if pose300=="idle":return
 var spec: Dictionary=layout300[pose300];visual.texture=POSES300[pose300];visual.pixel_size=1.6/float(spec.span[1]);visual.offset=Vector2(visual.texture.get_width()*.5-float(spec.foot[0]),float(spec.foot[1])-visual.texture.get_height()*.5);visual.material_override.albedo_texture=visual.texture
func sample(t: float) -> void:
 super.sample(t)
 if not ready300:return
 # Entry now passes through the open centre, offset so the tall puppet head
 # clears the rounded arch rather than cutting through its shoulder.
 var u=smoothstep(4.55,7.35,t);var at=Vector3(.8,0,-1.3).lerp(Vector3(1.1,0,4.),u);at.y=ground298(at.x,at.z);puppet298.position=at
 puppet298.visible=t>=4.55 and gate_open298>.65 or t>=7.35
 girl.visible=t<.95 or t>=1.65
 girl.position=girl_home298 if t<1.65 else HOME300
 balcony300.visible=t>=1.42;balcony_shape300.disabled=t<2.9
 act300(t)
 bubble.position=Vector3(0,2.0,0)
 bubble.visible=t<.7 or t>3.45 and t<4.3
 bubble.text="啊？我的小纸怪\n怎么都趴下了！" if t<.7 else "开门——让它上！"
 if t<.1:actor_clock300=0.
func _process(delta: float) -> void:
 super._process(delta)
 if ready300 and finished and not playing:
  actor_clock300+=delta;act300(8.6+actor_clock300)
