extends "res://scripts/art/forest_dressing_art183.gd"
const VALLEY=preload("res://scripts/world/forest_plan183.gd")
var lamp_bodies182: Array[StaticBody3D]=[]
var rack_bodies182: Array[StaticBody3D]=[]
var prop_shadows182: Array[MeshInstance3D]=[]
var contacts182: Array[MeshInstance3D]=[]
var rack_top182 := 3.2
var foreground_grass182: MultiMeshInstance3D
func foreground182() -> void: pass
func tree(at: Vector2,height: float,index: int) -> void:
 if index==21:
  var n := cutout181(preload("res://assets/forest183/central_oak.png"),Vector3(at.x,PLAN.BASE,at.y),7.6,Vector2(.52,1.))
  n.name="CentralOak183";trees.append(n);fading.append({"node":n,"at":at,"radius":2.4,"height":7.6});return
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
 super._ready();name="RockAlcoveForest183"
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
 grounding183()

var craft_props183: Array[Sprite3D]=[]
var cottage_shadow183: MeshInstance3D
func grounding183() -> void:
 contact182(Vector2(-11.,-9.7),6.1,3.0)
 silhouette182(cottage_sprite);cottage_shadow183=prop_shadows182[-1]
 var poly := PackedVector2Array([Vector2(-2.9,-.8),Vector2(2.7,-.85),Vector2(3.,.35),Vector2(2.5,.85),Vector2(-2.65,.75)])
 var foundation: MeshInstance3D=world.park99._prism99(poly,Vector3(PLAN.CENTER.x-11.,PLAN.BASE+.018,PLAN.CENTER.y-9.7),.16)
 foundation.name="CottageFoundation183"
 for child in foundation.get_children():
  if child is CollisionObject3D: child.collision_layer=0
 for p in [Vector2(4.8,2.8),Vector2(-12.8,-7.7)]:
  var y: float=world.floor_height(PLAN.CENTER+p)
  var prop := cutout181(preload("res://assets/forest183/yarn_craft_corner.png"),Vector3(p.x,y,p.y),1.3,Vector2(.5,1.),true)
  prop.name="YarnCraftCorner183";craft_props183.append(prop);silhouette182(prop);contact182(p,1.15,.8)
  var shape := CylinderShape3D.new();shape.radius=.43;shape.height=.8;body(shape,Vector3(p.x,y+.4,p.y))
 contact182(Vector2(-1.,0.),3.8,2.8)
 # Low, nonblocking flowers keep both routes clear and introduce the lilac palette.
 for p in [Vector2(-3.2,1.),Vector2(-2.9,-2.),Vector2(.9,1.5),Vector2(.7,-1.9),Vector2(8.,-6.8),Vector2(5.8,-8.1),Vector2(-8.8,-9.1),Vector2(-13.5,-9.),Vector2(-11.2,-7.),Vector2(-10.,4.8),Vector2(2.,8.6)]:
  var y: float=world.floor_height(PLAN.CENTER+p)
  var flower := cutout181(preload("res://assets/forest183/lilac_ground_clump.png"),Vector3(p.x,y,p.y),1.05,Vector2(.5,1.),true)
  flower.name="LilacGroundClump183";silhouette182(flower)
