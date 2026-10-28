extends "res://scripts/combat/spider170.gd"
const WIND171 := 1.15
const PUSH171 := .30
const SIT171 := 1.35
var loaded171 := false
var pushed171 := false
var throws171 := 0
var relocate171 := false
var facing171 := false
func _ready() -> void:
 super._ready()
 var entries: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/spider171/poses.json"))
 for key in ["winding","push","sit"]:
  poses[key]=entries[key];textures[key]=load("res://assets/spider171/"+key+".png")
 loaded171=true;_render_legacy(0.)
func play119() -> void:
 super.play119();relocate171=false;pushed171=false
func enter170(next: String) -> void:
 state170=next;clock170=0.
 # No body attack/parry-lunge phase: only the released toy can hurt the player.
 attack_phase="windup" if next=="winding" else ("recover" if next in ["push","sit"] else "approach")
 if next=="sit": recoveries170+=1;lift170=0.;attack_connected=true
func prepare170(player: Vector2) -> void:
 var at := Vector2(position.x,position.z)
 target170=player;attack_direction=(player-at).normalized()
 if attack_direction.length_squared()<.01: attack_direction=Vector2.DOWN
 face_motion171(attack_direction)
 impulse=Vector2.ZERO;pushed171=false;attacks_started+=1;enter170("winding")
func face_motion171(direction: Vector2) -> void:
 var side := Vector3(direction.x,0.,direction.y).dot(battle.camera.global_basis.x)
 # Preserve the last side near screen-vertical motion instead of flickering.
 if absf(side)>.08: facing171=side<0.
func begin_hop170(player: Vector2) -> void:
 super.begin_hop170(player)
 face_motion171(hop170)
func _render_legacy(lift: float) -> void:
 if not loaded171: super._render_legacy(lift);return
 var key := "idle"
 if dead: key="landing"
 elif state170 in ["winding","push","sit"]: key=state170
 elif state170=="crouch": key="anticipation"
 elif state170=="hop": key="airborne"
 _pose(key,lift);visual.rotation.z=0.;visual.flip_h=facing171
 if visual.flip_h: visual.offset.x=-visual.offset.x
 if state170=="winding" and not dead:
  visual.rotation.z=sin(clock170*19.)*.035
  visual.scale=Vector3(1.+sin(clock170*19.)*.025,1.-sin(clock170*19.)*.025,1.)
 elif state170=="push" and not dead:
  var t := clampf(clock170/PUSH171,0.,1.)
  visual.rotation.z=(.10 if facing171 else -.10)*sin(t*PI)
 elif state170=="sit" and not dead:
  var t := clampf(clock170/SIT171,0.,1.)
  visual.rotation.z=sin(t*TAU*2.)*.10*exp(-t*3.)
 elif state170=="watch": visual.scale.y=1.+sin(age*3.+role110)*.018
 if is_instance_valid(marker170): marker170.hide()
 if is_instance_valid(cue): cue.hide()
 if is_instance_valid(small_cue): small_cue.hide()
func deflect(_contact: Vector3) -> void:
 # Spider body never lunges in this version.
 pass
func _physics_process(delta: float) -> void:
 if battle.combat_paused: return
 if dead or mode119!="playing": super._physics_process(delta);return
 _step_response121(delta)
 if not active_ai or battle.player_hp<=0. or battle.wave_state!="fighting": return
 clock170+=delta;phase_clock=clock170;lift170=0.
 var at := Vector2(position.x,position.z);var player := Vector2(battle.hero.position.x,battle.hero.position.z)
 var motion := Vector2.ZERO
 match state170:
  "watch":
   if clock170>=wait170:
    if relocate171: relocate171=false;begin_hop170(player)
    elif at.distance_to(player)<=7. and absf(position.y-battle.hero.position.y)<.65 and battle.line_clear110(at,player) and battle.reserve_spider170(self): prepare170(player)
    else: begin_hop170(player)
  "crouch":
   if clock170>=.16: enter170("hop")
  "hop":
   var t := clampf(clock170/.38,0.,1.)
   motion=hop170*4.2*sin(t*PI)*float(get_meta("locomotion_scale153",1.));lift170=sin(t*PI)*.32
   if t>=1.: enter170("watch");wait170=.35+float(role110%3)*.11
  "winding":
   if clock170>=WIND171: enter170("push")
  "push":
   if not pushed171 and clock170>=.08:
    pushed171=true;throws171+=1
    battle.release_silk171(self,attack_direction)
   if clock170>=PUSH171: enter170("sit")
  "sit":
   if clock170>=SIT171: enter170("watch");wait170=.30;relocate171=true
 var recoil := impulse if state170 in ["watch","crouch","hop"] else Vector2.ZERO
 velocity=Vector3(motion.x+recoil.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y+recoil.y)
 impulse*=maxf(0.,1.-8.*delta);move_and_slide();_render_legacy(lift170)
