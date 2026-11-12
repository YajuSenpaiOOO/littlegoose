extends "res://scripts/world/woodland_world291.gd"
var stage297: Node3D
var available297 := false
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 297 · 抛书开场 / 纸城堡展开试演")
func stage_script297() -> Script:return preload("res://scripts/art/paper_stage297.gd")
func stage_anchor297() -> Vector2:return meadow.landmarks.grove+Vector2(0,-1.)
func preview_spawn297() -> Vector2:return meadow.landmarks.grove+Vector2(0,4.)
func preview_hint297() -> String:return "297 纸剧场开场试演　F12播放 / 重播　F3回院\n纸妹妹与主角同高1.6；当前只看演出与布景，还没有Boss招式"
func _ready() -> void:
 await super._ready()
 mode264="away";active114=false;wave_state="waiting";clear251()
 if is_instance_valid(cushion265):cushion265.queue_free();cushion265=null
 speech112.dismiss()
 var at: Vector2=stage_anchor297()
 stage297=stage_script297().new();stage297.battle=self;stage297.position=Vector3(at.x,floor_height(at)+.03,at.y);add_child(stage297)
 _teleport15(preview_spawn297());available297=true
 hint288.text=preview_hint297()
 state_hud288.hide()
 stage297.start()
func _physics_process(delta: float) -> void:
 if available297:
  # Exploration only; do not run the inherited Tuantuan encounter scheduler.
  return
 super._physics_process(delta)
func _input(event: InputEvent) -> void:
 if available297 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_F12:
   if not stage297.playing:_teleport15(preview_spawn297())
   stage297.start();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F3:stage297.cancel()
  if event.physical_keycode in [KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_E,KEY_Q,KEY_F2,KEY_C]:
   get_viewport().set_input_as_handled();return
 super._input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if available297:
  guide206.text="纸剧场开场试演 · F12重播\n本版没有Boss战斗、掉落或正式进度"
func _exit_tree() -> void:
 if is_instance_valid(stage297):stage297.cancel()
 super._exit_tree()
