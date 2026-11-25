extends "res://scripts/world/room_world367.gd"
var legacy_sleep368:=false
func room_script355() -> Script:return preload("res://scripts/room/room_shell368.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 368 · 双枕与3D床躺卧")
 help367="368 · 双枕与3D床躺卧\nE 床边躺下/起床 · F10 状态预览\nB 新3D床躺卧 / 旧2D躺卧\nC 近看 · F12 跟随 · F11 3D/2D床\nQ 被子 · G 搭毯 · V 床单床裙\nF9 素色 · F2 昼夜 · F4 占地\nF7 归位 · F3 小院"
 refresh367()
func set_sleep362(mode: int) -> void:
 mode=clampi(mode,0,2)
 if legacy_sleep368:
  room.set_occupied368(false);super.set_sleep362(mode);return
 var was_sleeping:=sleeping362
 if mode>0 and not was_sleeping:return362=hero.global_position
 sleeping362=mode>0;hero.visible=not sleeping362;hero.set_physics_process(not sleeping362);hero.set_process(not sleeping362)
 hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.combat_impulse=Vector2.ZERO
 if not sleeping362 and was_sleeping:hero.global_position=return362;hero.reset_physics_interpolation()
 room.set_art356(true);room.set_craft364(true);room.mode362=mode;room.set_occupied368(sleeping362)
 message355="右侧枕位预留，未加入小黑鹅角色" if mode==2 else ("E · 起床" if mode==1 else "空床双枕")
 message_left355=4.
func follow_target363() -> Vector3:
 if sleeping362 and not legacy_sleep368:
  var at: Vector3=room.head_anchor368.global_position
  return camera_home363+Vector3(clampf(at.x*.65,-2.1,2.1),0.,clampf((at.z+.35)*.65,-1.35,1.35))
 return super.follow_target363()
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_B:
  var mode: int=room.mode362
  if sleeping362:set_sleep362(0)
  legacy_sleep368=not legacy_sleep368
  if mode>0:set_sleep362(mode)
  message355="躺卧对照："+("旧2D分层床" if legacy_sleep368 else "新3D床与压枕");message_left355=4.
  get_viewport().set_input_as_handled();return
 super._input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if sleeping362 and not legacy_sleep368:prompt.text="E · 起床 · 主角躺卧 / 左枕受压"+(" · 右枕位预留" if room.mode362==2 else "")
