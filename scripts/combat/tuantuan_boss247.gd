extends "res://scripts/combat/tuantuan128.gd"
## Authored legacy body, independent boss AI. Flight stays on the ground root;
## sprite AND native target rise together, while movement still uses terrain collision.
const HEIGHTS247 = [2.8, 1.55, .68]
const TIMES247 = [.94, .70, .46]
const RADIUS247 = 1.18
var phase247 := "rest"
var clock247 := 0.
var jump247 := 0
var cycle247 := 0
var lift247 := 0.
var from247 := Vector2.ZERO
var goal247 := Vector2.ZERO
var forward247 := Vector2.DOWN
var landings247: Array = []
var marker247: MeshInstance3D
var flights247: Array = []
func _ready() -> void:
 super._ready()
 if is_instance_valid(flower110):flower110.queue_free()
 cue.hide();cue.set_process(false)
 marker247=MeshInstance3D.new();marker247.top_level=true;add_child(marker247)
 marker247.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink=StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.vertex_color_use_as_albedo=true;ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 marker247.material_override=ink
 shadow.show();shadow.scale=Vector3(body_scale110,1.,body_scale110)
 mode119="playing";active_ai=true;hit_area.collision_layer=8
 enter247("rest")
func enter247(next: String) -> void:
 phase247=next;clock247=0.;attack_connected=false
 # Disable legacy lunge cue/parry sweeps: this AI owns its landing-only damage.
 attack_phase="recover";hopping=false
 if next=="squat":
  jump247=0;cycle247+=1;lift247=0.
  battle.Audio.play("parry_on",.7)
 if next in ["rest","flat"]:lift247=0.;marker247.hide()
func lock247() -> void:
 from247=Vector2(position.x,position.z)
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 var wanted: Vector2
 if phase247=="pounce":wanted=from247+(player-from247).limit_length(3.7)
 elif jump247<2:
  var reach: float=[6.,3.5][jump247]
  wanted=from247+(player-from247).limit_length(reach)
  if wanted.distance_to(from247)>.05:forward247=(wanted-from247).normalized()
 else:wanted=from247+forward247*.85
 goal247=battle.safe_goal247(from247,wanted)
 flights247.append({"jump":jump247,"from":from247,"goal":goal247,"height":HEIGHTS247[jump247] if phase247!="pounce" else .5})
 marker247.show();draw_marker247()
func draw_marker247() -> void:
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var col=Color("efbd69")
 for i in 48:
  var a=TAU*float(i)/48.;var b=TAU*float(i+1)/48.
  for pt in [Vector2(cos(a),sin(a))*(RADIUS247-.045),Vector2(cos(a),sin(a))*(RADIUS247+.045),Vector2(cos(b),sin(b))*(RADIUS247+.045),Vector2(cos(a),sin(a))*(RADIUS247-.045),Vector2(cos(b),sin(b))*(RADIUS247+.045),Vector2(cos(b),sin(b))*(RADIUS247-.045)]:
   var at: Vector2=goal247+pt;st.set_color(col);st.add_vertex(Vector3(at.x,battle.floor_height(at)+.07,at.y))
 marker247.mesh=st.commit();marker247.global_transform=Transform3D.IDENTITY
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if dead:
  marker247.hide();super._physics_process(delta);return
 if not battle.active114 or battle.player_hp<=0.:
  lift247=0.;marker247.hide();velocity=Vector3.ZERO;render247();return
 clock247+=delta;age+=delta
 _step_soft_response(delta);_step_squeeze(delta)
 for key in ["hit_left","hit_rearm","landing_left","flash","health_time","juice_gate","parry_stun"]:set(key,maxf(0.,float(get(key))-delta))
 var motion=Vector2.ZERO
 match phase247:
  "rest":
   if clock247>=1.25:
    if cycle247%2==0:enter247("squat")
    else:enter247("pounce_wait");goal247=Vector2(battle.hero.position.x,battle.hero.position.z)
  "squat":
   if clock247>=.85:enter247("flight");lock247()
  "rebound":
   if clock247>=.10:enter247("flight");lock247()
  "flight","pounce":
   var duration: float=.48 if phase247=="pounce" else TIMES247[jump247]
   var height: float=.5 if phase247=="pounce" else HEIGHTS247[jump247]
   var t=clampf(clock247/duration,0.,1.)
   lift247=4.*height*t*(1.-t)
   var wanted=from247.lerp(goal247,t)
   motion=(wanted-Vector2(position.x,position.z))/maxf(delta,.001)
   if t>=1.:
    move247(motion,delta);land247();render247();return
  "pounce_wait":
   if clock247>=.65:enter247("pounce");lock247()
  "flat":
   if clock247>=2.1:enter247("rest")
 move247(motion,delta);render247()
func move247(motion: Vector2,delta: float) -> void:
 # Never apply shot knockback to a locked flight trajectory.
 impulse=Vector2.ZERO
 velocity=Vector3(motion.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y)
 move_and_slide()
func land247() -> void:
 lift247=0.;landing_left=.13;landing_count+=1;tuft_velocity+=.55
 var at=Vector2(position.x,position.z)
 landings247.append({"jump":jump247,"at":at,"goal":goal247,"phase":phase247})
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 if at.distance_to(player)<RADIUS247+.3 and absf(position.y-battle.hero.position.y)<.8:
  if battle.hero.can_parry():
   deflect(battle.hero.position+Vector3.UP*.65);return
  battle.hurt_player(touch110,at)
 if is_instance_valid(battle.jelly_fx):battle.jelly_fx._play(battle.jelly_fx.landing_clip,position,-10.,.8+float(jump247)*.12)
 if phase247=="pounce":cycle247+=1;enter247("flat")
 elif jump247<2:jump247+=1;enter247("rebound")
 else:enter247("flat")
func render247() -> void:
 hopping=phase247 in ["flight","pounce"];hop_clock=.12 if hopping else 0.
 if phase247 in ["squat","rebound","pounce_wait","flat"]:landing_left=.1
 _render_legacy(lift247)
 var squash=0.
 if phase247=="squat":squash=.30*smoothstep(0.,.85,clock247)
 elif phase247=="rebound":squash=.22
 elif phase247=="pounce_wait":squash=.14*smoothstep(0.,.65,clock247)
 elif phase247=="flat":squash=.38*(1.-smoothstep(1.35,2.1,clock247))
 elif hopping:squash=-.09*sin(clampf(clock247/.15,0.,1.)*PI)
 visual.scale*=Vector3(1.+squash*.65,1.-squash,1.)
 # Rank110 intentionally pins ground targets; override ONLY this actor to match flight.
 hit_area.position.y=.8*body_scale110+lift247
 shadow.visible=true;shadow.scale=Vector3(body_scale110*(1.-minf(lift247*.12,.4)),1.,body_scale110*(1.-minf(lift247*.12,.4)))
 health_fill.position.y=1.55*body_scale110+lift247
func deflect(contact: Vector3) -> void:
 super.deflect(contact);parry_lift=0.;enter247("flat")
func receive_hit(damage: float,direction: Vector3) -> void:
 super.receive_hit(damage,direction)
 if dead:marker247.hide();hit_area.collision_layer=0;collision_layer=0
 else:render247()
