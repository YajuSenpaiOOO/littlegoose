extends "res://scripts/art/forest_art184.gd"
var stage_tree185: Sprite3D
func tree(at: Vector2,height: float,index: int) -> void:
 if index!=21: super.tree(at,height,index);return
 var n := cutout181(preload("res://assets/forest185/stage_oak.png"),Vector3(at.x,PLAN.BASE+.025,at.y+1.15),11.,Vector2(.36,1.))
 n.name="StageOak185";n.modulate=Color(.74,.85,1.);stage_tree185=n
 trees.append(n);fading.append({"node":n,"at":at,"radius":3.5,"height":11.})
func _ready() -> void:
 super._ready();name="StageTreeForest185"
 # Bury the painted front lip slightly so the grass/stone apron overlaps its edge.
 cottage_sprite.position.y-=.18
 var island := world.find_child("RootStoneIsland184",true,false)
 if is_instance_valid(island): island.hide()
 # Two irregular flat fragments sit apart from the roots, with no encircling pedestal.
 var poly := PackedVector2Array([Vector2(-.5,-.22),Vector2(.08,-.4),Vector2(.6,-.1),Vector2(.29,.28),Vector2(-.34,.21)])
 for p in [Vector2(-3.4,-.5),Vector2(.75,1.7)]:
  var node: MeshInstance3D=world.park99._prism99(poly,Vector3(PLAN.CENTER.x+p.x,PLAN.BASE+.035,p.y),.07)
  for child in node.get_children():
   if child is CollisionObject3D: child.collision_layer=0
  ground_layers184.append(node)
 # Retain real shadows, with crown masses matching the new asymmetric silhouette.
 var poses := [Vector3(-2.7,7.5,0.),Vector3(2.8,6.8,0.),Vector3(.5,9.,0.)]
 for i in 3: native_casters184[i+3].position=poses[i]+Vector3(0,PLAN.BASE,0)
 attach_lamps185()
func attach_lamps185() -> void:
 if not is_instance_valid(stage_tree185) or hanging_lamps184.size()!=2: return
 var bounds := opaque_bounds181(stage_tree185.texture)
 var points := [Vector2(.405,.695),Vector2(.69,.625)]
 var width := bounds.size.x*stage_tree185.pixel_size
 for i in 2:
  var uv: Vector2=points[i]
  var at: Vector3=stage_tree185.global_position+world.camera.global_basis.x*((uv.x-.36)*width)+world.camera.global_basis.y*((1.-uv.y)*11.)
  hanging_lamps184[i].global_position=at
  hanging_lights184[i].global_position=at-world.camera.global_basis.y*.72+Vector3(0,0,.2)
func _process(delta: float) -> void:
 super._process(delta);attach_lamps185()
