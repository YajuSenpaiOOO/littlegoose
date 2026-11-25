extends "res://scripts/world/woodland_world389.gd"
func _init() -> void:
 super._init();memory_save116="user://flight_combat390.cfg"
func goose_script() -> Script:return preload("res://scripts/combat/goose390.gd")
func test_config_path226() -> String:return "user://flight_loadout390.cfg"
func ordinary_record_folder347() -> String:return "user://flight_combat390_records"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 390 · 四向蓄力与后冲")
func charge_tint39() -> Color:return Color.WHITE
func _release_charged(target: Vector3,ratio: float) -> void:
 var before: int=goose.human383.charged_events389 if is_instance_valid(goose) else 0
 super._release_charged(target,ratio)
 if is_instance_valid(goose) and goose.human383.charged_events389>before:
  goose.charged_impulse390(target-goose.global_position,ratio)
func _ready() -> void:
 await super._ready()
 hint288.text="390 四向蓄力与后冲\n按住左键蓄力晃动 · 松开后冲 · 取消红温\n弹弓弹速+20% · C装配 · F4瞄准\nF6暂停 · F7重试 · F8鸟形 · 4.6限速无碰撞"
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 super._add_actor_shadow(actor,sprite)
 if actor.get_script()==preload("res://scripts/combat/goose390.gd"):
  for child in actor.get_children():
   if child is MeshInstance3D and child.get("visual")==sprite:child.enabled=false;child.visible=false
