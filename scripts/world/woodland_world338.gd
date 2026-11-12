extends "res://scripts/world/woodland_world337.gd"
var structure_splits338: Array[Dictionary]=[]
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 338 · 结构分裂弹 / 坡面弹道")
func _ready() -> void:
 await super._ready()
 hint288.text="338 结构分裂弹 / 坡面弹道\n小零食可命中结构分裂 · C纸剧场独立采样"
func _apply_shot_hit(shot: Dictionary, hit: Dictionary) -> void:
 var aliases: Array[RID]=[]
 var eligible:=false
 if active114 and core_phase326 and is_instance_valid(theatre314):
  if hit.collider==theatre314.castle_target327 or hit.collider==theatre314.bodies[0].get_parent():
   eligible=fastener_hp321>0.
   aliases=[theatre314.castle_target327.get_rid(),theatre314.bodies[0].get_parent().get_rid()]
  elif hit.collider is Area3D:
   var index: int=theatre314.cannon_areas326.find(hit.collider)
   if index>=0:
    eligible=cannon_hp326[index]>0.
    aliases.append(hit.collider.get_rid())
    var body: CollisionObject3D=theatre314.scenery_shapes322[theatre314.cannons326[index]].get_parent()
    aliases.append(body.get_rid())
 var depth:=int(shot.get("split_depth110",0))
 var snack:=int(shot.get("snack146",buffs.level("snack")))
 var split:=eligible and snack>depth
 var damage:=damage_for_shot(shot)
 super._apply_shot_hit(shot,hit)
 if split and active114:
  structure_splits338.append({"at":hit.position,"depth":depth+1,"damage":damage*.5,"ignore":aliases,"velocity111":shot.velocity,"life111":maxf(.35,float(shot.get("life",.7))*.5),"piercing111":shot.get("charged",false) or shot.get("piercing110",false),"sword153":shot.get("sword153",false),"goose_source168":shot.get("goose_source168",0),"payload234":{"stream":shot.get("stream110",false),"heavy":shot.get("stream_heavy110",false),"lane":shot.get("stream_lane110",0),"charged":shot.get("charged",false),"note":shot.get("note110",false),"snack":snack,"tracking":shot.get("tracking146",buffs.level("eye_exercise"))}})
func _step_shots(delta: float) -> void:
 super._step_shots(delta)
 var pending:=structure_splits338.duplicate()
 structure_splits338.clear()
 for split in pending:
  var count:=6 if int(split.depth)==1 else 4
  for i in count:
   var angle:=TAU*float(i)/float(count)
   var direction:=Vector3(cos(angle),0.,sin(angle))
   if shots.size()>=512: break
   var velocity: Vector3=split.velocity111
   var shot: Dictionary=data_shot110(split.at+direction*14./Profile.PPM,direction*velocity.length(),float(split.life111))
   shot.split_depth110=split.depth
   shot.fixed_damage110=split.damage
   shot.ignore_rids110=split.ignore.duplicate()
   shot.spawn_grace111=.06
   shot.piercing110=split.piercing111
   inherit_split153(shot,split)
   shot.damage_source260="snack_split"
func _clear_combat_shots() -> void:
 structure_splits338.clear()
 super._clear_combat_shots()
func cannon_height338(at: Vector2, clearance: float) -> float:
 var nominal:=floor_height(at)
 var query:=PhysicsRayQueryParameters3D.create(Vector3(at.x,nominal+4.,at.y),Vector3(at.x,nominal-4.,at.y),1)
 var ground:=get_world_3d().direct_space_state.intersect_ray(query)
 # Terrain only, never the top of a cannon/tree as a fake floor.
 var surface:=maxf(nominal,float(ground.position.y)) if not ground.is_empty() else nominal
 return surface+maxf(.7,clearance)
func acquire_structure335(cursor: Vector2) -> Dictionary:
 var result:=super.acquire_structure335(cursor)
 if result.is_empty(): return result
 var origin:=projectile_origin()
 var at: Vector3=result.at
 var terrain:=PhysicsRayQueryParameters3D.create(origin,at,1)
 if get_world_3d().direct_space_state.intersect_ray(terrain).is_empty(): return result
 var shape: CollisionShape3D=result.shape
 var local:=shape.to_local(at)
 var ceiling: float=(shape.shape as BoxShape3D).size.y*.5-.05
 for step in range(1,25):
  var y:=local.y+float(step)*.15
  if y>ceiling: break
  var candidate:=shape.to_global(Vector3(local.x,y,local.z))
  terrain.to=candidate
  if get_world_3d().direct_space_state.intersect_ray(terrain).is_empty():
   result.at=candidate
   result.raised338=true
   break
 return result
func report_stats226() -> Dictionary:
 var report:=super.report_stats226()
 report.runtime_world_script=get_script().resource_path
 report.runtime_preview=338
 if report.has("paper_theatre337"): report.paper_theatre337.preview=338
 return report

func cannon_start338(at: Vector3, clearance: float) -> Vector3:
 return Vector3(at.x,maxf(at.y,cannon_height338(Vector2(at.x,at.z),clearance)),at.z)

func stop_beam288() -> void:
 super.stop_beam288()
 structure_splits338=structure_splits338.filter(func(split): return not split.get("payload234",{}).get("stream",false))

func start_progress_record338(levels: Dictionary, cat_hp: float, bat_hp: float, mode: String, level: int) -> String:
 var error:=commit_progress257(levels,cat_hp,bat_hp,true,level)
 if error!="": return error
 return begin_sample337(mode)
func commit_progress257(levels: Dictionary, cat_hp: float, bat_hp: float, restart: bool, level: int) -> String:
 if loadout_error257(levels,level)=="" and is_finite(cat_hp) and is_finite(bat_hp) and cat_hp>=10. and bat_hp>=10. and cat_hp<=10000. and bat_hp<=10000.:
  finish_sample337("loadout_change_abort")
 return super.commit_progress257(levels,cat_hp,bat_hp,restart,level)
