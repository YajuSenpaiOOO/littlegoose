extends "res://scripts/world/woodland_world234.gd"
var rhythm236=preload("res://scripts/combat/music_clock235.gd").new()
var music_audio236: Node
var flash236 := 0.
var judgment236 := "跟着外框点击"
var rhythm_damage236 := 0.
var active_scale236 := 1.
var stamp236 := 0
func _init() -> void:
 super._init();memory_save116="user://music236_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit235.gd").new()
 levels226={"music_class":1};loadout_name226="乐器课原型"
func balance_profile226() -> Script:return preload("res://scripts/combat/balance_profile235.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 236 · 乐器课 / 逐发旋律 / Perfect反馈")
func test_config_path226() -> String:return "user://boss_balance236.cfg"
func load_test226() -> void:
 var cfg=ConfigFile.new()
 if cfg.load(test_config_path226())!=OK:return
 var saved=cfg.get_value("test","levels",{})
 if saved is Dictionary and balance_profile226().error(saved)=="":levels226=saved.duplicate(true);loadout_name226=name_for226(levels226)
 cat_health226=clampf(float(cfg.get_value("test","cat_hp",100.)),10.,10000.);bat_health226=clampf(float(cfg.get_value("test","bat_hp",80.)),10.,10000.)
func _candy_script117() -> Script:return preload("res://scripts/combat/music_aim236.gd")
func _ready() -> void:
 await super._ready()
 music_audio236=preload("res://scripts/combat/music_audio236.gd").new();add_child(music_audio236)
func music_enabled236() -> bool:return buffs.level("music_class")>0
func music_running236() -> bool:
 return ready228 and music_enabled236() and stage225=="battle" and active114 and not combat_paused and not result_open and player_hp>0. and wave_state=="fighting"
func music_allowed236() -> bool:
 return hero.controls_enabled and hero.dash_left<=0. and not hero.guarding109 and not hero.knocked_down and not fire_needs_release and (not is_instance_valid(paper_memories146) or not paper_memories146.writing146)
func reset_music236() -> void:
 rhythm236.reset();stamp236=Time.get_ticks_usec();flash236=0.;judgment236="跟着外框点击";rhythm_damage236=0.
 if is_instance_valid(music_audio236):music_audio236.cursor236=0
 if is_instance_valid(candy117):candy117.consumed236=-1;candy117.pulses236.clear();candy117.click_until236=-1.
func apply_levels226() -> void:
 super.apply_levels226();reset_music236()
func start_battle225(keep_player: bool) -> void:
 super.start_battle225(keep_player);reset_music236()
func _tag_shot110(shot: Dictionary) -> void:
 if not music_enabled236():super._tag_shot110(shot);return
 shot.split_depth110=0 # Disable the obsolete random +50% note modifier.
func _input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed and music_running236() and music_allowed236():
  if is_instance_valid(candy117):candy117.click236()
  advance_music236();rhythm236.press();flush_music236();get_viewport().set_input_as_handled();return
 super._input(event)
func _step_fire_input(delta: float) -> void:
 if not music_enabled236():super._step_fire_input(delta)
func advance_music236() -> void:
 var now=Time.get_ticks_usec()
 var delta=0. if stamp236==0 else float(now-stamp236)/1000000.
 stamp236=now
 if not music_running236():return
 if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):fire_needs_release=false
 var old_beat=floori(rhythm236.time/.5)
 rhythm236.step(delta,fire_input_held(),music_allowed236())
 if floori(rhythm236.time/.5)>old_beat and is_instance_valid(music_audio236):music_audio236.tick235()
 flush_music236()
func flush_music236() -> void:
 for event in rhythm236.drain():
  var target=paper_aim146()
  if not target.is_finite():continue
  var before=shots.size();var before_flights=music_flights236()
  var budget_scale=music_budget_scale236()*float(event.gain)
  # Snapshot final damage once, including the current combo's original cadence.
  active_scale236=budget_scale
  super.fire_at(target)
  active_scale236=1.
  for i in range(before,shots.size()):
   var amount=damage_for_shot(shots[i])*budget_scale
   shots[i].fixed_damage110=amount;shots[i].final_damage234=true
   rhythm_damage236+=amount
  if shots.size()==before:
   if music_flights236()<=before_flights:continue
   rhythm_damage236+=music_plane_budget236()
  music_attack_finished236(before,target)
  if is_instance_valid(candy117):candy117.hit236(int(event.beat),bool(event.perfect))
  flash236=.26;judgment236="Perfect ×1.4" if event.perfect else "普通 ×1.0"
  if is_instance_valid(music_audio236):music_audio236.note236(int(event.beat),bool(event.perfect))
func _process(delta: float) -> void:
 super._process(delta)
 advance_music236()
 if not ready228:return
 guide206.text=guide206.text.replace("234","236")
 if music_enabled236():guide206.text+="\n乐器课 120 BPM · 重合点击Perfect · 按住普通连奏"
 if not combat_paused:flash236=maxf(0.,flash236-delta)
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["music236"]={"bpm":120,"window_ms":80,"perfect_gain":1.4,"perfects":rhythm236.perfects,"normal":rhythm236.normals,"emitted_damage_budget":rhythm_damage236};return report
func _shot_sound_enabled110() -> bool:
 return false if music_enabled236() else super._shot_sound_enabled110()
func snapshot_packet146(target: Vector3,charged: bool,ratio: float,retire_all := false,carrier := true) -> Dictionary:
 var packet=super.snapshot_packet146(target,charged,ratio,retire_all,carrier)
 if music_enabled236() and not packet.is_empty():
  for spec in packet.specs:spec.damage=float(spec.damage)*active_scale236
 return packet

func music_budget_scale236() -> float:return .5/maxf(.001,attack_cooldown())
func music_flights236() -> int:return 0
func music_plane_budget236() -> float:return 0.

func music_attack_finished236(_before: int,_target: Vector3) -> void:pass
