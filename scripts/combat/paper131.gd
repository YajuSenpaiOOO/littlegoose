extends "res://scripts/combat/paper129.gd"
var drift130 := Vector2.ZERO
var gust_wait130 := 4.
var curve_a130 := Vector2.ZERO
var curve_b130 := Vector2.ZERO
var curve_c130 := Vector2.ZERO
var locked130 := Vector2.ZERO
var last_motion130 := Vector2.ZERO
var gust_duration131 := 1.1
var air_clock131 := 0.
var air_scan131 := 0.
var air_age131 := 1.
var air_side131 := Vector2.ZERO
var air_count131 := 0
func play119() -> void:
 super.play119();paper_state129="drift";paper_clock129=0.;gust_wait130=3.2+float(role110%6)*.63
 paper_lift129=.5;drift130=Vector2.from_angle(float(role110)*1.7)*.45
func deflect(contact: Vector3) -> void:
 super.deflect(contact)
 paper_state129="coast";paper_clock129=0.;drift130*=-.25;gust_wait130=4.5
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if dead: return
 var phase := float(role110)*1.73
 var bank := sin(age*.83+phase)*.19+sin(age*1.67+phase*.7)*.065
 var side: float=Vector3(drift130.x,0.,drift130.y).dot(battle.camera.global_basis.x)
 visual.rotation.z=bank-side*.055+sin(curl_left129/.32*PI)*.36
 visual.scale.x*=1.-.12*pow(sin(age*1.2+phase),2.)
 if paper_state129=="warning":
  visual.scale*=Vector3(.92,1.06,1.)
  visual.rotation.z=lerpf(visual.rotation.z,-paper_direction129.x*.18,clampf(paper_clock129/.65,0.,1.))
 # Keep the visible floating paper, aim point and physical hurt capsule together.
 hit_area.position.y=lift+.72
func _begin_gust130(at: Vector2) -> void:
 paper_state129="gust";paper_clock129=0.;attack_connected=false
 curve_a130=at
 var distance := at.distance_to(locked130)
 var direction := (locked130-at).normalized()
 var side := direction.orthogonal()*(.8 if role110%2==0 else -.8)
 curve_c130=locked130+direction*1.15+side
 var u := clampf(distance/(distance+1.15),.50,.82)
 # Solve the control point so the path actually crosses the advertised target.
 curve_b130=(locked130-curve_a130*pow(1.-u,2.)-curve_c130*u*u)/(2.*u*(1.-u))
 gust_duration131=clampf((distance+2.)/6.,.85,1.4)
func _wind_motion130(at: Vector2,player: Vector2) -> Vector2:
 var phase := float(role110)*1.73
 var wind: Vector2=battle.paper_wind130(at,battle.elapsed114)
 var eddy := Vector2(sin(age*.91+phase),cos(age*.67+phase*.8))*.56
 var desired := wind+eddy+(player-at).limit_length(4.)*.16
 var from_home := at-home
 if from_home.length()>5.5: desired-=from_home.normalized()*(from_home.length()-5.5)*.65
 # Geometry still blocks the actor; gently turn out of obstacles rather than snapping.
 if desired.length()>.1 and not battle.line_clear110(at,at+desired.normalized()*.8):
  desired=desired.rotated(.9 if role110%2==0 else -.9)*.75
 return desired.limit_length(2.5)
func _physics_process(delta: float) -> void:
 if dead or mode119!="playing": super._physics_process(delta);return
 if battle.combat_paused: return
 _step_response121(delta)
 curl_left129=maxf(0.,curl_left129-delta);curl_gate129=maxf(0.,curl_gate129-delta)
 if not active_ai or battle.player_hp<=0. or battle.wave_state!="fighting": _render_legacy(paper_lift129);return
 paper_clock129+=delta;gust_wait130-=delta
 air_clock131=maxf(0.,air_clock131-delta);air_scan131-=delta;air_age131+=delta
 if paper_state129=="drift" and air_clock131<=0. and air_scan131<=0.:
  air_scan131=.08;scan_air131()
 var at := Vector2(position.x,position.z)
 var player := Vector2(battle.hero.position.x,battle.hero.position.z)
 var phase := float(role110)*1.73
 var desired := _wind_motion130(at,player)
 var target_lift := .90+sin(age*.87+phase)*.52+sin(age*1.53+phase*.6)*.20
 hopping=false;attack_phase="approach"
 match paper_state129:
  "drift":
   if gust_wait130<=0. and at.distance_to(player)<5.8:
    paper_state129="warning";paper_clock129=0.;locked130=player;paper_direction129=(player-at).normalized()
  "warning":
   attack_phase="windup";attack_direction=paper_direction129;attack_distance=at.distance_to(locked130);phase_clock=paper_clock129
   desired*=.32;target_lift=.72
   if paper_clock129>=.65: _begin_gust130(at)
  "gust":
   attack_phase="lunge"
   var t := clampf(paper_clock129/gust_duration131,0.,1.)
   var u := t*t*(3.-2.*t)
   var wanted := (1.-u)*(1.-u)*curve_a130+2.*(1.-u)*u*curve_b130+u*u*curve_c130
   desired=((wanted-at)/maxf(delta,.001)).limit_length(12.)
   target_lift=.18+.25*absf(2.*t-1.)
   if t>=1.:
    paper_state129="coast";paper_clock129=0.;gust_wait130=4.2+float(role110%4)*.47
  "coast":
   desired=drift130*.55+desired*.45
   if paper_clock129>=1.1: paper_state129="drift";paper_clock129=0.
 if paper_state129=="gust": drift130=desired
 else: drift130=drift130.move_toward(desired,1.65*delta)
 paper_lift129=lerpf(paper_lift129,target_lift,1.-exp(-delta*(6. if paper_state129=="gust" else 2.3)))
 var before := position
 var air := air_side131*(2.8*sin(PI*clampf(air_age131/.34,0.,1.))) if air_age131<.34 else Vector2.ZERO
 var glide153 := (drift130+air)*(float(get_meta("locomotion_scale153",1.)) if paper_state129!="gust" else 1.)
 velocity=Vector3(glide153.x+impulse.x,-.3 if is_on_floor() else velocity.y-20.*delta,glide153.y+impulse.y)
 impulse*=exp(-8.*delta);move_and_slide();last_motion130=drift130
 if paper_state129=="gust" and not attack_connected:
  if _try_parry_attack(before): _render_legacy(paper_lift129);return
  var crossed: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),player,.75)
  if crossed<INF and paper_lift129<.7 and absf(position.y-battle.hero.position.y)<.65:
   attack_connected=true;paper_contact131(at)
 _render_legacy(paper_lift129)



func air_threat131(at: Vector3,motion: Vector3) -> bool:
 if paper_state129!="drift" or air_clock131>0. or motion.length_squared()<1.: return false
 var centre := global_position+Vector3.UP*(paper_lift129+.72)
 var relative := motion-Vector3(drift130.x,0.,drift130.y)
 var time := (centre-at).dot(relative)/maxf(relative.length_squared(),.001)
 if time<.035 or time>.28: return false
 var near := at+relative*time
 if near.distance_to(centre)>.82: return false
 var flat := Vector2(motion.x,motion.z).normalized()
 if flat.length_squared()<.1: return false
 var side := flat.orthogonal()
 var offset := Vector2(centre.x-near.x,centre.z-near.z).dot(side)
 if offset<-.02 or (absf(offset)<=.02 and role110%2==1): side=-side
 air_side131=side;air_age131=0.;air_clock131=1.85;air_count131+=1
 curl_left129=.32
 return true
func scan_air131() -> void:
 # Scan at most 12.5Hz, with the existing projectile budget; no per-shot nodes.
 var begin := maxi(0,battle.shots.size()-96)
 for i in range(battle.shots.size()-1,begin-1,-1):
  var shot: Dictionary=battle.shots[i]
  if air_threat131(shot.node.position,shot.velocity): return

func paper_contact131(at: Vector2) -> void:
 battle.hurt_player(10.,at)
