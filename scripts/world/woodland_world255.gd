extends "res://scripts/world/woodland_world254.gd"
var aligned255 := true
func _porch_script() -> Script:return preload("res://scripts/art/woodland_palette255.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 255 · 主角与姐姐 / 环境调色对齐")
func _ready() -> void:
 await super._ready()
 apply_actor255()
func apply_actor255() -> void:
 if not ready253:return
 var tint=porch49.actor_tint255(rig220.person_at) if aligned255 else Color.WHITE
 for card in [rig220.standing,rig220.seated]:card.modulate=tint
func _input(event: InputEvent) -> void:
 if ready253 and event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and event.physical_keycode==KEY_F10:
  aligned255=not aligned255;apply_actor255();get_viewport().set_input_as_handled();return
 super._input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if not ready253:return
 apply_actor255()
 guide206.text=guide206.text.replace("254 森林暖灯","255 两人环境调色").replace(" / F10落地圈","")
 guide206.text+="\nF10 姐姐环境调色："+("与主角同规则" if aligned255 else "254原样（未接入）")
