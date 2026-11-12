extends SceneTree
class Trial:
 extends "res://scripts/world/woodland_world337.gd"
 func export_stats226() -> Error: return OK
 func reset_stats226(partial: bool) -> void:
  super.reset_stats226(partial)
  recording226.folder="res://.record337"
 func commit_console226(levels: Dictionary,_cat: float,_bat: float,_restart: bool) -> String:
  finish_sample337("loadout_change_abort")
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
 var config: Dictionary={"eye_exercise":1}
 check(w.start_recording226(config,90.,80.,"test337")=="","new recording starts")
 var id1: String=w.recording226.id
 w.theatre314.cancel()
 w.waiting_intro314=false
 w.core_phase326=true
 w.paper337.combat_seconds=10.
 w.damage_fastener321({"fixed_damage110":10.,"velocity":Vector3.FORWARD},w.theatre314.castle.global_position)
 check(w.paper337.castle_damage==10. and w.fastener_hp321==134.,"castle actual damage captured")
 w.hurt_cannon326(0,20.)
 check(w.paper337.cannon_damage[0]==16. and w.paper337.disables[0]==1,"cannon overkill clamped to actual health loss")
 check(w.paper337.castle_by_source.get("cannon_disable_reward",0.)==3.,"disable reward attributed separately")
 w.invulnerability=0.
 w.parry_grace258=0.
 w.hero.reset_actions()
 w.hazard_hurt332(1.5,Vector2(w.hero.position.x,w.hero.position.z),"meteor")
 check(w.paper337.injuries.size()==1 and w.paper337.injuries[0].source=="meteor","heavy injury source preserved")
 w.finish251(true)
 var archived: Dictionary=w.report_stats226()
 check(not w.recording226.active and archived.paper_theatre337.result=="victory","victory archives actual paper result")
 check(archived.paper_theatre337.castle_dps==1.3,"DPS uses castle health loss over combat time")
 var r=w.recording226
 r.begin(w,"reuse test")
 check(r.final_report.is_empty(),"recorder begin clears frozen prior report")
 w.start_recording226({"hero_moment":1},90.,80.,"second")
 var id2: String=w.recording226.id
 check(id2!=id1 and w.paper337.id==id2 and w.paper337.castle_damage==0.,"new sample has fresh id and zero damage")
 var second: Dictionary=w.report_stats226()
 check(second.loadout=={"hero_moment":1} and second.paper_theatre337.excluded_hero_moment,"current loadout captured and hero moment flagged")
 w.finish_sample337("abort")
 var path: String=w.recording226.folder+"/"+id2+".json"
 var saved: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
 check(saved.recording.id==id2 and saved.paper_theatre337.id==id2,"filename and both ids agree")
 check(saved.paper_theatre337.result=="abort","abort distinguished from victory")
 print("RESULT failures=",failures)
 quit(failures)
