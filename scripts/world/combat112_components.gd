extends "res://scripts/world/combat112_profile.gd"
class Hero112:
 extends Fighter
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._physics_process(delta);get_parent().record112("hero",t)
class Enemy112:
 extends "res://scripts/combat/tuantuan110.gd"
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._physics_process(delta);battle.record112("enemy",t)
class Details112:
 extends "res://scripts/art/woodland_details106.gd"
 func _physics_process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._physics_process(delta);world.record112("details_physics",t)
class Shadow112:
 extends "res://scripts/combat/actor_shadow105.gd"
 func _process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._process(delta);battle.record112("actor_shadow",t)
class Skills112:
 extends "res://scripts/combat/battle_skills111.gd"
 func _process(delta: float) -> void:
  var t := Time.get_ticks_usec();super._process(delta);battle.record112("skills_process",t)
 func _draw() -> void:
  var t := Time.get_ticks_usec();super._draw();battle.record112("skills_draw",t)
class Cost112:
 extends Profile112
 var parts := {}
 func record112(key: String,t: int) -> void: parts[key]=int(parts.get(key,0))+Time.get_ticks_usec()-t
 func _hero_script() -> Script: return Hero112
 func _enemy_script() -> Script: return Enemy112
 func _details_script101() -> Script: return Details112
 func _actor_shadow_script105() -> Script: return Shadow112
 func _skills_script110() -> Script: return Skills112
func run() -> void:
 root.size=Vector2i(2560,1494);DisplayServer.window_set_size(root.size);DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 var s := Cost112.new();await setup(s,"woodland_ready111")
 s.shooting=false;s.parts.clear();await measure112(s,"components_idle");print("PARTS112 idle ",JSON.stringify(s.parts))
 build(s,["forest_fireboy","three_player","eye_exercise","eye_exercise","snack","snack"])
 s.parts.clear();await measure112(s,"components_six");print("PARTS112 six ",JSON.stringify(s.parts));quit()
