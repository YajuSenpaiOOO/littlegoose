extends "res://scripts/world/woodland_world101.gd"
var woodland_ready102 := false
var assisted_steps102 := 0
func _park_script99() -> Script: return preload("res://scripts/art/nature_park102.gd")
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props102.gd")
func _details_script101() -> Script: return preload("res://scripts/art/woodland_details102.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time102.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 102 · 实阶碰撞 / 立体蘑菇 / 可踢松果与拨叶")
func _grass_growth92(at: Vector2) -> float:
 if meadow!=null and not meadow.landmarks.is_empty():
  var p: Vector2=at-Vector2(meadow.landmarks.grove)
  var stair := PARK99.to_stair99(p)
  if ((p-PARK99.DECK)/Vector2(3.7,3.)).length()<1. or (absf(stair.x-PARK99.STAIR_X)<1.8 and stair.y>PARK99.STAIR_TOP-.35 and stair.y<PARK99.STAIR_FOOT+.6): return 0.
 return super._grass_growth92(at)
func _refresh_planting() -> void:
 super._refresh_planting()
 var g: Vector2=meadow.landmarks.grove
 for item in grass_poses92:
  var p: Vector3=item.node.to_global(item.after.origin)
  var local := Vector2(p.x,p.z)-g
  var stair := PARK99.to_stair99(local)
  if ((local-PARK99.DECK)/Vector2(3.7,3.)).length()<1. or (absf(stair.x-PARK99.STAIR_X)<1.8 and stair.y>PARK99.STAIR_TOP-.35 and stair.y<PARK99.STAIR_FOOT+.6):
   item.after.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);item.before.basis=item.after.basis;item.node.multimesh.set_instance_transform(item.index,item.after)
func floor_height(at: Vector2) -> float:
 var base := super.floor_height(at)
 if is_instance_valid(park99) and park99.has_method("support102"):
  var p: Vector2=at-Vector2(meadow.landmarks.grove)
  if (p-PARK99.DECK).length()<8.: base=maxf(base,park99.support102(at))
 return base
func _ready() -> void:
 super._ready()
 while not woodland_ready101: await get_tree().physics_frame
 process_physics_priority=-10
 woodland_ready102=true;_title35();time55.update_guide();print("WOODLAND102_READY solid_slabs=",park99.slab_bodies102.size())
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not woodland_ready102: return
 _step_actor102(hero,delta)
 for enemy in enemies:
  if is_instance_valid(enemy) and not enemy.dead: _step_actor102(enemy,delta)
func _step_actor102(actor: CharacterBody3D,delta: float) -> void:
 var at := Vector2(actor.position.x,actor.position.z)
 var p: Vector2=PARK99.to_stair99(at-Vector2(meadow.landmarks.grove))
 if absf(p.x-PARK99.STAIR_X)>1.65 or p.y<PARK99.STAIR_TOP-.65 or p.y>PARK99.STAIR_FOOT+.65: return
 var direction := Vector2(actor.velocity.x,actor.velocity.z)
 if actor==hero and actor.has_method("movement_input"): direction+=actor.movement_input()*actor.movement_speed()
 if actor!=hero:
  if actor.hopping: direction+=actor.hop_direction*3.
  elif actor.get("attack_phase")=="lunge": direction+=actor.attack_direction*3.
 if direction.length()<.1: return
 var lead := .23 if actor==hero else .38
 var ahead := at+direction.normalized()*maxf(lead,minf(lead+.09,direction.length()*delta+lead-.03))
 var support: float=park99.support102(ahead)
 var rise: float=support-actor.position.y
 if rise>.008 and rise<.34 and actor.velocity.y<=.5:
  actor.position.y=support+.012;actor.velocity.y=0.;assisted_steps102+=1
