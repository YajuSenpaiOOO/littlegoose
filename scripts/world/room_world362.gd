extends "res://scripts/world/room_world357.gd"
var sleeping362:=false
var return362:=Vector3.ZERO
func room_script355() -> Script:return preload("res://scripts/room/room_shell362.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 362 · 分层手绘床")
 for node in title_panel.find_children("*","Label",true,false):node.text="362 · 分层手绘床\nWASD走动 · E 床边躺下/起床\nF10 空床/单人/双睡位被子\nF11 分层画稿/旧3D床 · F9 被子\nF8 睡位标记 · F2 昼夜 · F4 占地\nF5 占位 · F6 衣柜 · F7 归位 · F3 小院"
func set_sleep362(mode: int) -> void:
 mode=clampi(mode,0,2)
 if mode>0 and not sleeping362:return362=hero.global_position
 sleeping362=mode>0;hero.visible=not sleeping362;hero.set_physics_process(not sleeping362);hero.set_process(not sleeping362)
 hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.combat_impulse=Vector2.ZERO
 if not sleeping362:
  hero.global_position=return362;hero.reset_physics_interpolation()
 room.use_layers362=true;room.set_art356(true);room.set_mode362(mode)
 message355=["空床","单人躺卧试演 · E起床","双睡位被子预览 · 右侧角色待确认 · E起床"][mode];message_left355=5.
func interact355() -> void:
 if sleeping362:set_sleep362(0);return
 nearest355=choose355()
 if not nearest355.is_empty() and nearest355.id=="bed":set_sleep362(1);return
 super.interact355()
func reset355() -> void:
 if sleeping362:set_sleep362(0)
 super.reset355()
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  match event.physical_keycode:
   KEY_F10:set_sleep362((room.mode362+1)%3);get_viewport().set_input_as_handled();return
   KEY_F11:
    if sleeping362:set_sleep362(0)
    room.toggle_soft359();get_viewport().set_input_as_handled();return
   KEY_F9:room.cover_shown362=not room.cover_shown362;room.front362.visible=room.cover_shown362;get_viewport().set_input_as_handled();return
   KEY_F8:room.slot_debug362.visible=not room.slot_debug362.visible;get_viewport().set_input_as_handled();return
 super._input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if sleeping362:prompt.text="E · 起床"+("    右侧睡位预留，小黑鹅形象待确认" if room.mode362==2 else "")
