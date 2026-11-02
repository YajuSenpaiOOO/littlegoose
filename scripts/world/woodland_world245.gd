extends "res://scripts/world/woodland_world244.gd"
@export var relay_gain245 := .35
var relay245: Node3D
var last_packet245 := {}
var relaying245 := false
var captures245 := 0
var echoes245 := 0
var generation245 := 1000000
func _init() -> void:
 super._init();memory_save116="user://relay245_preview.cfg";memory_kit116=preload("res://scripts/combat/memory_kit245.gd").new()
 levels226={"red_banner":1,"music_class":1};loadout_name226="接力旗原型"
func balance_profile226() -> Script:return preload("res://scripts/combat/balance_profile245.gd")
func test_config_path226() -> String:return "user://boss_balance245.cfg"
func load_test226() -> void:
 if FileAccess.file_exists(test_config_path226()):super.load_test226()
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 245 · 铅笔接力旗 / 动作原型")
func _ready() -> void:
 await super._ready();relay245=relay_script245().new();relay245.battle=self;add_child(relay245)
func damage_for_shot(shot: Dictionary) -> float:
 # The new relay replaces the old combo +40% passive, including all snapshots.
 var saved=buffs.levels.get("red_banner",0);buffs.levels.erase("red_banner")
 var result=super.damage_for_shot(shot)
 if saved>0:buffs.levels.red_banner=saved
 return result
func on_dash_started() -> void:
 super.on_dash_started()
 if buffs.level("red_banner")>0 and active114 and stage225=="battle" and is_instance_valid(relay245) and can_plant245():
  relay245.plant245(hero.global_position,relay_ground245(hero.global_position))
func relay_ground245(at: Vector3) -> String:
 var ray=PhysicsRayQueryParameters3D.create(at+Vector3.UP*2.,at+Vector3.DOWN*3.,1)
 var hit=get_world_3d().direct_space_state.intersect_ray(ray)
 if not hit.is_empty() and hit.collider.has_meta("ground_material"):return str(hit.collider.get_meta("ground_material"))
 return "soil_grass"
func snapshot_packet146(target: Vector3,charged: bool,ratio: float,retire_all := false,carrier := true) -> Dictionary:
 var packet=super.snapshot_packet146(target,charged,ratio,retire_all,carrier)
 last_packet245=packet.duplicate(true)
 return packet
func pack_shots245(before: int) -> Dictionary:
 var specs=[]
 for i in range(before,shots.size()):
  var shot: Dictionary=shots[i]
  if int(shot.get("goose_source168",0))!=0:continue
  specs.append({"speed":Vector3(shot.velocity).length(),"angle":0.,"life":shot.life,"damage":damage_for_shot(shot),"gain":shot.art.scale_gain,"charged":shot.get("charged",false),"piercing110":shot.get("piercing110",false),"note110":shot.get("note110",false),"stream110":shot.get("stream110",false),"sword153":shot.get("sword153",false),"snack":shot.get("snack146",buffs.level("snack")),"tracking":shot.get("tracking146",buffs.level("eye_exercise")),"goose_source168":0})
 return {"specs":specs,"plane":false,"stream":false,"label":"接力","burst_time":.04,"pulse_interval":.04}
func capture245(before: int,target: Vector3) -> void:
 if relaying245 or buffs.level("red_banner")==0 or not is_instance_valid(relay245):return
 if relay245.phase not in ["drop","settle","ready"] or not relay245.pending.is_empty():return
 var packet=pack_shots245(before) if shots.size()>before else last_packet245.duplicate(true)
 if packet.is_empty():return
 var specs=[]
 for spec in packet.get("specs",[]):
  if int(spec.get("goose_source168",0))==0:specs.append(spec.duplicate(true))
 packet.specs=specs;packet.relay245=true;packet.single_goose169=true;packet.source_rate169=buffs.rate()
 if relay245.offer245(packet,target):captures245+=1
func fire_at(target: Vector3) -> void:
 var before=shots.size();last_packet245.clear();super.fire_at(target)
 if not music_enabled236():capture245(before,target)
func _release_charged(target: Vector3,ratio: float) -> void:
 var before=shots.size();last_packet245.clear();super._release_charged(target,ratio)
 capture245(before,target)
func emit_stream110(target: Vector3) -> void:
 var before=shots.size();super.emit_stream110(target)
 if not music_enabled236():capture245(before,target)
func music_attack_finished236(before: int,target: Vector3) -> void:capture245(before,target)
func emit_relay245(packet: Dictionary,origin: Vector3,target: Vector3) -> void:
 if packet.is_empty():return
 relaying245=true;echoes245+=1
 if packet.get("plane",false):paper_memories146.launch146(packet,origin,target,relay_gain245,true)
 else:
  generation245+=1;emit_packet146(packet,origin,target,relay_gain245,generation245)
 relaying245=false
func _clear_combat_shots() -> void:
 super._clear_combat_shots();last_packet245.clear()
 if is_instance_valid(relay245):relay245.clear245()
func _process(delta: float) -> void:
 super._process(delta)
 if ready228:guide206.text=guide206.text.replace("244","245")+"\n接力旗：Shift留下 / 下一轮接棒 · F11动作预览 · 测试补射35%"
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F11 and is_instance_valid(relay245) and stage225=="battle":
  stats226.debug=true;relay245.plant245(hero.global_position+camera.global_basis.x*.85)
  var packet={"specs":[{"speed":10.,"angle":0.,"life":1.2,"damage":1.,"gain":1.,"charged":false,"piercing110":false,"note110":false,"stream110":false,"sword153":false,"snack":0,"tracking":0}],"plane":false,"stream":false,"label":"预览"}
  relay245.offer245(packet,paper_aim146());get_viewport().set_input_as_handled();return
 super._input(event)
func report_stats226() -> Dictionary:
 if not recording226.final_report.is_empty() and recording226.final_report.has("relay245"):return recording226.final_report.duplicate(true)
 var report=super.report_stats226();report["relay245"]={"test_gain":relay_gain245,"captures":captures245,"echoes":echoes245,"phase":relay245.phase if is_instance_valid(relay245) else "loading","source":"main goose only; no recursive capture"};return report
func reset_music236() -> void:
 super.reset_music236();captures245=0;echoes245=0
 if is_instance_valid(relay245):relay245.clear245()

func relay_script245() -> Script:return preload("res://scripts/combat/relay_flag245.gd")
func can_plant245() -> bool:return true
