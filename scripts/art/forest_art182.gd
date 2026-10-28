extends "res://scripts/art/forest_art181.gd"
const VALLEY=preload("res://scripts/world/forest_plan182.gd")
var lamp_bodies182: Array[StaticBody3D]=[]
var rack_bodies182: Array[StaticBody3D]=[]
var prop_shadows182: Array[MeshInstance3D]=[]
var contacts182: Array[MeshInstance3D]=[]
var rack_top182 := 3.2
var foreground_grass182: MultiMeshInstance3D
func foreground182() -> void:
 # The traversable map keeps its old boundary. Dress the visible low apron
 # beyond that boundary with the same grass so it does not end in a bare strip.
 var rng := RandomNumberGenerator.new();rng.seed=18271
 var poses: Array[Transform3D]=[]
 for iz in 12:
  for ix in 48:
   var p := Vector2(-14.4+ix*.6+rng.randf_range(-.18,.18),17.6+iz*.5+rng.randf_range(-.12,.12))
   var at := PLAN.CENTER+p;var y: float=world.floor_height(at)
   if y> -1.8: continue
   var frame := Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*rng.randf_range(.55,.95))
   poses.append(Transform3D(frame,Vector3(at.x,y,at.y)))
 var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D;multi.use_custom_data=true;multi.mesh=world.meadow.blades(2);multi.instance_count=poses.size()
 for i in poses.size(): multi.set_instance_transform(i,poses[i]);multi.set_instance_custom_data(i,Color(0,.5,0,1))
 foreground_grass182=MultiMeshInstance3D.new();foreground_grass182.multimesh=multi;foreground_grass182.material_override=world.grass_material;foreground_grass182.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;foreground_grass182.visibility_range_end=38.
 world.add_child(foreground_grass182)
func tree(at: Vector2,height: float,index: int) -> void:
 var before := solids.size();super.tree(at,height,index)
 var y: float=world.floor_height(PLAN.CENTER+at)
 trees[-1].position.y=y-.04
 for i in range(before,solids.size()): solids[i].position.y=y+1.
func contact182(at: Vector2,width: float,depth: float) -> void:
 var plane := PlaneMesh.new();plane.size=Vector2(width,depth)
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/foot_contact16.gdshader")
 var n := mesh(plane,Vector3(at.x,world.floor_height(PLAN.CENTER+at)+.032,at.y),material);n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;contacts182.append(n)
func cutout181(texture: Texture2D,at: Vector3,units: float,anchor: Vector2,width := false) -> Sprite3D:
 if texture==preload("res://assets/forest181/woven_lantern.png"):
  texture=preload("res://assets/forest182/post_top_nightlight.png");units=2.3;anchor=Vector2(.5,1.)
  var shape := CylinderShape3D.new();shape.radius=.20;shape.height=2.05
  var n := body(shape,at+Vector3.UP*1.025);n.name="NightlightPost182_%d"%lamp_bodies182.size();lamp_bodies182.append(n)
  contact182(Vector2(at.x,at.z),.75,.55)
 return super.cutout181(texture,at,units,anchor,width)
func silhouette182(visual: Sprite3D) -> void:
 var shadow: MeshInstance3D=world._actor_shadow_script105().new();shadow.battle=world;shadow.visual=visual;shadow.enabled=world.silhouettes_enabled
 visual.add_child(shadow);world.actor_shadows.append(shadow);prop_shadows182.append(shadow)
func _ready() -> void:
 super._ready();name="OpenValleySolidProps182"
 var boundary := BoxShape3D.new();boundary.size=Vector3(37.,3.,.3)
 var edge: float=world.meadow.world_bounds.end.y-PLAN.CENTER.y
 var guard := body(boundary,Vector3(-.5,PLAN.BASE+1.2,edge));guard.name="LoweredWorldEdgeGuard182"
 var top := PLAN.BASE+rack_top182
 # Replace the short native support posts, using the same hand-painted timber.
 for n in get_children():
  if not n is MeshInstance3D or not n.mesh is CylinderMesh: continue
  if absf(n.position.z-4.5)>.02: continue
  if absf(n.position.x-10.9)>.02 and absf(n.position.x-13.2)>.02: continue
  n.hide()
 for p in [Vector2(10.9,4.5),Vector2(13.2,4.5)]:
  var bottom: float=world.floor_height(PLAN.CENTER+p)
  var post := super.cylinder(.10,top-bottom+.08,Vector3(p.x,(top+bottom)*.5,p.y),world.park99.wood97,true)
  post.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON;rack_bodies182.append(solids[-1]);contact182(p,.5,.4)
 flags181.position.y=top;kitten181.position.y=PLAN.BASE+2.6;kitten181.scale=Vector3.ONE*1.1
 # A small solid peg makes the plush loop's attachment explicit.
 box(Vector3(.28,.06,.07),Vector3(10.82,PLAN.BASE+2.6,4.47),world.park99.wood97,false)
 for light in lights181:
  var at := Vector2(light.position.x,light.position.z)
  light.position.y=world.floor_height(PLAN.CENTER+at)+1.98;light.omni_range=4.5
  if absf(at.x-10.65)<.1: light.position.x=10.2
 # Re-seat southern edge planting on the opened valley instead of leaving it
 # floating at the old rim. Leave cottage and newly placed props untouched.
 for n in get_children():
  if n is Sprite3D and not n in props181 and not n in trees and n!=cottage_sprite and n.position.z>7.:
   n.position.y=world.floor_height(PLAN.CENTER+Vector2(n.position.x,n.position.z))-.04
 for visual in props181: silhouette182(visual)
 foreground182()
