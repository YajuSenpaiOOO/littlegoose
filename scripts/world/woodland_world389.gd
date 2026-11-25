extends "res://scripts/world/woodland_world388.gd"
const CHARGED_SPEED389:=1.20
func _init() -> void:
 super._init();memory_save116="user://flight_combat389.cfg"
 levels226={"homework":1,"slingshot":1};loadout_name226="双手蓄力施法";auto114=false
func goose_script() -> Script:return preload("res://scripts/combat/goose389.gd")
func test_config_path226() -> String:return "user://flight_loadout389.cfg"
func ordinary_record_folder347() -> String:return "user://flight_combat389_records"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 389 · 双手蓄力与弹弓加速")
func _ready() -> void:
 await super._ready()
 hint288.text="389 双手蓄力与弹弓加速\n按住左键蓄力 · 松开释放 · 正面张嘴出弹\n弹弓弹速+20% · C装配 · F4自动/鼠标瞄准\nF6暂停 · F7重试 · F8鸟形 · 4.6限速无碰撞"
func fire_input_held() -> bool:
 var held: bool=super.fire_input_held()
 # Auto aim can choose targets, but charge/release still belongs to the button.
 if is_instance_valid(buffs) and buffs.level("slingshot")>0 and not beam_active288():
  held387=held and raw_fire387();return held387
 return held
func charged_launch_speed39(ratio: float) -> float:return super.charged_launch_speed39(ratio)*CHARGED_SPEED389
func _step_fire_input(dt: float) -> void:
 var was_charging:=charge_active
 super._step_fire_input(dt)
 if not was_charging and charge_active and is_instance_valid(goose):
  goose.human383.charge_left389=0.;goose.human383.apply_pose386()
func _release_charged(target: Vector3,ratio: float) -> void:
 if not is_instance_valid(goose):super._release_charged(target,ratio);return
 var v=goose.human383
 var enabled: bool=buffs.level("slingshot")>0 and not beam_active288()
 var saved: bool=v.charge_emitting389;v.charge_emitting389=enabled
 var events: int=v.charged_events389
 var planes: int=paper_memories146.planes_launched146 if is_instance_valid(paper_memories146) else 0
 super._release_charged(target,ratio)
 # Plane capture retires temporary shots; still acknowledge its real launch.
 if enabled and v.charged_events389==events and is_instance_valid(paper_memories146) and paper_memories146.planes_launched146>planes:v.charged_fired389()
 v.charge_emitting389=saved
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 super._add_actor_shadow(actor,sprite)
 if actor.get_script()==preload("res://scripts/combat/goose389.gd"):
  for child in actor.get_children():
   if child is MeshInstance3D and child.get("visual")==sprite:child.enabled=false;child.visible=false
