extends "res://scripts/combat/tuantuan128.gd"
var paper_state129 := "float"
var paper_clock129 := 0.
var curl_left129 := 0.
var curl_gate129 := 0.
var touch_gate129 := 0.
var drift_angle129 := 0.
var paper_direction129 := Vector2.DOWN
var paper_lift129 := 0.
func _ready() -> void:
 var texture: Texture2D=load("res://assets/paper129/scrap.svg")
 poses=poses.duplicate();textures=textures.duplicate()
 var spec := {"foot":[77.,137.],"scale":.32,"visible_width":33.,"visible_height":37.}
 for key in poses.keys(): poses[key]=spec.duplicate();textures[key]=texture
 super._ready()
func play119() -> void:
 super.play119();paper_state129="float";paper_clock129=role110*.23;drift_angle129=role110*2.3
func peer_contact123(_before: Vector3) -> bool: return false
func receive_hit(damage: float,direction: Vector3) -> void:
 var old := impulse
 var react := curl_gate129<=0.
 super.receive_hit(damage,direction)
 if dead: return
 # One brief flutter per interval; secondary bullets cannot endlessly blow it away.
 impulse=Vector2(direction.x,direction.z).normalized()*.85 if react else old
 if react: curl_left129=.32;curl_gate129=.48
func deflect(contact: Vector3) -> void:
 super.deflect(contact);paper_state129="settle";paper_clock129=0.;impulse=impulse.limit_length(1.)
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if dead: return
 visual.rotation.z=sin(age*3.4+drift_angle129)*(.12 if paper_state129=="float" else .025)+sin(curl_left129/.32*PI)*.42
 if curl_left129>0.: visual.scale.x*=1.-sin(curl_left129/.32*PI)*.32
func _physics_process(delta: float) -> void:
 if dead or mode119!="playing": super._physics_process(delta);return
 if battle.combat_paused: return
 _step_response121(delta);paper_clock129+=delta
 curl_left129=maxf(0.,curl_left129-delta);curl_gate129=maxf(0.,curl_gate129-delta);touch_gate129=maxf(0.,touch_gate129-delta)
 if not active_ai or battle.player_hp<=0. or battle.wave_state!="fighting": _render_legacy(.08);return
 var at := Vector2(position.x,position.z)
 var player := Vector2(battle.hero.position.x,battle.hero.position.z)
 var toward := (player-at).normalized()
 var motion := Vector2.ZERO
 hopping=false;attack_phase="approach"
 match paper_state129:
  "float":
   var wish := player+toward.orthogonal()*sin(age*1.7+drift_angle129)*1.3
   path_clock-=delta
   if path_clock<=0.: route=battle.navigation.path(at,wish);path_clock=.4
   while route.size()>1 and at.distance_to(route[0])<.5: route.remove_at(0)
   motion=(route[0]-at).normalized()*1.65 if not route.is_empty() else toward*1.65
   paper_lift129=.30+sin(age*4.+drift_angle129)*.16
   if paper_clock129>=1.8+float(role110%3)*.22: paper_state129="settle";paper_clock129=0.
  "settle":
   paper_lift129=move_toward(paper_lift129,.04,delta*1.4)
   if paper_clock129>=.95:
    paper_direction129=toward;paper_state129="windup" if at.distance_to(player)<4.5 else "float";paper_clock129=0.
  "windup":
   attack_phase="windup";attack_direction=paper_direction129;attack_distance=2.08;phase_clock=paper_clock129;paper_lift129=.04+absf(sin(paper_clock129*30.))*.035
   if paper_clock129>=.32: paper_state129="swoop";paper_clock129=0.;attack_connected=false
  "swoop":
   attack_phase="lunge";motion=paper_direction129*5.2;paper_lift129=sin(clampf(paper_clock129/.40,0.,1.)*PI)*.2
   if paper_clock129>=.40: paper_state129="float";paper_clock129=0.;motion=Vector2.ZERO
 var before := position
 velocity=Vector3(motion.x+impulse.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y+impulse.y)
 impulse*=maxf(0.,1.-8.*delta);move_and_slide()
 if paper_state129=="swoop" and not attack_connected and _try_parry_attack(before): _render_legacy(paper_lift129);return
 if touch_gate129<=0.:
  var t: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,.75)
  if t<INF and absf(position.y-battle.hero.position.y)<.65:
   battle.hurt_player(10.,at);touch_gate129=.9;attack_connected=true
 _render_legacy(paper_lift129)

