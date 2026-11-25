extends "res://scripts/world/woodland_world387.gd"
func _init() -> void:
 super._init();memory_save116="user://flight_combat388.cfg"
func goose_script() -> Script:return preload("res://scripts/combat/goose388.gd")
func test_config_path226() -> String:return "user://flight_loadout388.cfg"
func ordinary_record_folder347() -> String:return "user://flight_combat388_records"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 388 · 四向基础施法")
func _ready() -> void:
 await super._ready()
 hint288.text="388 四向基础施法\n左右背面新增释放 · 连射/光束保持施法\nF4自动/鼠标瞄准 · 左键空射 · C装配\nF6暂停 · F7重试 · F8鸟形 · 4.6限速无碰撞"
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 super._add_actor_shadow(actor,sprite)
 if actor.get_script()==preload("res://scripts/combat/goose388.gd"):
  for child in actor.get_children():
   if child is MeshInstance3D and child.get("visual")==sprite:child.enabled=false;child.visible=false
