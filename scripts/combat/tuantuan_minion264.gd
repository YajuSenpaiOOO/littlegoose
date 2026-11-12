extends "res://scripts/combat/tuantuan_minion262.gd"
var playground264 := false
var play_clock264 := 0.
var play_center264 := Vector2.ZERO
func _ready() -> void:
 super._ready()
 if playground264:
  state260="play264";active_ai=false;hit_area.collision_layer=0;collision_layer=16;collision_mask=1|2|16
  rustle261.hide();visual.show();play_center264=Vector2(position.x,position.z)
func _physics_process(delta: float) -> void:
 if state260!="play264":super._physics_process(delta);return
 if battle.combat_paused:return
 play_clock264+=delta;_step_response121(delta)
 var phase=fmod(play_clock264+float(role110%2)*.27,.72)
 var t=clampf(phase/.42,0.,1.);hopping=phase<.42;hop_clock=phase
 var turn=float(int(play_clock264/1.44)%4)*PI*.5+float(role110%2)*PI
 var target=play_center264+Vector2(cos(turn),sin(turn))*.65
 var at=Vector2(position.x,position.z);var motion=(target-at).limit_length(1.4*sin(t*PI) if hopping else 0.)
 velocity=Vector3(motion.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y);move_and_slide()
 _render_legacy(sin(t*PI)*.18 if hopping else 0.);shadow.hide();health_fill.hide();cue.hide();small_cue.hide()
