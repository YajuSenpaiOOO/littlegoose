extends "res://scripts/world/woodland_world248.gd"
var show_landing249 := false
func _init() -> void:
 super._init();memory_save116="user://tuantuan_boss249_preview.cfg"
func boss_script247() -> Script:return preload("res://scripts/combat/tuantuan_boss249.gd")
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 249 · 弹反只反跳一次 / 地影读招")
func _input(event: InputEvent) -> void:
 if ready247 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F10:
  show_landing249=not show_landing249
  if is_instance_valid(boss247):
   boss247.marker247.visible=show_landing249 and boss247.phase247 in ["flight","pounce"]
   if boss247.marker247.visible:boss247.draw_marker247()
  get_viewport().set_input_as_handled();return
 super._input(event)
func _unhandled_input(event: InputEvent) -> void:
 if ready247 and event is InputEventKey and event.physical_keycode==KEY_F10:return
 super._unhandled_input(event)
func _process(delta: float) -> void:
 super._process(delta)
 if not ready247:return
 guide247.text=guide247.text.replace("248 团团Boss · 急眼连砸","249 团团Boss · 地影读招").replace("弹反后反向续跳、每次加2砸（上限11）","弹反只反跳一次，再追主角；每次加2砸（上限11）")
 guide247.text+="\nF10 落地圈对照："+("开" if show_landing249 else "关（默认）")
