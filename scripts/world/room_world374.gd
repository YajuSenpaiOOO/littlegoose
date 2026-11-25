extends "res://scripts/world/room_world373.gd"
func companion_script373() -> Script:return preload("res://scripts/combat/goose_follow374.gd")
func room_script355() -> Script:return preload("res://scripts/room/room_shell374.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 374 · 盖被收发与侧面摆臂")
 help367=help367.replace("373 · 小黑鹅四向移动与跟随","374 · 盖被收发与侧面摆臂")+"\nT 盖被修复/旧遮挡对照 · Q 掀被\nU 侧面慢放：左/右/关闭"
 refresh367()

func _input(event: InputEvent) -> void:
 if ready355 and is_instance_valid(companion373) and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_U:
  var mode: int=(companion373.preview374+1)%3
  if mode>0:reset355();companion373.hold373();set_pair372(true)
  else:companion373.resume373()
  companion373.preview374=mode
  message355=["恢复正常跟随","左侧摆臂慢放","右侧摆臂慢放"][mode];message_left355=4.
  get_viewport().set_input_as_handled();return
 super._input(event)
func reset355() -> void:
 super.reset355()
 if is_instance_valid(companion373):companion373.preview374=0
