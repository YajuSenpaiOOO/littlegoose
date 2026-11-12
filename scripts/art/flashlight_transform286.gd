extends Node3D
signal revealed
signal finished
const STAND=preload("res://assets/hero_transform284/stand_closed.png")
const RAISE=preload("res://assets/hero_transform284/raise_open.png")
const INTRO := 3.15
const TOTAL := 10.0
var age := 0.
var playing := false
var released := false
var actor: Sprite3D
var glow: ShaderMaterial
var idle_texture: Texture2D
var idle_offset := Vector2.ZERO
var pixel := .003
var motion := Vector3.ZERO
var motion_target := Vector3.ZERO
var strips: Array[MeshInstance3D]=[]
var lamp_light: OmniLight3D
var down_light: SpotLight3D
var last_cape: Array[Vector3]=[]
var beam_length := 80.
func _ready() -> void:
 actor=Sprite3D.new();actor.billboard=BaseMaterial3D.BILLBOARD_DISABLED;actor.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;actor.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST;add_child(actor)
 var shader=Shader.new()
 shader.code="""shader_type spatial;
 render_mode cull_disabled;
 uniform sampler2D art : source_color, filter_nearest;
 uniform float cover=0.0;
 uniform vec4 tint : source_color=vec4(1.0);
 void fragment(){
  vec4 c=texture(art,UV);
  ALBEDO=mix(c.rgb*tint.rgb,vec3(1.0,0.96,0.76),cover);
  ALPHA=c.a; ALPHA_SCISSOR_THRESHOLD=0.5;
  ROUGHNESS=1.0;SPECULAR=0.0;
  NORMAL_MAP=vec3(0.5,0.7113,0.9532);
  EMISSION=vec3(1.0,0.91,0.62)*cover*1.5;
 }"""
 glow=ShaderMaterial.new();glow.shader=shader;actor.material_override=glow;actor.hide()
 for i in 11:
  var node=MeshInstance3D.new();node.mesh=ImmediateMesh.new();node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  var material=StandardMaterial3D.new();material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;material.vertex_color_use_as_albedo=true;material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;material.cull_mode=BaseMaterial3D.CULL_DISABLED
  node.material_override=material;add_child(node);strips.append(node)
 lamp_light=OmniLight3D.new();lamp_light.light_color=Color(1.,.82,.48);lamp_light.omni_range=2.3;lamp_light.light_specular=0.;lamp_light.light_energy=0.;add_child(lamp_light)
 down_light=SpotLight3D.new();down_light.position=Vector3(0,5,0);down_light.rotation.x=-PI*.5;down_light.spot_range=7.;down_light.spot_angle=25.;down_light.light_color=Color(1.,.88,.66);down_light.light_specular=0.;down_light.light_energy=0.;add_child(down_light)
func ramp(a: float,b: float,t: float) -> float:return smoothstep(a,b,t)
func start() -> void:
 age=0.;released=false;playing=true;motion=Vector3.ZERO;motion_target=Vector3.ZERO;sample(0.)
func cape_amount() -> float:return ramp(1.22,2.05,age)*(1.-ramp(9.1,TOTAL,age)) if playing else 0.
func cancel() -> void:
 playing=false;actor.hide();lamp_light.light_energy=0.;down_light.light_energy=0.
 for node in strips:(node.mesh as ImmediateMesh).clear_surfaces()
func advance(delta: float) -> void:
 if not playing:return
 motion=motion.lerp(motion_target,1.-exp(-delta*7.))
 sample(age+delta)
 if age>=INTRO and not released:released=true;revealed.emit()
 if age>=TOTAL:cancel();finished.emit()
func sample(t: float) -> void:
 age=t
 if not playing:return
 actor.visible=age<INTRO;actor.flip_h=false
 if age<1.98:
  actor.texture=STAND if age<.52 else RAISE;actor.pixel_size=pixel*.595
  actor.offset=Vector2(actor.texture.get_width()*.5-587.,1230.-actor.texture.get_height()*.5)
 else:
  actor.texture=idle_texture;actor.pixel_size=pixel;actor.offset=Vector2(idle_offset.x,-idle_offset.y)
 glow.set_shader_parameter("art",actor.texture.atlas if actor.texture is AtlasTexture else actor.texture)
 glow.set_shader_parameter("cover",ramp(1.08,1.75,age)*(1.-ramp(2.02,2.5,age)))
 draw_effects()
func p(x: float,y: float,z := 0.) -> Vector3:return Vector3(x*pixel,y*pixel,z)
func strip(index: int,points: Array[Vector3],widths: Array[float],color: Color) -> void:
 var mesh=strips[index].mesh as ImmediateMesh;mesh.clear_surfaces()
 if points.size()<2 or color.a<.001:return
 mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
 for i in points.size():
  var tangent=points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]
  var normal=Vector3(-tangent.y,tangent.x,0.).normalized()
  mesh.surface_set_color(color);mesh.surface_add_vertex(points[i]+normal*widths[i])
  mesh.surface_set_color(color);mesh.surface_add_vertex(points[i]-normal*widths[i])
 mesh.surface_end()
func column(index: int,start: Vector3,end: Vector3,a: float,b: float,color: Color) -> void:
 var mesh=strips[index].mesh as ImmediateMesh;mesh.clear_surfaces()
 var normal=Vector3.LEFT
 mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
 for u in [-1.,-.75,-.4,0.,.4,.75,1.]:
  var alpha=color.a*pow(1.-absf(u),.7)
  mesh.surface_set_color(Color(color,alpha));mesh.surface_add_vertex(start+normal*a*u)
  mesh.surface_set_color(Color(color,alpha));mesh.surface_add_vertex(end+normal*b*u)
 mesh.surface_end()
func cape(side: float,index: int,amount: float) -> void:
 var points: Array[Vector3]=[];var widths: Array[float]=[]
 var travel=ramp(1.2,2.05,age);var speed=clampf(motion.length()/4.,0.,1.)
 for i in 27:
  var u=float(i)/26.
  if u>travel:break
  # Gravity first: upright drooping scarf. Only locomotion lifts/trails the ends.
  var v=1.-u
  var x=side*(95.*v*v*v+3.*240.*v*v*u+3.*330.*v*u*u+325.*u*u*u)+sin(age*2.+u*5.)*5.*u
  var y=277.*v*v*v+3.*280.*v*v*u+3.*170.*v*u*u+25.*u*u*u+speed*155.*pow(u,1.5)
  var point=p(x,y,-.07-u*.025)-Vector3(motion.x,0.,motion.z)*(.12*u*u)
  points.append(p(-126.,463.,.015).lerp(point,travel));widths.append((10.+45.*pow(1.-u,.6))*pixel*amount)
 if side>0.:last_cape=points.duplicate()
 strip(index,points,widths,Color(1.,.69,.23,.16*amount))
 var inner: Array[float]=[];var core: Array[float]=[]
 for w in widths:inner.append(w*.57);core.append(w*.12)
 strip(index+1,points,inner,Color(1.,.80,.39,.80*amount))
 strip(index+2,points,core,Color(1.,.96,.76,.92*amount))
func draw_effects() -> void:
 for node in strips:(node.mesh as ImmediateMesh).clear_surfaces()
 var amount=cape_amount()
 if amount>0.:cape(-1.,0,amount);cape(1.,3,amount)
 var lamp=p(-126.,463.,.015);lamp_light.position=lamp
 var beam=ramp(.68,.705,age)*(1.-ramp(1.28,1.7,age))
 var flare=ramp(.72,.80,age)*(1.-ramp(.86,1.04,age))
 var width=lerpf(2.,48.,ramp(.72,.83,age))*pixel
 if beam>0.:
  var top=lamp+Vector3.UP*beam_length*ramp(.68,.72,age)
  column(6,lamp,top,width*2.8,width*3.8,Color(1.,.81,.42,.12*beam))
  column(7,lamp,top,width,width*1.2,Color(1.,.93,.69,.48*beam))
  strip(8,[lamp,top],[maxf(2.*pixel,width*.38),width*.50],Color(1.,.99,.91,.95*beam))
 # A short transverse lens flare marks the switch-on impulse.
 if flare>0.:strip(9,[lamp+Vector3.LEFT*pixel*120.,lamp+Vector3.RIGHT*pixel*120.],[pixel*4.*flare,pixel*4.*flare],Color(1.,.94,.74,flare*.8))
 var fall=ramp(.98,1.18,age)*(1.-ramp(1.92,2.45,age))
 if fall>0.:
  var bottom=lerpf(12.,.02,ramp(.98,1.18,age))
  column(10,Vector3(0,bottom,-.035),Vector3(0,beam_length,-.035),pixel*255.,pixel*290.,Color(1.,.88,.60,.16*fall))
 lamp_light.light_energy=.6*beam+1.2*flare
 down_light.light_energy=.65*fall
