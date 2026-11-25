extends "res://scripts/world/room_world396.gd"
var close398:=""
var before_close398:=Transform3D.IDENTITY
func room_script355() -> Script:return preload("res://scripts/room/room_shell398.gd")
func _ready() -> void:
 await super._ready();DisplayServer.window_set_title("小白鹅 · 398 · 衣柜与洗漱台")
 help367="398 · 衣柜与洗漱台（书桌沿用A）\nM柜台新旧 · 1衣柜近看 · 2洗漱台近看\nWASD走动 · F12固定/跟随 · F2昼夜\nG书桌 · Y茶桌 · E查看 · F3出门"
 refresh367()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n当前："+("手绘实体柜台 / 低纹理噪点" if room.use_cabinets398 else "原衣柜与洗漱台对照")
func close_cabinet398(id: String) -> void:
 if close398==id:
  close398="";camera.global_transform=before_close398
 elif id.is_empty():
  if not close398.is_empty():camera.global_transform=before_close398;close398=""
 else:
  close_desk395(false);close_tea396(false)
  if close398.is_empty():before_close398=camera.global_transform
  close398=id;set_follow363(false)
  camera.global_basis=before_close398.basis
  if id=="wash":camera.rotation_degrees=Vector3(-25.,-35.,0.)
  var at:=Vector3(2.15,1.1,-3.25) if id=="wardrobe" else Vector3(5.65,1.,-.05)
  camera.global_position=at+camera.global_basis.z*(6.5 if id=="wardrobe" else 5.5)
 camera.reset_physics_interpolation()
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_M:
   room.set_cabinets398(not room.use_cabinets398);refresh367();get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_1,KEY_2]:
   close_cabinet398("wardrobe" if event.physical_keycode==KEY_1 else "wash");get_viewport().set_input_as_handled();return
  if event.physical_keycode in [KEY_G,KEY_Y,KEY_F12] and not close398.is_empty():close_cabinet398("")
 super._input(event)
