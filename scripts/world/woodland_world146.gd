extends "res://scripts/world/woodland_world145.gd"
var hill_ready146 := false
var paper_memories146: Node3D
var paper_build146 := 0
const PAPER_TEST146=[{"name":"飞机＋课堂笔记","levels":{"paper_plane":1,"homework":1}},{"name":"弹弓飞机＋课堂笔记","levels":{"paper_plane":1,"homework":1,"slingshot":1}},{"name":"分裂飞机＋课堂笔记","levels":{"paper_plane":1,"homework":1,"snack":1}},{"name":"追踪飞机＋课堂笔记","levels":{"paper_plane":1,"homework":1,"eye_exercise":1}},{"name":"水柱飞机＋课堂笔记","levels":{"paper_plane":1,"homework":1,"flashlight":1}},{"name":"直接弹弓＋课堂笔记","levels":{"homework":1,"slingshot":1}}]
func _init() -> void:
 memory_kit116=preload("res://scripts/combat/memory_kit146.gd").new();memory_save116="user://paper_memories146.cfg"
 buffs=preload("res://scripts/combat/buff_book146.gd").new();buffs.rng110.randomize()
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 146 · 纸飞机投递 / 课堂笔记运用")
func _hero_script() -> Script: return preload("res://scripts/combat/hero146.gd")
func _skills_script110() -> Script: return preload("res://scripts/combat/battle_skills146.gd")
func _memory_ui_script116() -> Script: return preload("res://scripts/combat/notebook_ui146.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud146.gd")
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_memories146.gd")
func _ready() -> void:
 super._ready()
 while not hill_ready145: await get_tree().physics_frame
 paper_memories146=_paper_manager_script146().new();paper_memories146.battle=self
 var effect_root146: Node=call("combat_effect_root159") if has_method("combat_effect_root159") else self
 effect_root146.add_child(paper_memories146)
 hill_ready146=true;_title35()
 if "--memories146" in OS.get_cmdline_user_args(): paper_trial129=true;start_combat()
 print("PAPER_MEMORIES146_READY")
func paper_aim146() -> Vector3: return aim_at_screen(get_viewport().get_mouse_position())
func attack_cooldown() -> float:
 return maxf(.28,(2. if buffs.level("three_player")>0 else 1.)/buffs.rate()) if buffs.level("paper_plane")>0 else super.attack_cooldown()
func fire_input_held() -> bool:
 if is_instance_valid(paper_memories146) and paper_memories146.writing146: return false
 return super.fire_input_held()
func _step_fire_input(delta: float) -> void:
 if is_instance_valid(paper_memories146) and paper_memories146.writing146: _cancel_charge();return
 if buffs.level("flashlight")>0 and buffs.level("slingshot")==0 and (buffs.level("paper_plane")>0 or buffs.level("homework")>0):
  if not fire_input_held(): fire_needs_release=false
  if fire_input_held() and not fire_needs_release and cooldown<=0. and wave_state=="fighting" and not result_open:
   fire_at(paper_aim146());cooldown=attack_cooldown()
  return
 var was_charge := charge_active;var age := charge_age
 super._step_fire_input(delta)
 if was_charge and not charge_active and buffs.level("paper_plane")>0: cooldown=maxf(cooldown,maxf(0.,attack_cooldown()-age))
func fire_at(target: Vector3) -> void:
 if not is_instance_valid(paper_memories146) or (buffs.level("paper_plane")==0 and buffs.level("homework")==0): super.fire_at(target);return
 capture146(target,false,0.)
func _release_charged(target: Vector3,ratio: float) -> void:
 if not is_instance_valid(paper_memories146) or (buffs.level("paper_plane")==0 and buffs.level("homework")==0): super._release_charged(target,ratio);return
 capture146(target,true,ratio)
func capture146(target: Vector3,charged: bool,ratio: float) -> void:
 var packet := snapshot_packet146(target,charged,ratio)
 if packet.is_empty(): return
 paper_memories146.record146(packet)
 if packet.plane: paper_memories146.launch146(packet,projectile_origin(),target)
 elif packet.stream: paper_memories146.send146(packet,projectile_origin(),target)
func snapshot_packet146(target: Vector3,charged: bool,ratio: float,retire_all := false,carrier := true) -> Dictionary:
 if not target.is_finite(): return {}
 var before := shots.size();var origin := projectile_origin()
 var stream := buffs.level("flashlight")>0
 if stream: super.emit_stream110(target)
 elif charged: super._release_charged(target,ratio)
 else: super.fire_at(target)
 if shots.size()==before: return {}
 var packet := {"plane":buffs.level("paper_plane")>0,"stream":stream,"burst_time":.22+(.18*ratio if charged else 0.),"pulse_interval":.04/(buffs.rate()*flashlight_rate_gain110()*(.5 if buffs.level("three_player")>0 else 1.)),"specs":[],"label":"水柱" if stream else (("蓄力%d%%"%roundi(ratio*100.)) if charged else ("分裂" if buffs.level("snack")>0 else "普通"))}
 if packet.plane: packet.label="飞机·"+str(packet.label)
 var carrier_gain := 1.
 if carrier and packet.plane and not charged:
  carrier_gain=attack_cooldown()/float(packet.burst_time) if stream else attack_cooldown()/maxf(.01,super.attack_cooldown())
 for i in range(before,shots.size()):
  var shot: Dictionary=shots[i];var velocity: Vector3=shot.velocity;var direct := target-origin
  var spec := {"speed":velocity.length(),"angle":Vector2(direct.x,direct.z).angle_to(Vector2(velocity.x,velocity.z)),"life":shot.life,"damage":damage_for_shot(shot)*carrier_gain,"gain":shot.art.scale_gain if shot.has("art") else 1.,"charged":shot.get("charged",false),"piercing110":shot.get("piercing110",false),"note110":shot.get("note110",false),"stream110":shot.get("stream110",false),"snack":buffs.level("snack"),"tracking":buffs.level("eye_exercise")}
  packet.specs.append(spec)
 if retire_all or packet.plane or stream:
  for i in range(shots.size()-1,before-1,-1): pool110.retire(shots[i]);shots.remove_at(i);fired_count-=1
 return packet
func emit_packet146(packet: Dictionary,origin: Vector3,target: Vector3,gain: float,generation := -1) -> void:
 for spec in packet.specs:
  var direction := (target-origin).normalized().rotated(Vector3.UP,-float(spec.angle))
  if direction.length_squared()<.01: direction=Vector3.FORWARD
  var shot: Dictionary=data_shot110(origin+direction*.08,direction*spec.speed,spec.life)
  shot.fixed_damage110=float(spec.damage)*gain;shot.damage_multiplier=1.;shot.charged=spec.charged;shot.piercing110=spec.piercing110;shot.note110=spec.note110;shot.split_depth110=0
  shot.snack146=spec.snack;shot.tracking146=spec.tracking;shot.packet146=true
  shot.art.projectile=true;shot.art.scale_gain=float(spec.gain)*(.85 if gain<1. else 1.);shot.art.facing=screen_direction(origin,direction)
  if spec.stream110:
   stream_sequence110+=1;shot.stream110=true;shot.stream_lane110=0;shot.stream_generation110=generation if generation>=0 else stream_generation110;shot.stream_sequence110=stream_sequence110;shot.stream_heavy110=false
func damage_for_shot(shot: Dictionary) -> float:
 if shot.get("packet146",false): return float(shot.fixed_damage110)
 return super.damage_for_shot(shot)
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var saved: int=buffs.level("snack")
 if shot.get("packet146",false): buffs.levels["snack"]=int(shot.snack146)
 super._apply_shot_hit(shot,hit)
 if saved>0: buffs.levels["snack"]=saved
 else: buffs.levels.erase("snack")
func on_dash_started() -> void:
 if is_instance_valid(paper_memories146): paper_memories146.cancel146()
 super.on_dash_started()
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if is_instance_valid(paper_memories146): paper_memories146.step146(delta)
func _clear_combat_shots() -> void:
 super._clear_combat_shots()
 if is_instance_valid(paper_memories146): paper_memories146.reset146()
func apply_paper_build129() -> void:
 _cancel_charge();_clear_combat_shots();paper_build129=0;buffs.levels=PAPER_TEST146[paper_build146].levels.duplicate();beam_left110=0.;_apply_owned_buffs()
 if is_instance_valid(encounter_hud): encounter_hud.announce(PAPER_TEST146[paper_build146].name,"左键射击／蓄力 · Q翻阅笔记 · Shift中止 · 1—6换组合",2.)
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  if event.physical_keycode==KEY_Q and active114:
   if is_instance_valid(paper_memories146): paper_memories146.request146()
   get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F9 and hill_ready146:
   paper_build146=(paper_build146+1)%PAPER_TEST146.size()
   if not active114 or not paper_trial129: paper_trial129=true;start_combat()
   else: apply_paper_build129()
   get_viewport().set_input_as_handled();return
  if paper_trial129 and active114 and event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_6:
   paper_build146=event.physical_keycode-KEY_1;apply_paper_build129();get_viewport().set_input_as_handled();return
 super._input(event)

func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if hill_ready146 and paper_trial129:
  encounter_hud.announce("纸飞机与课堂笔记 · "+str(PAPER_TEST146[paper_build146].name),"左键攻击／蓄力 · Q翻阅笔记 · Shift中止保留笔记 · 1—6直接换组合 · F9轮换",3.)
