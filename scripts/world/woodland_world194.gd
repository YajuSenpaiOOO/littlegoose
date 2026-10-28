extends "res://scripts/world/woodland_world193.gd"
func _init() -> void:
 super._init();memory_save116="user://forest194_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 194 · 双生树吊床 / 林边层次 / 慢半拍呜喵")
func _forest_art_script188() -> Script: return preload("res://scripts/art/forest_art194.gd")
func _lighting_script191() -> Script: return preload("res://scripts/art/forest_lighting194.gd")
func _ready() -> void:
 await super._ready()
 forest188.pop_age194=-1.;forest188.pop_cooldown194=0.;forest188.pop_armed194=true;forest188.pop_count194=0
 forest188.pop_board194.hide();forest188.pop_spider194.hide();forest188.pop_words194.hide()
 _teleport15(preload("res://scripts/world/forest_plan188.gd").CENTER+Vector2(14.8,7.8))
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("193 "):
     child.text="194 双生树吊床 / 林边层次 / 慢半拍呜喵\nF8 样板 / F6 入口 / F7 小屋 / F3 小院\nF9 吊床角 / F10 调色 / F11 小径 / F12 灯光"
func _input(event: InputEvent) -> void:
 if forest_ready188 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F8:
  _teleport15(preload("res://scripts/world/forest_plan188.gd").CENTER+Vector2(14.8,7.8))
  forest188.pop_age194=-1.;forest188.pop_cooldown194=0.;forest188.pop_armed194=true
  forest188.pop_board194.hide();forest188.pop_spider194.hide();forest188.pop_words194.hide()
  get_viewport().set_input_as_handled();return
 if forest_ready188 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F9:
  _teleport15(preload("res://scripts/world/forest_plan188.gd").CENTER+Vector2(7.6,-1.8));get_viewport().set_input_as_handled();return
 super._input(event)
