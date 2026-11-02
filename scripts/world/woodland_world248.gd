extends "res://scripts/world/woodland_world247.gd"
var impact248 := 0
func _init() -> void:
 super._init();memory_save116="user://tuantuan_boss248_preview.cfg"
func boss_script247() -> Script:return preload("res://scripts/combat/tuantuan_boss248.gd")
func boss_size247() -> float:return 2.15
func _encounter_hud_script37() -> Script:return preload("res://scripts/combat/boss_hud248.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 248 · 急眼连砸 / 弹反反向加弹")
func reset_impact248() -> void:
 impact248=0;impact_clock.clear();stop_until=0.;stop_gate=0.;stop_duration=0.;punch=0.;dodge_zoom=0.;closeup_started=-1.;closeup_weight=0.;trauma=0.
 if is_instance_valid(camera):
  camera.h_offset=0.;camera.v_offset=0.
  camera_gain=(LEGACY_BASE_ZOOM+_base_zoom_delta())/LEGACY_BASE_ZOOM
  camera.fov=rad_to_deg(2.*atan(tan(deg_to_rad(21.))/camera_gain))
func begin247() -> void:
 reset_impact248();super.begin247();reset_impact248()
func finish247(victory: bool) -> void:
 super.finish247(victory);reset_impact248()
func boss_impact248(_contact: Vector3) -> void:
 # Use the existing real-time effect scheduler, not uncancellable timers.
 impact248+=1;impact_clock.cancel_pending("parry");impact_clock.cancel_pending("boss248")
 hitstop(.11,true)
 impact_clock.add(.28,.30,.11,"boss248")
 punch=maxf(punch,1.05);trauma=minf(1.,trauma+.25)
func _input(event: InputEvent) -> void:
 if ready247 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6:
  # Pause never leaves a real-time delayed slow-motion event armed.
  reset_impact248()
 super._input(event)
func _exit_tree() -> void:
 impact_clock.clear();Engine.time_scale=1.;super._exit_tree()
func _process(delta: float) -> void:
 super._process(delta)
 if not ready247:return
 guide247.text=guide247.text.replace("247 团团Boss · 弹力三连跳原型","248 团团Boss · 急眼连砸")
 if is_instance_valid(boss247):
  var labels={"angry":"急眼跺跳","deflected":"弹反！反向蓄弹"}
  if labels.has(boss247.phase247):guide247.text=guide247.text.replace("休息",labels[boss247.phase247])
  guide247.text+="\n连砸 %d / %d · 弹反后反向续跳、每次加2砸（上限11）"%[mini(boss247.jump247+1,boss247.total248),boss247.total248]
