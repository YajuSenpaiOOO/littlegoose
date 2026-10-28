extends "res://scripts/art/forest_art194.gd"
var decor201: Array[Dictionary]=[]
var light_seeds201: Array[Vector3]=[]
var fence_bodies201: Array[StaticBody3D]=[]
func level201(p: Vector2,half_width := .4) -> bool:
 if lane_distance194(p)<2.0: return false
 var y: float=world.floor_height(PLAN.CENTER+p)
 if y>PLAN.TOP+.1: return false
 for offset in [Vector2(-half_width,0),Vector2(half_width,0),Vector2(0,.3),Vector2(0,-.3)]:
  if absf(world.floor_height(PLAN.CENTER+p+offset)-y)>.15: return false
 return true
func fence201(p: Vector2,width: float) -> void:
 var found := false
 var desired := p
 for ring in 6:
  for direction in [Vector2.ZERO,Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,Vector2(1,1).normalized(),Vector2(-1,1).normalized(),Vector2(1,-1).normalized(),Vector2(-1,-1).normalized()]:
   var candidate: Vector2=desired+direction*float(ring)*.65
   if not level201(candidate,width*.45): continue
   if candidate.distance_to(Vector2(-1.,0.))<2.8 or candidate.distance_to(Vector2(7.6,-5.))<2.5: continue
   var spaced := true
   for entry in decor201:
    if entry.kind=="fence" and entry.local.distance_to(candidate)<3.5: spaced=false;break
   if not spaced: continue
   p=candidate;found=true;break
  if found: break
 if not found: return
 var node := cutout181(preload("res://assets/forest201/ribbon_fence.png"),ground194(p),width,Vector2(.5,1.),true)
 node.name="RibbonFence201";node.modulate=Color(.83,.80,.89)
 decor201.append({"node":node,"local":p,"kind":"fence","width":width})
 # Footprint follows the short rails; these sections are outside the lane.
 var shape := BoxShape3D.new();shape.size=Vector3(width*.88,.65,.22)
 var solid := body(shape,ground194(p)+Vector3.UP*.325);solid.name="ShortFenceFootprint201";fence_bodies201.append(solid)
 contact182(p,width,.55);silhouette182(node)
 var glow: Vector3=painted_point193(node,Vector2(.90,.18))+world.camera.global_basis.z*.18
 light_seeds201.append(glow)
func nook201(p: Vector2,kitten: bool) -> void:
 if not level201(p,.65): return
 var ground := ground194(p)
 var stump := cylinder(.30,.38,ground+Vector3.UP*.19,world.park99.wood97,true)
 stump.name="LittleLanternStump201";stump.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 contact182(p,.9,.65)
 var node := cutout181(preload("res://assets/forest184/hanging_lantern.png"),ground+Vector3.UP*.38,.62,Vector2(.5,1.))
 node.name="StumpAmberLantern201";node.modulate=Color(.8,.76,.78)
 decor201.append({"node":node,"local":p,"kind":"stump_lantern"})
 if kitten:
  var toy := cutout181(preload("res://assets/forest181/ghost_kitten.png"),ground+Vector3(.48,.02,.02),.62,Vector2(.5,1.))
  toy.name="PretendScaryPlush201";toy.modulate=Color(.66,.62,.73)
  decor201.append({"node":toy,"local":p+Vector2(.48,.02),"kind":"plush"})
  silhouette182(toy);contact182(p+Vector2(.48,.02),.55,.4)
func _ready() -> void:
 super._ready()
 for spec in [Vector3(-1.,-7.6,3.8),Vector3(8.4,-8.8,3.4),Vector3(10.5,-.2,3.2),Vector3(7.0,10.,3.6),Vector3(-9.,5.2,3.5),Vector3(-10.8,-.2,3.1)]:
  fence201(Vector2(spec.x,spec.y),spec.z)
 for spec in [Vector3(-8.1,-5.8,1),Vector3(3.6,-3.1,0),Vector3(-3.8,6.5,1)]: nook201(Vector2(spec.x,spec.y),spec.z>0.)
