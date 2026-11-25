extends "res://scripts/world/room_world362.gd"
# Optional translation-only follow, fixed pitch/yaw/FOV. Default remains the accepted fixed shot.
var follow363:=false
var camera_home363:=Vector3.ZERO
var camera_ready363:=false
var follow_label363: Label
func room_script355() -> Script:return preload("res://scripts/room/room_shell363.gd")
func _ready() -> void:
 await super._ready()
 camera_home363=camera.global_position;camera_ready363=true
 DisplayServer.window_set_title("小白鹅 · 363 · 室内跟随镜头对照")
 for node in title_panel.find_children("*","Label",true,false):
  node.text=node.text.replace("362 · 分层手绘床","363 · 跟随镜头对照")
  node.text+="\nF12 固定 / 跟随镜头（默认固定）"
 follow_label363=Label.new();follow_label363.position=Vector2(18,230);follow_label363.add_theme_font_size_override("font_size",18);follow_label363.add_theme_color_override("font_outline_color",Color(.1,.08,.06));follow_label363.add_theme_constant_override("outline_size",5);title_panel.get_parent().add_child(follow_label363)
func set_follow363(value: bool) -> void:
 follow363=value
 if camera_ready363 and not value:
  camera.global_position=camera_home363;camera.reset_physics_interpolation()
func follow_target363() -> Vector3:
 var at: Vector3=hero.global_position
 if sleeping362:at=room.anchors362[0].global_position
 return camera_home363+Vector3(clampf(at.x*.65,-2.1,2.1),0.,clampf((at.z+.35)*.65,-1.35,1.35))
func _process(delta: float) -> void:
 super._process(delta)
 if not camera_ready363:return
 if follow363:camera.global_position=camera.global_position.lerp(follow_target363(),1.-exp(-4.*delta))
 follow_label363.visible=title_panel.visible
 follow_label363.text="镜头："+("平滑跟随 · 透视25° / 42FOV" if follow363 else "固定 · 透视25° / 42FOV")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F12:
  set_follow363(not follow363);get_viewport().set_input_as_handled();return
 super._input(event)
