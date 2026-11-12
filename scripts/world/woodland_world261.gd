extends "res://scripts/world/woodland_world260.gd"
var entry_notes261 := 0
var entry_navigation261: RefCounted
func minion_script260() -> Script:return preload("res://scripts/combat/tuantuan_minion261.gd")
func minion_attack_allowed260() -> bool:return true
func entry_lanes261() -> Array:return preload("res://scripts/combat/encounter_entry261.gd").LANES
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 261 · 团团Boss / 林边入场")
func _ready() -> void:
 await super._ready()
 entry_navigation261=preload("res://scripts/combat/woodland_navigation76.gd").new()
 entry_navigation261.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
func begin251() -> void:
 entry_notes261=0;super.begin251()
func spawn_minion260() -> CharacterBody3D:
 if live_minions260().size()>=minion_cap261() or entry_navigation261==null:return null
 var occupied: Array[Vector2]=[]
 for m in live_minions260():occupied.append(Vector2(m.position.x,m.position.z))
 var plan=preload("res://scripts/combat/encounter_entry261.gd").plan(self,entry_navigation261,serial260,occupied,entry_lanes261())
 if plan.is_empty():
  telemetry260.event("entry_unavailable");return null
 var m=minion_script260().new()
 m.battle=self;m.poses=combat_poses;m.textures=combat_textures;m.home=meadow.landmarks.grove;m.rank110=0;m.body_scale110=1.;m.max_hp110=6.;m.hp=6.;m.touch110=1.;m.role110=serial260+200;serial260+=1
 m.entry_route261=plan.route.duplicate();m.entry_name261=plan.name;m.entry_length261=plan.length
 var at: Vector2=plan.route[0];m.position=Vector3(at.x,floor_height(at)+.03,at.y)
 add_child(m);minions260.append(m);m.reset_physics_interpolation();_add_actor_shadow(m,m.visual);m.projection260=actor_shadows[-1];m.projection260.hide();time55.apply_look()
 telemetry260.data.minions.spawned+=1;telemetry260.event("entry_rustle",{"lane":plan.name,"route_metres":plan.length})
 if entry_notes261==0:encounter_hud.announce("林边的草晃了晃","小团团从林子里蹦过来了。",1.8)
 entry_notes261+=1;return m
func entry_complete261(m: CharacterBody3D) -> void:
 telemetry260.event("entry_complete",{"lane":m.entry_name261})
func cancel_entry261(m: CharacterBody3D) -> void:
 telemetry260.event("entry_blocked",{"lane":m.entry_name261})
 if is_instance_valid(m.projection260):actor_shadows.erase(m.projection260)
 minions260.erase(m);enemies.erase(m);m.hide();m.set_physics_process(false)
 if m.is_inside_tree():remove_child(m)
 m.queue_free();_prune_actor_shadows();target114=null;aim_tick114=-1;rebuild_cells110()
func _process(delta: float) -> void:
 super._process(delta)
 if ready251:guide206.text=guide206.text.replace("260 团团Boss · 同伴弹飞","261 团团Boss · 林边入场")

func minion_cap261() -> int:return 3
