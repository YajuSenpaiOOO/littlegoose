extends "res://scripts/world/woodland_world172.gd"
func _hero_script() -> Script: return preload("res://scripts/combat/hero173.gd")
func _enemy_script() -> Script: return preload("res://scripts/combat/spider173.gd") if spider_trial170 else super._enemy_script()
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/spider_hud173.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 173 · 脚下织网 / 三块十秒 / 丝线绊脚")
func _ready() -> void:
 super._ready()
 while not is_instance_valid(arc_shadows167): await get_tree().physics_frame
 if "--web173" in OS.get_cmdline_user_args(): start_spider170()
func place_pad172(actor: CharacterBody3D) -> CharacterBody3D:
 if pads172.size()>=3: return null
 var center := Vector2(actor.position.x,actor.position.z)
 var height := floor_height(center)
 if absf(height-actor.position.y)>.5: return null
 for other in pads172:
  if not other.retired171 and center.distance_to(Vector2(other.position.x,other.position.z))<1.3: return null
 var pad := preload("res://scripts/combat/web_pad173.gd").new();pad.battle=self;pad.owner172=weakref(actor);pad.position=Vector3(center.x,height+.04,center.y)
 combat_effect_root159().add_child(pad);pads172.append(pad);return pad
func remove_pad172(pad: CharacterBody3D) -> void:
 if target114==pad: target114=null;aim_tick114=-1
 pads172.erase(pad)
 if is_instance_valid(pad): pad.hide();pad.set_physics_process(false);pad.queue_free()
func _refresh_aim114(cursor: Vector2) -> void:
 # Pads are terrain, so only real spiders and intentionally aimed silk balls
 # participate. Preserve 172 as a separately playable destructible-web version.
 var regions := pads172;pads172=[]
 super._refresh_aim114(cursor);pads172=regions
func announce152() -> void:
 if not spider_trial170: super.announce152();return
 if is_instance_valid(encounter_hud): encounter_hud.announce("脚下织网 · "+BUILDS170[build170].name,"网从蜘蛛脚下展开 · 三块/十秒 · 移速-45%，可正常闪避 · F6单/三只 F7重开 1—9组合",4.)
