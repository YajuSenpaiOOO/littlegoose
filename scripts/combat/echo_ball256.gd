extends CharacterBody3D
var battle: Node3D
var direction := Vector2.RIGHT
var age256 := 0.
var bounces256 := 0
var speed256 := 3.6
var visual256: MeshInstance3D
var shadow256: MeshInstance3D
var last_bounce256 := -.2
func _ready() -> void:
 collision_layer=0;collision_mask=1|2;floor_snap_length=.35
 var shape=CollisionShape3D.new();var sphere=SphereShape3D.new();sphere.radius=.17;shape.shape=sphere;add_child(shape)
 visual256=MeshInstance3D.new();var mesh=SphereMesh.new();mesh.radius=.19;mesh.height=.38;mesh.radial_segments=12;mesh.rings=6;visual256.mesh=mesh
 var ink=StandardMaterial3D.new();ink.albedo_color=Color("a5e6bc");ink.roughness=.7;ink.metallic_specular=.15;visual256.material_override=ink;visual256.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(visual256)
 shadow256=MeshInstance3D.new();var plane=PlaneMesh.new();plane.size=Vector2(.48,.40);shadow256.mesh=plane
 var shade=ShaderMaterial.new();var shader=Shader.new();shader.code="shader_type spatial;render_mode unshaded,cull_disabled,depth_draw_never;void fragment(){float q=length((UV-.5)*2.);ALBEDO=vec3(.025,.035,.03);ALPHA=(1.-smoothstep(.25,1.,q))*.3;}";shade.shader=shader;shadow256.material_override=shade;shadow256.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(shadow256)
func rebound256(normal: Vector2) -> void:
 if age256-last_bounce256<.08:return
 last_bounce256=age256;direction=direction.bounce(normal).normalized();bounces256+=1;speed256*=.84
 if bounces256>2:queue_free()
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if not battle.active114 or not is_instance_valid(battle.boss247) or battle.boss247.dead:queue_free();return
 age256+=delta
 if age256>=2.7:queue_free();return
 velocity=Vector3(direction.x*speed256,-.5 if is_on_floor() else velocity.y-16.*delta,direction.y*speed256)
 var start=position;move_and_slide()
 for i in get_slide_collision_count():
  var normal=get_slide_collision(i).get_normal()
  if absf(normal.y)<.5:rebound256(Vector2(normal.x,normal.z).normalized());break
 var at=Vector2(position.x,position.z)
 if absf(battle.floor_height(at)-battle.floor_height(Vector2(start.x,start.z)))>.35:
  position=start;rebound256(-direction)
 visual256.position.y=absf(sin(age256*PI*5.))*.28*(1.-age256/3.)
 var shrink=1.-smoothstep(2.1,2.7,age256)
 visual256.scale=Vector3.ONE*shrink*pow(.86,bounces256)
 shadow256.global_position=Vector3(position.x,battle.floor_height(at)+.045,position.z);shadow256.scale=Vector3.ONE*shrink
 var hero=battle.hero
 if at.distance_to(Vector2(hero.position.x,hero.position.z))<.46 and absf(position.y-hero.position.y)<.75:
  if hero.can_parry():battle.parry_success(global_position,Vector3(direction.x,0,direction.y));queue_free()
  elif battle.invulnerability<=0.:battle.hurt_player(1.,at);queue_free()
