extends "res://scripts/world/woodland_world354.gd"
func _init() -> void:
 super._init()
 memory_save116="user://flight_combat383.cfg"
 levels226={"homework":1};loadout_name226="飞行小黑鹅实战"
func goose_script() -> Script:return preload("res://scripts/combat/goose383.gd")
func test_config_path226() -> String:return "user://flight_loadout383.cfg"
func ordinary_record_folder347() -> String:return "user://flight_combat383_records"
func load_test226() -> void:
 if restore_flight_loadout383():super.load_test226()
func restore_flight_loadout383() -> bool:return false
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 383 · 四向飞行小黑鹅实战")
func _ready() -> void:
 await super._ready()
 hint288.text="383 四向飞行小黑鹅实战\nF8 人形/旧使魔 · F4 自动/鼠标瞄准\nWASD移动 · C装配 · F7重试\n主使魔四向，额外机队暂保留旧鹅形"
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 super._add_actor_shadow(actor,sprite)
 if actor.get_script()==preload("res://scripts/combat/goose383.gd"):
  for child in actor.get_children():
   if child is MeshInstance3D and child.get("visual")==sprite:child.enabled=false;child.visible=false
func preview_projectile_origin() -> Vector3:
 if is_instance_valid(goose) and goose.use_human383:return goose.muzzle()
 return super.preview_projectile_origin()
func _input(event: InputEvent) -> void:
 if ready350 and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F8 and not console226.visible:
  goose.use_human383=not goose.use_human383
  goose._update_follow_visual(goose.position+goose.last_shot_direction,false)
  for child in goose.get_children():
   if child is MeshInstance3D and child.get("visual")==goose.visual:child.enabled=not goose.use_human383
  get_viewport().set_input_as_handled();return
 super._input(event)
