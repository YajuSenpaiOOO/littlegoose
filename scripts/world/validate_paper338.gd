extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world338.gd"
 func export_stats226() -> Error: return OK
 func reset_stats226(partial: bool) -> void:
  super.reset_stats226(partial)
  recording226.folder="res://.record338"
 func commit_progress257(levels: Dictionary,_cat: float,_bat: float,_restart: bool,level: int) -> String:
  finish_sample337("loadout_change_abort")
  determination_level257=level
  levels226=levels.duplicate(true)
  restart301()
  return ""
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func reset_hit(w: Node) -> void:
 w.invulnerability=0.
 w.parry_grace258=0.
 w.hero.reset_actions()
 w.player_hp=12.
func run() -> void:
 var w=Trial.new()
 root.add_child(w)
 current_scene=w
 var deadline:=Time.get_ticks_msec()+180000
 while not is_instance_valid(w.boss_bar326) and Time.get_ticks_msec()<deadline: await process_frame
 if not is_instance_valid(w.boss_bar326):
  quit(1)
  return
 w.set_physics_process(false)
 w.hero.set_physics_process(false)
 var stage=w.theatre314
 stage.set_process(false)
 stage.cancel()
 stage.sample(4.06)
 stage.finished=true
 w.boss_step314(.01)
 w.set_process(false)
 w.clear_patterns327()
 w._clear_combat_shots()
 w.buffs.levels["snack"]=1
 var collider: Area3D=stage.castle_target327
 var point: Vector3=collider.get_child(2).global_position
 var shot: Dictionary=w.data_shot110(w.hero.global_position+Vector3.UP,Vector3.FORWARD*4.,1.)
 shot.fixed_damage110=2.
 shot.split_depth110=0
 w._apply_shot_hit(shot,{"collider":collider,"position":point})
 check(w.structure_splits338.size()==1,"castle hit schedules snack split")
 w._step_shots(0.)
 var children: Array=w.shots.filter(func(s): return s.get("damage_source260","")=="snack_split")
 check(children.size()==6,"first generation emits six native pool fragments")
 check(children.all(func(s): return s.fixed_damage110==1. and s.split_depth110==1),"fragments inherit half damage and depth")
 check(children.all(func(s): return s.get("final_damage234",false) and s.get("snack146",0)==1),"existing resolved payload inheritance retained")
 check(children.all(func(s): return s.ignore_rids110.has(collider.get_rid()) and s.ignore_rids110.has(stage.bodies[0].get_parent().get_rid())),"castle area and wall aliases cannot retrigger same structure")
 w._clear_combat_shots()
 w.buffs.levels["snack"]=2
 shot=w.data_shot110(w.hero.global_position+Vector3.UP,Vector3.FORWARD*4.,1.)
 shot.fixed_damage110=2.
 shot.split_depth110=0
 var gun: Area3D=stage.cannon_areas326[0]
 w._apply_shot_hit(shot,{"collider":gun,"position":gun.global_position})
 w._step_shots(0.)
 children=w.shots.filter(func(s): return s.get("damage_source260","")=="snack_split")
 check(children.size()==6,"level two cannon hit emits six fragments")
 w._clear_combat_shots()
 shot={"fixed_damage110":1.,"velocity":Vector3.FORWARD,"split_depth110":2}
 w._apply_shot_hit(shot,{"collider":gun,"position":gun.global_position})
 check(w.structure_splits338.is_empty(),"generation cap remains intact")
 var terrain_hits:=0
 var segments:=0
 for index in 2:
  var start: Vector3=stage.muzzle330(index)
  start=w.cannon_start338(start,.8)
  for offset in [-4.,-2.,0.,2.,4.]:
   var target: Vector2=w.centre301+Vector2(offset,8.)
   var previous: Vector3=start
   for i in range(1,61):
    var v: Vector2=Vector2(start.x,start.z).lerp(target,float(i)/60.)
    var next:=Vector3(v.x,w.cannon_height338(v,.8),v.y)
    var query:=PhysicsRayQueryParameters3D.create(previous,next,1)
    if not w.get_world_3d().direct_space_state.intersect_ray(query).is_empty(): terrain_hits+=1
    segments+=1
    previous=next
 check(terrain_hits==0,"both batteries traverse 600 real slope segments without terrain clipping")
 var origin: Vector3=stage.muzzle330(1)
 var at: Vector2=Vector2(origin.x,origin.z)
 var low:=w.floor_height(at)-1.
 check(w.cannon_start338(Vector3(at.x,low,at.y),.8).y>=w.floor_height(at)+.8,"embedded initial source is lifted before collision sweep")
 # Props still use the unchanged 1|2 collision query, never blanket wall ignores.
 check(w.hero.collision_mask==3,"hero terrain and scenery collision unchanged")
 var report: Dictionary=w.report_stats226()
 check(report.runtime_preview==338 and report.runtime_world_script==w.get_script().resource_path,"runtime preview and actual script path recorded")
 w._clear_combat_shots()
 check(w.structure_splits338.is_empty(),"clear removes pending structural splits")
 w.console226.draft={"snack":1,"eye_exercise":1}
 w.console226.determination257.value=2
 w.console226.record226()
 check(w.paper337.get("active",false) and w.paper337.loadout_start==w.console226.draft,"actual C record button starts paper telemetry with current draft")
 var id: String=w.recording226.id
 var path: String=w.recording226.folder+"/"+id+".json"
 var saved: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
 check(saved.has("paper_theatre337") and saved.paper_theatre337.id==id and saved.runtime_preview==338,"actual C button saves paper block id and runtime version")
 w.console226.draft={"hero_moment":1}
 w.console226.record226()
 check(w.recording226.id!=id and w.paper337.excluded_hero_moment,"second actual C recording refreshes id and exclusion flag")
 w.finish_sample337("abort")
 print("RESULT failures=",failures," terrain_segments=",segments)
 quit(failures)
