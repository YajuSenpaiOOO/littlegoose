extends "res://scripts/world/woodland_world383.gd"
func _init() -> void:
 super._init();memory_save116="user://flight_combat385.cfg"
func goose_script() -> Script:return preload("res://scripts/combat/goose385.gd")
func test_config_path226() -> String:return "user://flight_loadout385.cfg"
func ordinary_record_folder347() -> String:return "user://flight_combat385_records"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 385 · 自由悬浮与速度上限")
func restart301() -> void:
 super.restart301()
 if ready350 and is_instance_valid(goose):
  goose.update_follow(0.,hero.global_position+Vector3(.8,0,.2),true)
  if is_instance_valid(skills110):skills110.reset_path168()
func _ready() -> void:
 await super._ready()
 hint288.text="385 自由悬浮与速度上限\n场景碰撞/绕障撤回 · 保留4.6m/s上限\nC装配 · F7重试 · F8人形/鸟形\nF4瞄准 · F6暂停 · 鸟形复制40%伤害"
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 super._add_actor_shadow(actor,sprite)
 if actor.get_script()==preload("res://scripts/combat/goose385.gd"):
  for child in actor.get_children():
   if child is MeshInstance3D and child.get("visual")==sprite:child.enabled=false;child.visible=false
