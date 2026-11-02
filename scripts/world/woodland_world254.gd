extends "res://scripts/world/woodland_world253.gd"
func _lighting_script191() -> Script:return preload("res://scripts/art/forest_lighting254.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 254 · 森林灯芯 / 暖色小光池")
func _ready() -> void:
 await super._ready()
 # A lighting preview should open at the reported fixture, with neutral native actors.
 set_lighting252(1)
 go253(3)
func positions253() -> Array:
 return super.positions253()+[FOREST188.CENTER+Vector2(4.8,-3.1)]
func go253(index: int) -> void:
 location253=posmod(index,4)
 if active114:finish251(false)
 _teleport15(positions253()[location253]);hero.velocity=Vector3.ZERO;hero.combat_impulse=Vector2.ZERO
 forest_mood188.update188(0.);lighting191._process(0.);place_sister253(0.)
func _input(event: InputEvent) -> void:
 if ready253 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and event.physical_keycode==KEY_F8:
  go253(location253+1);get_viewport().set_input_as_handled();return
 super._input(event)
func location_label253() -> String:return "吊床小灯" if location253==3 else LOCATIONS253[location253]
func _process(delta: float) -> void:
 super._process(delta)
 if ready253:guide206.text=guide206.text.replace("253 主角＋姐姐","254 森林暖灯")
