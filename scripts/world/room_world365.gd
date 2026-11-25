extends "res://scripts/world/room_world364.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell365.gd")
func _ready() -> void:
 await super._ready()
 DisplayServer.window_set_title("小白鹅 · 365 · 奶油床单与褶边床裙")
 for node in title_panel.find_children("*","Label",true,false):node.text=node.text.replace("364 · 手绘3D床头＋左枕样件","365 · 床单与褶边床裙").replace("其余床架/床垫是素色承托，非整床成品","V 床单床裙/旧承托 · 厚被子尚未制作")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_V:
  room.set_linen365(not room.show_linen365);get_viewport().set_input_as_handled();return
 super._input(event)
func set_detail364(value: bool) -> void:
 super.set_detail364(value)
 if value:
  var center: Vector3=room.item356("bed").root.global_position+Vector3(0.,1.02,-.20)
  camera.global_position=center+camera.global_basis.z*6.8
  camera.reset_physics_interpolation()
