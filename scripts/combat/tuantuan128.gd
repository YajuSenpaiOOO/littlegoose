extends "res://scripts/combat/tuantuan127.gd"
var timing128 := RandomNumberGenerator.new()
func _ready() -> void:
 timing128.seed=128000+role110*7919
 super._ready()
func play119() -> void:
 super.play119()
 phase_clock=-timing128.randf_range(.04,.72)
func _begin_windup(target: Vector2) -> void:
 super._begin_windup(target)
 phase_clock=timing128.randf_range(-.06,.06)
func clear_play123() -> void:
 super.clear_play123()
 peer_cooldown123=timing128.randf_range(5.,7.)
func _physics_process(delta: float) -> void:
 var previous := attack_phase
 super._physics_process(delta)
 if not battle.combat_paused and available123() and play_state123=="" and previous=="lunge" and attack_phase=="recover" and phase_clock==0.:
  phase_clock=timing128.randf_range(-.09,.09)
func _step_play123(delta: float) -> void:
 if play_state123=="shove" and play_clock123+delta>=2.1:
  clear_play123();_render_legacy(0.);return
 super._step_play123(delta)
func peer_contact123(before: Vector3) -> bool:
 if peer_cooldown123>0.: return false
 var start := Vector2(before.x,before.z)
 var at := Vector2(position.x,position.z)
 var travel := at-start
 if travel.length()<.015: return false
 var forward := travel.normalized()
 var own_speed := travel/maxf(get_physics_process_delta_time(),.001)
 var nearest: CharacterBody3D
 var first := INF
 for other in battle.enemies:
  if other==self or not is_instance_valid(other) or not other.has_method("available123"): continue
  if not other.available123() or other.peer_cooldown123>0. or other.play_state123 not in ["","cheer","shove"]: continue
  if absf(position.y-other.position.y)>.65: continue
  var toward := Vector2(other.position.x,other.position.z)-start
  # A real incoming body impact, not an overlap, side brush or same-speed queue.
  if toward.length()<=.70 or toward.normalized().dot(forward)<.70 or absf(toward.cross(forward))>.38: continue
  var relative := own_speed-Vector2(other.velocity.x,other.velocity.z)
  if relative.dot(toward.normalized())<1.8: continue
  var crossed: float=battle.aim_model.sweep_circle(start,at,Vector2(other.position.x,other.position.z),.72)
  if crossed<first: first=crossed;nearest=other
 if not is_instance_valid(nearest): return false
 begin_quarrel123(nearest)
 if nearest.play_state123=="": nearest.begin_quarrel123(self)
 return true

