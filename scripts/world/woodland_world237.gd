extends "res://scripts/world/woodland_world236.gd"
var last_kind237 := "perfect"
var last_offset237 := 0.
func _init() -> void:
 super._init();rhythm236=preload("res://scripts/combat/music_clock237.gd").new()
 memory_save116="user://music237_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit237.gd").new()
func test_config_path226() -> String:return "user://boss_balance237.cfg"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 237 · 单轨音符 / 即时判定")
func _candy_script117() -> Script:return preload("res://scripts/combat/music_aim237.gd")
func flush_music236() -> void:
 for event in rhythm236.drain():
  last_kind237=event.kind;last_offset237=float(event.offset)
  if float(event.gain)<=0.:
   if is_instance_valid(candy117):candy117.result237(event.kind,float(event.offset))
   continue
  rhythm236.events.append(event)
  super.flush_music236()
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("236","237").replace("重合点击Perfect","音符到线点击")
func report_stats226() -> Dictionary:
 var report=super.report_stats226();report["music237"]={"good_window_ms":160,"perfect_window_ms":80,"misses":rhythm236.misses,"input":"immediate judgement; no early reservation"};return report
var suppress_auto237 := false
func _input(event: InputEvent) -> void:
 suppress_auto237=event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed
 super._input(event)
 suppress_auto237=false
func advance_music236() -> void:
 var now=Time.get_ticks_usec()
 var delta=0. if stamp236==0 else float(now-stamp236)/1000000.
 stamp236=now
 if not music_running236():return
 if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):fire_needs_release=false
 var old_beat=floori(rhythm236.time/.5)
 rhythm236.step(delta,fire_input_held() and not suppress_auto237,music_allowed236())
 if floori(rhythm236.time/.5)>old_beat and is_instance_valid(music_audio236):music_audio236.tick235()
 flush_music236()
func reset_music236() -> void:
 super.reset_music236()
 if is_instance_valid(candy117):
  candy117.text237="音符到线时点击";candy117.until237=0.;candy117.serial237=0
