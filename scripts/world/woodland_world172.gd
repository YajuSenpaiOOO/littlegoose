extends "res://scripts/world/woodland_world171.gd"
var pads172: Array[CharacterBody3D]=[]
var web_clears172 := 0
func _hero_script() -> Script: return preload("res://scripts/combat/hero172.gd")
func _silk_script171() -> Script: return preload("res://scripts/combat/silk_ball172.gd")
func _enemy_script() -> Script: return preload("res://scripts/combat/spider172.gd") if spider_trial170 else super._enemy_script()
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/spider_hud172.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 172 · 织小网垫 / 开心蹦两下 / 丝球弹反闪避")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 if "--web172" in OS.get_cmdline_user_args(): start_spider170()
func reserve_spider170(actor: CharacterBody3D) -> bool:
 if not reserve_attack(actor): return false
 if is_instance_valid(attacker170) and not attacker170.dead and attacker170!=actor and attacker170.state170 in ["winding","push","weave"]: return false
 attacker170=actor;return true
func can_perfect_dodge(enemy: CharacterBody3D) -> bool:
 if enemy.has_method("face_motion171"): return false
 return super.can_perfect_dodge(enemy)
func place_pad172(actor: CharacterBody3D) -> CharacterBody3D:
 if pads172.size()>=2: return null
 var at := Vector2(actor.position.x,actor.position.z);var player := Vector2(hero.position.x,hero.position.z)
 var forward := (player-at).normalized()
 if forward.length_squared()<.01: forward=Vector2.DOWN
 var center := at+forward.orthogonal()*(1.8 if actor.role110%2==0 else -1.8)
 if center.distance_to(player)<3.2: center=player+(center-player).normalized()*3.2
 var height := floor_height(center)
 if absf(height-actor.position.y)>.5 or not line_clear110(at,center): return null
 for other in pads172:
  if center.distance_to(Vector2(other.position.x,other.position.z))<3.6: return null
 var pad := preload("res://scripts/combat/web_pad172.gd").new();pad.battle=self;pad.owner172=weakref(actor);pad.position=Vector3(center.x,height+.04,center.y)
 combat_effect_root159().add_child(pad);pads172.append(pad);_add_actor_shadow(pad,pad.visual);return pad
func remove_pad172(pad: CharacterBody3D) -> void:
 if target114==pad: target114=null;aim_tick114=-1
 pads172.erase(pad)
 if is_instance_valid(pad): pad.hit_area.collision_layer=0;pad.hide();pad.set_physics_process(false);pad.queue_free()
func on_web172(at: Vector3) -> bool:
 for pad in pads172:
  if is_instance_valid(pad) and pad.covers172(at): return true
 return false
func _clear_combat_shots() -> void:
 super._clear_combat_shots()
 for pad in pads172.duplicate(): remove_pad172(pad)
 if is_instance_valid(hero) and hero.has_method("clear_web172"): hero.clear_web172()
func _refresh_aim114(cursor: Vector2) -> void:
 var balls := silk171;silk171=silk171.duplicate()
 for pad in pads172:
  if is_instance_valid(pad) and pad.live172 and not pad.dead: silk171.append(pad)
 super._refresh_aim114(cursor);silk171=balls
func announce152() -> void:
 if not spider_trial170: super.announce152();return
 if is_instance_valid(encounter_hud): encounter_hud.announce("织小网垫 · "+BUILDS170[build170].name,"网垫只减移动，可射散中心网结 · 丝球可完美闪避/弹反 · F6单/三只 F7重开 1—9组合",4.)
