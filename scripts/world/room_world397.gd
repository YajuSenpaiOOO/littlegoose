extends "res://scripts/world/room_world396.gd"
func room_script355() -> Script:return preload("res://scripts/room/room_shell397.gd")
func _ready() -> void:
 await super._ready();DisplayServer.window_set_title("小白鹅 · 397 · 书桌画风A/B")
 help367="397 · 书桌画风A/B\nM手绘/简化像素 · G书桌近看\nF12固定/跟随 · WASD走动 · F2昼夜\nT实体/旧插画 · Y茶桌近看 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n书桌："+("B 简化像素材质" if room.pixel397 else "A 原手绘材质")+("" if room.use_solids396 else "（当前显示旧插画）")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_M:
  if not room.use_solids396:room.set_solids396(true)
  room.set_pixel397(not room.pixel397);refresh367();get_viewport().set_input_as_handled();return
 super._input(event)
