extends "res://scripts/combat/paper_card301.gd"
## A small damped spherical pendulum, driven by the moving support and hits.
## Presentation stays upright: x/z displacement, z lean, never a pitched card.
const HOVER302 := .65
const LIMIT302 := .48
var ready302 := false
var angle302 := Vector2.ZERO
var angular302 := Vector2.ZERO
var anchor_velocity302 := Vector2.ZERO
var rope_length302 := .8
var thread_mesh302 := ImmediateMesh.new()
var simulation_steps302 := 0
func _ready() -> void:
 super._ready()
 visual.rotation=Vector3.ZERO;operator301.rotation=Vector3.ZERO
 # Same material normal treatment as the existing upright hero, own colour.
 var upright=preload("res://scripts/combat/hero192.gd").make_receiver192()
 upright.albedo_color=Color(.7,.7,.7,1.);upright.albedo_texture=visual.texture
 visual.material_override=upright
 operator301.material_override=upright.duplicate();operator301.material_override.albedo_texture=operator301.texture
 angle302=Vector2(.025 if role110%2==0 else -.025,0.)
 thread301.mesh=thread_mesh302
 ready302=true;render301()
func move301(motion: Vector2,delta: float) -> void:
 var start=position
 super.move301(motion,delta)
 var v=Vector2(position.x-start.x,position.z-start.z)/maxf(delta,.001)
 var acceleration=(v-anchor_velocity302)/maxf(delta,.001)
 anchor_velocity302=v
 step302(delta,acceleration.limit_length(35.))
 if ready302:pose302()
func step302(delta: float,acceleration: Vector2) -> void:
 # Fixed small substeps also keep long test/editor frames stable.
 var count=maxi(1,int(ceil(delta*120.)));var dt=delta/float(count)
 var length=maxf(.6,rope_length302+height301*.45)
 var angle_limit := .72 if boss_recoil325() else LIMIT302
 var speed_limit := 4.8 if boss_recoil325() else 3.6
 for i in count:
  var wind=Vector2(sin(age*.85+role110)*.035,0.)
  angular302+=(-angle302*(9.8/length)-angular302*1.65-acceleration/length+wind)*dt
  angular302=angular302.limit_length(speed_limit)
  angle302+=angular302*dt
  if angle302.length()>angle_limit:
   var outward=angle302.normalized();angle302=outward*angle_limit
   if angular302.dot(outward)>0.:angular302-=outward*angular302.dot(outward)*1.2
  simulation_steps302+=1
func _physics_process(delta: float) -> void:
 if ready302 and dead and not battle.combat_paused:step302(delta,Vector2.ZERO)
 super._physics_process(delta)
func boss_recoil325() -> bool:
 return false

func receive_hit(damage: float,direction: Vector3) -> void:
 if dead or not ready302 or state301=="enter":return
 var stronger := boss_recoil325()
 var incoming := Vector2(direction.x, direction.z)
 if incoming.length_squared() > .000001:
  var impulse := clampf(1.12 + damage * .32, 1.25, 2.8) if stronger else clampf(.28 + damage * .12, .4, 1.15)
  angular302 = (angular302 + incoming.normalized() * impulse).limit_length(4.8 if stronger else 3.6)
 var interrupt := stronger and state301 == "warn" and damage >= 2.4
 super.receive_hit(damage,direction)
 impact_contact=Vector3.INF
 if interrupt and not dead:
  enter301("stunned")
 if ready302:render301()

func deflect(contact: Vector3) -> void:
 if dead or state301!="attack":return
 super.deflect(contact)
 var away=Vector2(position.x-battle.hero.position.x,position.z-battle.hero.position.z).normalized()
 angular302=(angular302+away*2.6).limit_length(3.6);render301()
func enter301(next: String) -> void:
 super.enter301(next)
 if ready302 and next=="warn":
  direction301=(locked301-attack_at301()).normalized()
  if direction301.length()<.1:direction301=Vector2.DOWN
func render301() -> void:
 if not ready302:
  super.render301();return
 pose302()
 var attachment=visual.transform*tab302()
 var support=thread_support302()
 thread_mesh302.clear_surfaces();thread_mesh302.surface_begin(Mesh.PRIMITIVE_LINES);thread_mesh302.surface_add_vertex(attachment);thread_mesh302.surface_add_vertex(support);thread_mesh302.surface_end();thread301.visible=not dead
 health_fill.visible=health_time>0. and not dead;health_fill.position=visual.position+Vector3(-.45*(1.-hp/max_hp110),2.55,0.);health_fill.scale.x=maxf(.001,hp/max_hp110)
 cue301.visible=state301 in ["warn","attack"] and not dead
 if cue301.visible:draw_cue301()
func thread_support302() -> Vector3:
 return operator301.position+Vector3(0,.08,0)
func tab302() -> Vector3:
 return Vector3((float(spec301.tab[0])-float(spec301.foot[0]))*visual.pixel_size,(float(spec301.foot[1])-float(spec301.tab[1]))*visual.pixel_size,0.)
func pose302() -> void:
 var lift=lift302()
 var extra=5.*(1.-smoothstep(0.,.85,clock301)) if state301=="enter" else 0.
 if dead:extra+=clock301*5.
 if state301=="enter":hit_area.collision_layer=0
 var tab=tab302()
 # Fixed support, variable rope paid out for the monster's lift/drop.
 operator301.position=Vector3(0,3.55+extra,.02)
 var support=operator301.position+Vector3(0,.08,0)
 rope_length302=maxf(.12,support.y-extra-lift-tab.y)
 var theta=angle302.length();var sideways=angle302.normalized()*sin(theta)*rope_length302 if theta>.00001 else Vector2.ZERO
 var attachment=support+Vector3(sideways.x,-cos(theta)*rope_length302,sideways.y)
 visual.rotation=Vector3(0,0,angle302.x*.75)
 visual.position=attachment-visual.basis*tab
 visual.modulate=Color(1.4,1.15,1.05) if flash>0. else Color.WHITE
 visual.transparency=clampf(clock301/.65,0.,1.) if dead else 0.
 operator301.transparency=visual.transparency
 hit_area.position=visual.transform*Vector3(0,height301*.5,0)
 hit_area.rotation=Vector3(0,0,visual.rotation.z)
func lift302() -> float:
 var lift=HOVER302
 if kind301=="monster":
  if state301=="warn":lift+=.6*smoothstep(0.,.45,clock301)
  elif state301=="attack":lift=lerpf(HOVER302+.6,.12,smoothstep(0.,.24,clock301))
 return lift
func attack_at301() -> Vector2:
 if not ready302:return super.attack_at301()
 var centre=to_global(visual.transform*Vector3(0,height301*.5,0));return Vector2(centre.x,centre.z)
func attack_origin301() -> Vector3:
 if not ready302:return super.attack_origin301()
 return to_global(visual.transform*Vector3(0,.5,0))
func contact_point301() -> Vector3:
 if impact_contact.is_finite():return impact_contact
 return hit_area.global_position if ready302 else super.contact_point301()
