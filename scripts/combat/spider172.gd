extends "res://scripts/combat/spider171.gd"
const WEAVE172 := 1.8
const HAPPY172 := .85
var art_ready172 := false
var actions172 := 0
var pad172: CharacterBody3D
var celebrations172 := 0
func _ready() -> void:
 super._ready()
 var entries: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/spider172/poses.json"))
 for key in ["weave_a","weave_b","happy"]:
  poses[key]=entries[key];textures[key]=load("res://assets/spider172/"+key+".png")
 art_ready172=true
func play119() -> void:
 super.play119();actions172=role110%2
func prepare170(player: Vector2) -> void:
 var make_web := actions172%2==0;actions172+=1
 if make_web:
  pad172=battle.place_pad172(self)
  if is_instance_valid(pad172):
   face_motion171(Vector2(pad172.position.x-position.x,pad172.position.z-position.z));impulse=Vector2.ZERO;enter170("weave");return
 super.prepare170(player)
func _render_legacy(lift: float) -> void:
 if not art_ready172 or dead or state170 not in ["weave","happy"]: super._render_legacy(lift);return
 var key := ("weave_a" if int(clock170/.14)%2==0 else "weave_b") if state170=="weave" else "happy"
 _pose(key,lift);visual.flip_h=facing171
 if visual.flip_h: visual.offset.x=-visual.offset.x
 visual.rotation.z=sin(clock170*18.)*.025 if state170=="weave" else sin(clock170*12.)*.035
 if is_instance_valid(marker170): marker170.hide()
func _physics_process(delta: float) -> void:
 if dead or mode119!="playing" or state170 not in ["weave","happy"]: super._physics_process(delta);return
 if battle.combat_paused or not active_ai or battle.player_hp<=0. or battle.wave_state!="fighting": return
 _step_response121(delta);clock170+=delta;phase_clock=clock170;attack_phase="approach";lift170=0.
 if state170=="weave":
  if not is_instance_valid(pad172): enter170("watch");wait170=.3;return
  pad172.build172=clampf(clock170/WEAVE172,0.,1.)
  if clock170>=WEAVE172: pad172.commit172();enter170("happy");celebrations172+=1
 else:
  lift170=absf(sin(clampf(clock170/HAPPY172,0.,1.)*TAU))*.28
  if clock170>=HAPPY172: enter170("watch");wait170=.30;relocate171=true;lift170=0.
 velocity=Vector3(0.,-.3 if is_on_floor() else velocity.y-20.*delta,0.);move_and_slide();_render_legacy(lift170)
