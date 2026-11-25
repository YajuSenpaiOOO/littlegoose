extends "res://scripts/world/woodland_world386.gd"
var held387:=false
var aim_query387:=false
func _init() -> void:
 super._init();memory_save116="user://flight_combat387.cfg"
func goose_script() -> Script:return preload("res://scripts/combat/goose387.gd")
func _skills_script110() -> Script:return preload("res://scripts/combat/battle_skills387.gd")
func test_config_path226() -> String:return "user://flight_loadout387.cfg"
func ordinary_record_folder347() -> String:return "user://flight_combat387_records"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 387 · 羽毛弹与自由空射")
func _ready() -> void:
 await super._ready()
 hint288.text="387 羽毛弹与自由空射\n无锁定也可左键朝鼠标开火 · 基础连射保持施法\nF4自动/鼠标瞄准 · C装配 · F7重试\nF6暂停 · F8鸟形 · 4.6限速无碰撞"
func raw_fire387() -> bool:return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
func fire_input_held() -> bool:
 var native: bool=super.fire_input_held()
 var allowed: bool=active114 and not combat_paused and is_instance_valid(hero) and hero.controls_enabled and not hero.guarding109 and not hero.knocked_down and (not is_instance_valid(paper_memories146) or not paper_memories146.writing146)
 held387=native or (allowed and raw_fire387())
 return held387
func projectile_origin() -> Vector3:
 # Cursor picking/assist use a stable plane. Animated palm is emission only.
 if aim_query387 and is_instance_valid(goose):return goose.global_position+Vector3.UP*.44
 return super.projectile_origin()
func _refresh_aim114(cursor: Vector2) -> void:
 aim_query387=true;super._refresh_aim114(cursor);aim_query387=false
func feather_shot387(shot: Dictionary) -> bool:
 return not shot.get("stream110",false) and not shot.get("sword153",false) and not shot.get("charged",false) and not shot.get("note110",false)
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 super._add_actor_shadow(actor,sprite)
 if actor.get_script()==preload("res://scripts/combat/goose387.gd"):
  for child in actor.get_children():
   if child is MeshInstance3D and child.get("visual")==sprite:child.enabled=false;child.visible=false
