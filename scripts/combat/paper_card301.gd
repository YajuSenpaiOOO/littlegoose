extends "res://scripts/combat/tuantuan128.gd"
## A grounded combat target; only the art/operator hang above this footprint.
var kind301 := "dinosaur"
var ready301 := false
var state301 := "enter"
var clock301 := 0.
var locked301 := Vector2.ZERO
var direction301 := Vector2.DOWN
var connected301 := false
var operator301: Sprite3D
var thread301: MeshInstance3D
var cue301: MeshInstance3D
var spec301: Dictionary
var height301 := 2.1
var attacks301 := 0
var parries301 := 0
var hits301 := 0
func _ready() -> void:
 super._ready()
 mode119="playing";active_ai=true;collision_mask=1|2;hit_area.collision_layer=8
 cue.hide();cue.set_process(false);small_cue.hide();small_cue.set_process(false);shadow.hide()
 spec301=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper_cards301/layout.json"))[kind301]
 visual.billboard=BaseMaterial3D.BILLBOARD_DISABLED;visual.rotation=Vector3(deg_to_rad(-25.),0,0)
 # Card already faces the camera; do not double-tilt its lighting normal by
 # copying the upright hero's normal map. Match the existing paper props.
 var paper_ink=StandardMaterial3D.new();paper_ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;paper_ink.cull_mode=BaseMaterial3D.CULL_DISABLED;paper_ink.texture_filter=visual.texture_filter;paper_ink.roughness=1.;paper_ink.metallic_specular=0.;paper_ink.vertex_color_use_as_albedo=true;paper_ink.albedo_color=Color(.7,.7,.7,1.)
 visual.material_override=paper_ink;visual.shaded=true
 visual.texture=load("res://assets/paper_cards301/"+kind301+".png");visual.material_override.albedo_texture=visual.texture
 visual.pixel_size=height301/float(spec301.span[1]);visual.offset=Vector2(visual.texture.get_width()*.5-float(spec301.foot[0]),float(spec301.foot[1])-visual.texture.get_height()*.5)
 var target=CapsuleShape3D.new();target.radius=.65;target.height=2.;hit_area.get_child(0).shape=target
 operator301=Sprite3D.new();operator301.texture=preload("res://assets/paper134/base_C.png");operator301.texture_filter=visual.texture_filter;operator301.rotation.x=deg_to_rad(-25.);operator301.pixel_size=1./1019.;operator301.offset=Vector2(operator301.texture.get_width()*.5-593.5,1205.-operator301.texture.get_height()*.5);operator301.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 operator301.material_override=visual.material_override.duplicate();operator301.material_override.albedo_texture=operator301.texture;add_child(operator301)
 thread301=MeshInstance3D.new();thread301.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(thread301)
 var ink=StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color("eed5a1");thread301.material_override=ink
 cue301=MeshInstance3D.new();cue301.top_level=true;cue301.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(cue301)
 var cue_ink=StandardMaterial3D.new();cue_ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;cue_ink.vertex_color_use_as_albedo=true;cue_ink.cull_mode=BaseMaterial3D.CULL_DISABLED;cue_ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;cue301.material_override=cue_ink
 ready301=true;render301()
func enter301(next: String) -> void:
 state301=next;clock301=0.;connected301=false
 attack_phase="windup" if next=="warn" else ("lunge" if next=="attack" else "recover")
 if next=="warn":
  locked301=battle.paper_clamp301(Vector2(battle.hero.position.x,battle.hero.position.z))
  direction301=(locked301-Vector2(position.x,position.z)).normalized()
  if direction301.length()<.1:direction301=Vector2.DOWN
 if next=="attack":attacks301+=1
func receive_hit(damage: float,direction: Vector3) -> void:
 if dead or not ready301 or state301=="enter":return
 hp=maxf(0.,hp-damage);hit_count+=1;flash=.12;health_time=1.4;hit_direction=direction.normalized()
 battle.on_legacy_contact(self,contact_point301(), direction,juice_gate<=0. or hp<=0.);juice_gate=.12
 if hp<=0.:
  dead=true;clock301=0.;state301="broken";hit_area.set_deferred("collision_layer",0);set_deferred("collision_layer",0);battle.enemy_defeated(self)
func deflect(contact: Vector3) -> void:
 if dead or state301!="attack":return
 parries301+=1;connected301=true
 enter301("stunned");flash=.15;receive_hit(4.,Vector3(direction301.x,0,direction301.y))
 battle.parry_success(contact,Vector3(-direction301.x,0,-direction301.y))
func _physics_process(delta: float) -> void:
 if not ready301 or battle.combat_paused:return
 clock301+=delta;age+=delta;flash=maxf(0.,flash-delta);health_time=maxf(0.,health_time-delta);juice_gate=maxf(0.,juice_gate-delta)
 if dead:
  render301()
  if clock301>.65:queue_free()
  return
 if not battle.active114:cue301.hide();return
 var at=Vector2(position.x,position.z);var player=Vector2(battle.hero.position.x,battle.hero.position.z);var motion=Vector2.ZERO
 match state301:
  "enter":
   if clock301>.85:hit_area.collision_layer=8;enter301("rest")
  "rest":
   var desired=battle.paper_clamp301(player+(at-player).normalized()*(3.5 if kind301=="dinosaur" else 1.5))
   motion=(desired-at).limit_length(1.)*1.4
   if clock301>1.2+role110*.12:enter301("warn")
  "warn":
   if clock301>.95:enter301("attack")
  "attack":
   if kind301=="knight":motion=direction301*8.
   if kind301=="monster" and clock301<.24:motion=(locked301-at)/maxf(.24-clock301,delta)
   var before=attack_at301()
   move301(motion,delta);at=attack_at301()
   var contact=false
   if kind301=="dinosaur":
    var relative=player-at;contact=relative.length()<4.6 and (relative.length()<.1 or relative.normalized().dot(direction301)>cos(.45))
   elif kind301=="knight":contact=battle.aim_model.sweep_circle(before,at,player,.9)<=1.
   else:contact=clock301>=.24 and clock301<.44 and player.distance_to(at)<1.55
   if contact:
    var sight=PhysicsRayQueryParameters3D.create(attack_origin301(),battle.hero.position+Vector3.UP*.7,1|2)
    contact=get_world_3d().direct_space_state.intersect_ray(sight).is_empty()
   if contact and not connected301 and absf(position.y-battle.hero.position.y)<.85:
    connected301=true
    if battle.hero.can_parry():deflect(battle.hero.position+Vector3.UP*.7)
    else:
     var previous=battle.player_hp;battle.hurt_player(1.5,at)
     if battle.player_hp<previous:hits301+=1
   if state301=="attack" and clock301>(1.05 if kind301=="dinosaur" else .55):enter301("recover")
   render301();return
  "recover","stunned":
   if clock301>(1.5 if state301=="stunned" else 1.1):enter301("rest")
 move301(motion,delta);render301()
func move301(motion: Vector2,delta: float) -> void:
 motion*=clampf(float(get_meta("locomotion_scale153",1.)),.6,1.)
 var wanted=battle.paper_clamp301(Vector2(position.x,position.z)+motion*delta)
 motion=(wanted-Vector2(position.x,position.z))/maxf(delta,.001)
 velocity=Vector3(motion.x,-.3 if is_on_floor() else velocity.y-20.*delta,motion.y);move_and_slide()
func attack_at301() -> Vector2:return Vector2(position.x,position.z)
func attack_origin301() -> Vector3:return position+Vector3.UP*.8
func contact_point301() -> Vector3:return position+Vector3.UP
func render301() -> void:
 if not ready301:return
 var lift=.22+sin(age*2.5+role110)*.045
 if state301=="enter":lift+=5.*(1.-smoothstep(0.,.85,clock301));hit_area.collision_layer=0
 if kind301=="monster" and state301 in ["warn","attack"]:lift+=.9 if state301=="warn" else .9*(1.-smoothstep(0.,.24,clock301))
 if dead:lift+=clock301*5.
 visual.position.y=lift;visual.rotation.z=sin(age*3.)*.035+(sin(age*19.)*.07 if state301=="stunned" else 0.);visual.modulate=Color(1.4,1.15,1.05) if flash>0. else Color.WHITE
 hit_area.position.y=1.+minf(lift,.9)
 visual.transparency=clampf(clock301/.65,0.,1.) if dead else 0.
 operator301.position=Vector3(sin(age*1.7)*.12,3.1+lift,.2);operator301.transparency=visual.transparency
 var tab=Vector3((float(spec301.tab[0])-float(spec301.foot[0]))*visual.pixel_size,(float(spec301.foot[1])-float(spec301.tab[1]))*visual.pixel_size,0.)
 var a=visual.transform*tab;var b=operator301.position+Vector3(0,.08,0)
 var rope=ImmediateMesh.new();rope.surface_begin(Mesh.PRIMITIVE_LINES);rope.surface_add_vertex(a);rope.surface_add_vertex(b);rope.surface_end();thread301.mesh=rope;thread301.visible=not dead
 health_fill.visible=health_time>0. and not dead;health_fill.position=Vector3(-.45*(1.-hp/max_hp110),2.55+lift,0.);health_fill.scale.x=maxf(.001,hp/max_hp110)
 cue301.visible=state301 in ["warn","attack"] and not dead
 if cue301.visible:draw_cue301()
func draw_cue301() -> void:
 var mesh301=SurfaceTool.new();mesh301.begin(Mesh.PRIMITIVE_TRIANGLES)
 var at=attack_at301();var color=Color(1.,.67,.25,.30 if state301=="warn" else .72)
 var points: Array[Vector2]=[]
 if kind301=="monster":
  for i in 24:points.append(locked301+Vector2(cos(TAU*i/24.),sin(TAU*i/24.))*1.35)
 elif kind301=="knight":
  var cross=direction301.orthogonal()*.65;points=[at-cross,at+direction301*4.4-cross,at+direction301*4.4+cross,at+cross]
 else:
  points.append(at)
  for i in 17:points.append(at+direction301.rotated(lerpf(-.45,.45,float(i)/16.))*4.6)
 for i in range(1,points.size()-1):
  for p in [points[0],points[i],points[i+1]]:mesh301.set_color(color);mesh301.add_vertex(Vector3(p.x,battle.floor_height(p)+.075,p.y))
 cue301.mesh=mesh301.commit();cue301.global_transform=Transform3D.IDENTITY
