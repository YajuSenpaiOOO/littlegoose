extends "res://scripts/combat/tuantuan121.gd"
var roam122 := false
var spawn_age122 := 0.
var roam_wait122 := 1.
var roam_hop122 := 0.
var cheer122 := 0.
var roam_path122 := PackedVector2Array()
var speech_anchor122: Node3D
var roam_rng122 := RandomNumberGenerator.new()
func _ready() -> void:
 super._ready();set_process(false)
func receive_hit(damage: float,direction: Vector3) -> void:
 if roam122: return
 super.receive_hit(damage,direction)
 if dead: set_process(true)
func _process(delta: float) -> void:
 if not dead or battle.combat_paused: return
 corpse_time+=delta
 if corpse_time<Profile.CORPSE_LIFE: return
 var fade := clampf((corpse_time-Profile.CORPSE_LIFE)/Profile.CORPSE_FADE,0.,1.)
 visual.transparency=fade;visual.modulate.a=1.-fade
 if visual.material_override==soft_ink: soft_ink.set_shader_parameter("tint",Color(1.,1.,1.,1.-fade))
 if fade>=1.:
  battle.enemies.erase(self);battle.rebuild_cells110();hide();queue_free()
func begin_roam122() -> void:
 roam122=true;mode119="roam122";active_ai=false;collision_layer=0;hit_area.collision_layer=0
 roam_rng122.randomize();roam_wait122=roam_rng122.randf_range(.8,1.5)
 speech_anchor122=Node3D.new();speech_anchor122.position.y=1.;add_child(speech_anchor122)
 _render_legacy(0.);visual.scale=Vector3(.65,.05,1.);health_fill.hide()
func _physics_process(delta: float) -> void:
 if not roam122: super._physics_process(delta);return
 if battle.combat_paused: return
 if position.distance_squared_to(battle.hero.position)>625.: return
 _step_response121(delta);spawn_age122+=delta;health_fill.hide();attack_phase="approach"
 if spawn_age122<.75:
  var t := clampf(spawn_age122/.75,0.,1.)
  hopping=true;hop_clock=.1;_render_legacy(sin(t*PI)*.4)
  visual.scale*=Vector3(lerpf(.65,1.,t),lerpf(.05,1.,smoothstep(0.,.5,t)),1.)
  return
 var at := Vector2(position.x,position.z)
 var player := Vector2(battle.hero.position.x,battle.hero.position.z)
 var motion := Vector2.ZERO;var lift := 0.
 cheer122=maxf(0.,cheer122-delta)
 if cheer122>0.:
  hopping=true;hop_clock=.1;lift=absf(sin(cheer122*TAU*2.))*.3
 else:
  roam_wait122-=delta
  if roam_path122.is_empty() and roam_wait122<=0.:
   var target := home+Vector2.from_angle(roam_rng122.randf()*TAU)*roam_rng122.randf_range(1.,3.5)
   if at.distance_to(player)<6. and player.distance_to(home)<7. and at.distance_to(player)>3.:
    target=player+(at-player).normalized()*2.8
   roam_path122=battle.navigation.path(at,target);roam_wait122=roam_rng122.randf_range(1.5,3.)
  while not roam_path122.is_empty() and at.distance_to(roam_path122[0])<.45: roam_path122.remove_at(0)
  if not roam_path122.is_empty():
   roam_hop122=fmod(roam_hop122+delta,.62);hopping=roam_hop122<.42;hop_clock=roam_hop122
   var t := clampf(roam_hop122/.42,0.,1.)
   if hopping: motion=(roam_path122[0]-at).normalized()*2.8*sin(t*PI);lift=sin(t*PI)*.22
   landing_left=.08 if not hopping else 0.
  else: hopping=false;roam_hop122=0.
 velocity=Vector3(motion.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y);move_and_slide();_render_legacy(lift)
