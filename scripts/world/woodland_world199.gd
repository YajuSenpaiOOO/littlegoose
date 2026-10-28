extends "res://scripts/world/woodland_world198.gd"
var relations199: Node
func _init() -> void:
 super._init();memory_save116="user://forest199_preview.cfg"
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 199 · 整件遮挡 / 同步树影 / 小径视线")
func _relations_script199() -> Script: return preload("res://scripts/art/prop_relations199.gd")
func _ready() -> void:
 await super._ready()
 relations199=_relations_script199().new();relations199.world=self;add_child(relations199)
 for layer in get_children():
  if layer is CanvasLayer:
   for child in layer.get_children():
    if child is Label and child.text.begins_with("198 "):
     child.text=child.text.replace("198 竖直主角 / 材质受光 · 关系修整基线","199 整件遮挡 / 同步树影 / 小径视线")
