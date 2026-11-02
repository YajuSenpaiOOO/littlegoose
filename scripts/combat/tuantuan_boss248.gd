extends "res://scripts/combat/tuantuan_boss247.gd"
const BASE248 := 7
const CAP248 := 11
const RADIUS248 := 1.55
var total248 := BASE248
var extra248 := 0
var reflected248 := false
var boost248 := 0
var angry_lift248 := 0.
var deflects248 := 0
func enter247(next: String) -> void:
 super.enter247(next)
 if next=="angry":
  jump247=0;total248=BASE248;extra248=0;reflected248=false;boost248=0;lift247=0.;cycle247+=1
 if next=="squat":
  # Parent resets a three-jump cycle here; preserve this chain's initialized budget.
  cycle247-=1
 if next=="flat":reflected248=false;boost248=0
func duration248() -> float:
 return .43+pow(clampf(float(jump247)/6.,0.,1.),1.8)*.33 if boost248<=0 else .40
func height248() -> float:
 return maxf(.9,2.35-float(jump247)*.21) if boost248<=0 else 2.6
func lock247() -> void:
 from247=Vector2(position.x,position.z)
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 var wanted: Vector2
 if phase247=="pounce":wanted=from247+(player-from247).limit_length(4.2)
 elif not reflected248:
  var speed=maxf(4.2,9.8-float(jump247)*.85)
  var delta=(player-from247)
  if delta.length()>.05:forward247=delta.normalized()
  wanted=from247+delta.limit_length(speed*duration248())
 else:
  var speed=11. if boost248>0 else maxf(5.,9.8-float(jump247)*.5)
  wanted=from247+forward247*speed*duration248()
 goal247=battle.safe_goal247(from247,wanted)
 # A boundary acts as a bumper for the next full locked flight. Never tunnel through it.
 if reflected248 and goal247.distance_to(from247)<.35:
  forward247=-forward247
  goal247=battle.safe_goal247(from247,from247+forward247*3.5)
 flights247.append({"jump":jump247,"from":from247,"goal":goal247,"height":height248(),"duration":duration248(),"reflected":reflected248})
 marker247.show();draw_marker247()
func draw_marker247() -> void:
 super.draw_marker247()
 # Parent circle mesh is local in world coordinates: rebuild with this encounter's radius.
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var col=Color("8ce6f2") if reflected248 else Color("efb86b")
 for i in 48:
  var a=TAU*float(i)/48.;var b=TAU*float(i+1)/48.
  for pt in [Vector2(cos(a),sin(a))*(RADIUS248-.055),Vector2(cos(a),sin(a))*(RADIUS248+.055),Vector2(cos(b),sin(b))*(RADIUS248+.055),Vector2(cos(a),sin(a))*(RADIUS248-.055),Vector2(cos(b),sin(b))*(RADIUS248+.055),Vector2(cos(b),sin(b))*(RADIUS248-.055)]:
   var at: Vector2=goal247+pt;st.set_color(col);st.add_vertex(Vector3(at.x,battle.floor_height(at)+.07,at.y))
 marker247.mesh=st.commit()
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if dead:marker247.hide();super._physics_process(delta);return
 if not battle.active114 or battle.player_hp<=0.:
  lift247=0.;marker247.hide();velocity=Vector3.ZERO;render247();return
 clock247+=delta;age+=delta;_step_soft_response(delta);_step_squeeze(delta)
 for key in ["hit_left","hit_rearm","landing_left","flash","health_time","juice_gate","parry_stun"]:set(key,maxf(0.,float(get(key))-delta))
 var motion=Vector2.ZERO
 match phase247:
  "rest":
   if clock247>=1.05:
    if cycle247%2==0:enter247("angry")
    else:enter247("pounce_wait")
  "angry":
   # Three impatient little hops on one footprint, visibly separate from attack landings.
   lift247=absf(sin(clampf(clock247/.60,0.,1.)*PI*3.))*.32
   if clock247>=.60:enter247("squat");lift247=0.
  "squat":
   if clock247>=.65:enter247("flight");lock247()
  "rebound":
   if clock247>=.07+float(jump247)*.012:enter247("flight");lock247()
  "deflected":
   if clock247>=.20:enter247("flight");lock247()
  "flight","pounce":
   var duration=.48 if phase247=="pounce" else duration248()
   var height=.6 if phase247=="pounce" else height248()
   var t=clampf(clock247/duration,0.,1.);lift247=4.*height*t*(1.-t)
   motion=(from247.lerp(goal247,t)-Vector2(position.x,position.z))/maxf(delta,.001)
   if t>=1.:move247(motion,delta);land247();render247();return
  "pounce_wait":
   if clock247>=.65:enter247("pounce");lock247()
  "flat":
   if clock247>=2.1:enter247("rest")
 move247(motion,delta);render247()
func land247() -> void:
 lift247=0.;landing_left=.14;landing_count+=1;tuft_velocity+=.75
 var at=Vector2(position.x,position.z)
 landings247.append({"jump":jump247,"at":at,"goal":goal247,"phase":phase247,"reflected":reflected248})
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 if at.distance_to(player)<RADIUS248+.3 and absf(position.y-battle.hero.position.y)<.8:
  if battle.hero.can_parry():deflect(battle.hero.position+Vector3.UP*.65);return
  battle.hurt_player(touch110,at)
 battle.trauma=minf(1.,battle.trauma+.10)
 if is_instance_valid(battle.jelly_fx):battle.jelly_fx._play(battle.jelly_fx.landing_clip,position,-8.,.85)
 if phase247=="pounce":cycle247+=1;enter247("flat");return
 jump247+=1;boost248=maxi(0,boost248-1)
 if jump247<total248:enter247("rebound")
 else:enter247("flat")
func deflect(contact: Vector3) -> void:
 if dead or phase247 not in ["flight","pounce"]:return
 var pounce=phase247=="pounce"
 var incoming=goal247-from247
 if incoming.length()<.05:incoming=-Vector2(position.x-battle.hero.position.x,position.z-battle.hero.position.z)
 forward247=-incoming.normalized() if incoming.length()>.05 else -forward247
 parried_count+=1;deflects248+=1;attack_connected=true;lift247=0.;parry_lift=0.;impulse=Vector2.ZERO
 battle.parry_success(contact,Vector3(forward247.x,0,forward247.y))
 battle.boss_impact248(contact)
 if dead:return
 if pounce:cycle247+=1;enter247("flat");return
 reflected248=true;boost248=2;jump247+=1
 var added=mini(2,CAP248-total248);total248+=added;extra248+=added
 if jump247<total248:enter247("deflected")
 else:enter247("flat")
func _pose(key: String,lift: float) -> void:
 # Reuse the existing same-species annoyed face, retaining its own authored foot/size.
 if phase247 in ["angry","squat"] and poses.has("shove124") and not dead and hit_left<=0.:key="shove124"
 super._pose(key,lift)
func render247() -> void:
 super.render247()
 if phase247 in ["angry","squat"] and soft_ink!=null:
  var entry: Dictionary=poses.shove124;var size=visual.texture.get_size()
  soft_ink.set_shader_parameter("body_span",Vector2(float(entry.visible_width),float(entry.visible_height))/24./(size*visual.pixel_size))
  soft_ink.set_shader_parameter("foot_y",float(entry.foot[1])/size.y)
 if phase247=="angry":visual.rotation.z=sin(clock247*TAU*5.)*.07
 if phase247=="deflected":visual.scale*=Vector3(1.18,.78,1.)
