extends "res://scripts/world/woodland_world383.gd"
func _init() -> void:
 super._init();memory_save116="user://flight_combat384.cfg"
func goose_script() -> Script:return preload("res://scripts/combat/goose384.gd")
func test_config_path226() -> String:return "user://flight_loadout384.cfg"
func ordinary_record_folder347() -> String:return "user://flight_combat384_records"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 384 · 飞行限速与场景碰撞")
func restart301() -> void:
 super.restart301()
 # The forest trial teleports the hero after its parent reset. Reset the companion
 # at that explicit scene transition, never use teleporting to catch up in play.
 if ready350 and is_instance_valid(goose) and is_instance_valid(goose.body384):
  goose.update_follow(0.,hero.global_position+Vector3(.8,0,.2),true)
  if is_instance_valid(skills110):skills110.reset_path168()
func _ready() -> void:
 await super._ready()
 hint288.text="384 飞行限速与场景碰撞\n主小黑鹅限速4.6m/s · 胶囊碰撞/绕障\nC装配（纸杯电话/多鹅）· F7重试\nF8人形/鸟形 · F4瞄准 · F6暂停\n复制使魔保留鸟形与40%伤害"
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 super._add_actor_shadow(actor,sprite)
 if actor.get_script()==preload("res://scripts/combat/goose384.gd"):
  for child in actor.get_children():
   if child is MeshInstance3D and child.get("visual")==sprite:child.enabled=false;child.visible=false
