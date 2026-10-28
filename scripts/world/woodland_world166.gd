extends "res://scripts/world/woodland_world165.gd"
const ARC_RANGE166 := 1.65
const GRAVITY166 := 14.
const BUILDS166=[
 {"name":"短抛糖屑＋快射＋舞步","levels":{"snack":1,"eye_exercise":1,"exercise":1}},
 {"name":"短抛糖屑＋飞机＋舞步","levels":{"snack":1,"paper_plane":1,"exercise":1}},
 {"name":"短抛糖屑＋气球剑＋舞步","levels":{"snack":1,"balloon_sword":1,"exercise":1}},
 {"name":"短抛糖屑＋弹弓","levels":{"snack":1,"slingshot":1}},
 {"name":"课间操＋快射＋笔记","levels":{"exercise":1,"eye_exercise":1,"homework":1}},
 {"name":"普通快射对照","levels":{"eye_exercise":1,"homework":1}},
 {"name":"二级短抛糖屑","levels":{"snack":2}},
 {"name":"立体书＋短抛糖屑＋舞步","levels":{"hero_moment":1,"snack":1,"exercise":1}},
 {"name":"枕头窝＋舞步＋笔记","levels":{"pillow_hut":1,"exercise":1,"homework":1}}]
var build166 := 0
var arcs_landed166 := 0
func _init() -> void:
 buffs=preload("res://scripts/combat/buff_book166.gd").new();buffs.rng110.randomize()
 memory_kit116=preload("res://scripts/combat/memory_kit166.gd").new();memory_save116="user://snack_exercise166.cfg"
func _skills_script110() -> Script: return preload("res://scripts/combat/battle_skills166.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/play_hud166.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 166 · 近身糖屑 / 彩带舞步")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(moment161): await get_tree().physics_frame
 if "--play166" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func inherit_split153(shot: Dictionary,split: Dictionary) -> void:
 super.inherit_split153(shot,split)
 var direction := Vector3(shot.velocity.x,0.,shot.velocity.z).normalized()
 var at: Vector3=shot.node.position
 var height := maxf(.05,at.y-floor_height(Vector2(at.x,at.z))-.04)
 var up := 2.6
 var flight := (up+sqrt(up*up+2.*GRAVITY166*height))/GRAVITY166
 shot.arc166=true;shot.arc_origin166=at;shot.arc_age166=0.;shot.life=minf(1.8,flight+.12)
 shot.velocity=direction*(ARC_RANGE166/flight)+Vector3.UP*up
 shot.spawn_grace111=0.
 if split.has("rid"): shot.ignore_rids110.append(split.rid)
func _step_shots(delta: float) -> void:
 # Keep original shots on the existing native path; only local fragments use ballistic integration.
 var arcs: Array[Dictionary]=[]
 for i in range(shots.size()-1,-1,-1):
  if shots[i].get("arc166",false): arcs.append(shots[i]);shots.remove_at(i)
 super._step_shots(delta)
 for shot in arcs:
  var start: Vector3=shot.node.position;var velocity: Vector3=shot.velocity
  var end := start+velocity*delta+Vector3.DOWN*GRAVITY166*delta*delta*.5
  shot.velocity=velocity+Vector3.DOWN*GRAVITY166*delta;shot.life-=delta;shot.arc_age166+=delta
  var hit := _trace_shot(shot,start,end)
  var landed := end.y<=floor_height(Vector2(end.x,end.z))+.035
  if not hit.is_empty(): _apply_shot_hit(shot,hit)
  if not hit.is_empty() or landed or shot.life<=0.:
   if landed: arcs_landed166+=1
   pool110.retire(shot)
  else:
   shot.node.previous=start;shot.node.at=end;shots.append(shot)
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();paper_build129=0;paper_build146=0;build152=0;build153=0;build160=0;build161=0
 buffs.levels=BUILDS166[build166].levels.duplicate();beam_left110=0.;_apply_owned_buffs();reset_metrics152();announce152()
func announce152() -> void:
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS166[build166].name,"分裂子弹短程下落 · Shift掠过敌人触发彩带星芒三连 · 伤害仍只算一次",3.)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if active114 and (trial152 or paper_trial129):
   if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:
    build166=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
   if event.physical_keycode==KEY_F9:
    build166=(build166+1)%BUILDS166.size();apply_paper_build129();get_viewport().set_input_as_handled();return
 super._input(event)
