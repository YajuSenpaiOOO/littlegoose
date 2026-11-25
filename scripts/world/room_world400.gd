extends "res://scripts/world/room_world399.gd"
var warm400:=true
var window400: SpotLight3D
var lamps400: Array=[]
func room_script355() -> Script:return preload("res://scripts/room/room_shell400.gd")
func _ready() -> void:
 await super._ready()
 for light in room.find_children("*","OmniLight3D",true,false):lamps400.append({"light":light,"energy":light.light_energy})
 window400=SpotLight3D.new();window400.name="WindowPool400";window400.position=Vector3(-.5,2.8,-4.15)
 window400.light_color=Color("fff0d6");window400.spot_range=8.;window400.spot_angle=48.;window400.spot_angle_attenuation=1.4;window400.light_energy=1.1
 add_child(window400);window400.look_at(Vector3(-.3,.1,.5),Vector3.UP)
 apply400()
 DisplayServer.window_set_title("小白鹅 · 400 · 窗光与梁角藤蔓")
 help367="400 · 窗光与梁角藤蔓\n4光照新旧 · 5藤蔓开关 · 3木结构\nWASD走动 · F2昼夜 · F12跟随\n1衣柜 · 2洗漱 · G书桌 · F3出门"
 refresh367()
func apply400() -> void:
 if not is_instance_valid(window400):return
 if warm400:
  sun.light_color=Color("ffe9ce");sun.light_energy=.035 if night355 else .46;sun.shadow_opacity=.68
  environment.ambient_light_color=Color("e4e3d9");environment.ambient_light_energy=.29 if night355 else .53
  fill355.light_energy=.12 if night355 else .24
 else:
  sun.light_color=Color("ffe1aa");sun.light_energy=.08 if night355 else .72;sun.shadow_opacity=1.
  environment.ambient_light_color=Color("eadbba");environment.ambient_light_energy=.42 if night355 else .70
  fill355.light_energy=.18 if night355 else .28
 window400.light_energy=1.1 if warm400 and not night355 else 0.
 for row in lamps400:row.light.light_energy=row.energy*(.78 if warm400 else 1.)
func set_night355(value: bool) -> void:
 super.set_night355(value);apply400()
func refresh367() -> void:
 if is_instance_valid(label367) and is_instance_valid(room):label367.text=help367+"\n当前："+("窗边主光 / 中性柔暗" if warm400 else "399原光照")+(" · 有藤蔓" if room.vines400.visible else " · 无藤蔓")
func _input(event: InputEvent) -> void:
 if ready355 and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_4:warm400=not warm400;apply400();refresh367();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_5:room.set_vines400(not room.vines400.visible);refresh367();get_viewport().set_input_as_handled();return
 super._input(event)
