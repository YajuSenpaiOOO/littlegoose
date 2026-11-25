extends "res://scripts/world/woodland_world385.gd"
func _init() -> void:
 super._init();memory_save116="user://flight_combat386.cfg"
func goose_script() -> Script:return preload("res://scripts/combat/goose386.gd")
func test_config_path226() -> String:return "user://flight_loadout386.cfg"
func ordinary_record_folder347() -> String:return "user://flight_combat386_records"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 386 · 小黑鹅正面施法实战")
func _ready() -> void:
 await super._ready()
 hint288.text="386 小黑鹅正面施法实战\n朝南看抬手/笑脸释放 · 光束保持释放\nC装配 · F7重试 · F8人形/鸟形\nF4自动/鼠标瞄准 · F6暂停 · 4.6限速无碰撞"
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 super._add_actor_shadow(actor,sprite)
 if actor.get_script()==preload("res://scripts/combat/goose386.gd"):
  for child in actor.get_children():
   if child is MeshInstance3D and child.get("visual")==sprite:child.enabled=false;child.visible=false
func fire_at(target: Vector3) -> void:
 var before:=fired_count
 if is_instance_valid(goose):goose.prepare_fire386(target)
 super.fire_at(target)
 if is_instance_valid(goose):goose.finish_fire386(fired_count>before)
func _release_charged(target: Vector3,ratio: float) -> void:
 var before:=fired_count
 if is_instance_valid(goose):goose.prepare_fire386(target)
 super._release_charged(target,ratio)
 if is_instance_valid(goose):goose.finish_fire386(fired_count>before)
func emit_stream110(target: Vector3) -> void:
 var before:=shots.size()
 if is_instance_valid(goose):goose.prepare_fire386(target)
 super.emit_stream110(target)
 if is_instance_valid(goose):goose.finish_fire386(shots.size()>before,true)
