extends Node3D
## Non-targetable presentation rig. Four gold-ring anchors carry four mesh straps.
var world: Node3D
var cat: CharacterBody3D
var bats225: Array[Sprite3D]=[]
var straps225: Array[MeshInstance3D]=[]
var textures225: Array[Texture2D]=[]
var clock225 := 0.
var connected225 := true
var hooks225: Array[Vector3]=[]
var exit_from225: Array[Vector3]=[]
var exit225 := 0.
func _ready() -> void:
 cat=preload("res://scripts/art/fat_cat216.gd").new();cat.world=world;cat.origin216=world.arena220;cat.width216=3.;add_child(cat)
 cat.manual216=true;cat.original216=true;cat.set_physics_process(false);cat.collision_layer=0;cat.collision_mask=0;cat.update_visual216()
 textures225=[load("res://assets/sister205/bat_up.png"),load("res://assets/sister205/bat_down.png")]
 for i in 4:
  var bat=Sprite3D.new();bat.shaded=true;bat.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  bat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;bat.extra_cull_margin=4.
  var ink=ShaderMaterial.new();ink.shader=preload("res://scripts/art/sister_receiver207.gdshader");bat.material_override=ink
  add_child(bat);bats225.append(bat)
  var shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=world;shadow.visual=bat;shadow.opacity_scale=.2;add_child(shadow);world.actor_shadows.append(shadow)
  var strap=MeshInstance3D.new();strap.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  var mat=StandardMaterial3D.new();mat.albedo_color=Color("c0a4cf");mat.cull_mode=BaseMaterial3D.CULL_DISABLED;strap.material_override=mat
  add_child(strap);straps225.append(strap)
 hide()
func reset225() -> void:
 clock225=0.;exit225=0.;connected225=true;exit_from225.clear();cat.visual.scale=Vector3.ONE;show()
func place225(at: Vector3,delta: float,release: float=0.,squash: float=0.) -> void:
 clock225+=delta;cat.global_position=at;cat._process(0.)
 cat.visual.scale=Vector3(1.+squash*.35,1.-squash,1.)
 cat.shadow.opacity_scale=.6 if release>0. else .25
 var basis225: Basis=world.camera.global_basis
 hooks225.clear()
 for i in 4:
  var x=[-1.55,-.55,.55,1.55][i];var y=1.6 if i in [0,3] else 1.85
  var ring=at+basis225.x*x+basis225.y*y
  if release>0.:
   if exit_from225.is_empty():
    for bat in bats225:exit_from225.append(bat.global_position)
   var pixels=(world.camera.unproject_position(at+basis225.x)-world.camera.unproject_position(at)).length()
   var remaining=(world.get_viewport().get_visible_rect().size.x+180.-world.camera.unproject_position(exit_from225[i]).x)/maxf(1.,pixels)
   ring=exit_from225[i]+basis225.x*remaining*smoothstep(0.,1.,release)+Vector3.UP*sin(release*PI)*.15
  hooks225.append(ring)
  var bat=bats225[i];var frame=(int(clock225*8.)+i)%2
  var texture=textures225[frame];var anchor=texture.get_size()*Vector2(.5,.805)
  bat.texture=texture;bat.pixel_size=.8*world.rig220.display_scale206/739.
  bat.offset=Vector2(texture.get_width()*.5-anchor.x,anchor.y-texture.get_height()*.5)
  bat.global_basis=basis225;bat.global_position=ring
  var ink: ShaderMaterial=bat.material_override;ink.set_shader_parameter("paint",texture)
  ink.set_shader_parameter("foot199",Vector3(ring.x,world.floor_height(Vector2(ring.x,ring.z)),ring.z));ink.set_shader_parameter("camera199",world.camera.global_position)
  ink.set_shader_parameter("plane_normal199",Vector3(basis225.z.x,0.,basis225.z.z).normalized())
  ink.set_shader_parameter("receiver_normal207",(world.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))).normalized())
  var strap=straps225[i];strap.visible=release<=0.
  if strap.visible:
   var attach=at+basis225.x*float([-1.,-.35,.35,1.][i])+basis225.y*.55
   var side=basis225.x*.018;var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
   for point in [ring-side,ring+side,attach+side,ring-side,attach+side,attach-side]:st.add_vertex(point)
   strap.mesh=st.commit()
