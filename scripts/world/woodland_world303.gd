extends "res://scripts/world/woodland_world302.gd"
var focus303 := "mixed"
func card_script301() -> Script:return preload("res://scripts/combat/paper_card303.gd")
func card_type301(index: int) -> String:return super.card_type301(index) if focus303=="mixed" else focus303
func active_cap301() -> int:return 2 if focus303=="mixed" else 1
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 303 · 纸火舌 / 提线怪兽 / 摆刺骑士")
func _ready() -> void:
 await super._ready()
 hint288.text="303 纸偶招式\nF8混合 / F9恐龙 / F10怪兽 / F11骑士"
func _process(delta: float) -> void:
 super._process(delta)
 if ready301:guide206.text=guide206.text.replace("302 悬浮纸偶","303 纸偶招式")
func _input(event: InputEvent) -> void:
 if ready301 and event is InputEventKey and event.pressed and not event.echo and (not is_instance_valid(console226) or not console226.visible):
  var modes={KEY_F8:"mixed",KEY_F9:"dinosaur",KEY_F10:"monster",KEY_F11:"knight"}
  if modes.has(event.physical_keycode):focus303=modes[event.physical_keycode];restart301();get_viewport().set_input_as_handled();return
 super._input(event)
