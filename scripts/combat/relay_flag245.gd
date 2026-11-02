extends Node3D
const ROOT="res://assets/relay_flag245/"
const PX=1.25/819.
var battle: Node3D
var phase := "gone"
var age := 0.
var lifetime := 0.
var pending := {}
var target := Vector3.ZERO
var flip := 1.
var ground := Vector3.ZERO
var pieces: Array[Sprite3D]=[]
var inks: Array[ShaderMaterial]=[]
var idle: Texture2D
var firing: Texture2D
var shadow: MeshInstance3D
var chips: Array[Dictionary]=[]
var kind := "soil_grass"
var planted := 0
var emitted := 0
var history: Array[String]=[]
func texture245(file: String) -> Texture2D:
 var image=Image.load_from_file(ROOT+file);image.generate_mipmaps();return ImageTexture.create_from_image(image)
func _ready() -> void:
 idle=texture245("goose-idle.png");firing=texture245("goose-fire.png")
 var specs=[["pencil.png",1.,Vector2.ZERO],["banner.png",.84,Vector2(110.48,84.6)],["goose-idle.png",.43,Vector2(330.915,313.715)]]
 for i in 3:
  var spec=specs[i];var tex=texture245(spec[0]);var sprite=Sprite3D.new();sprite.texture=tex;sprite.pixel_size=PX*float(spec[1]);sprite.offset=Vector2(tex.get_width()*.5+(spec[2].x-332.)/spec[1],(895.-spec[2].y)/spec[1]-tex.get_height()*.5)
  sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  var ink=ShaderMaterial.new();ink.shader=shader245();ink.set_shader_parameter("paint",tex)
  ink.set_shader_parameter("hinge245",Vector2(596.-332.,895.-177.)*PX if i>0 else Vector2.ZERO)
  sprite.material_override=ink;add_child(sprite);pieces.append(sprite);inks.append(ink)
 shadow=MeshInstance3D.new();var plane=PlaneMesh.new();plane.size=Vector2(.40,.22);shadow.mesh=plane;shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var mat=ShaderMaterial.new();var shader=Shader.new();shader.code="shader_type spatial; render_mode unshaded, cull_disabled, depth_draw_never; void fragment(){float r=length((UV-vec2(.5))*2.);ALBEDO=vec3(.11,.08,.15);ALPHA=(1.-smoothstep(.3,1.,r))*.18;}";mat.shader=shader;shadow.material_override=mat;battle.add_child(shadow)
 clear245()
func enter245(value: String) -> void:phase=value;age=0.;history.append(value)
func clear245() -> void:
 phase="gone";pending.clear();hide()
 if is_instance_valid(shadow):shadow.hide()
 for chip in chips:
  if is_instance_valid(chip.node):chip.node.queue_free()
 chips.clear()
func plant245(at: Vector3,material: String="soil_grass") -> void:
 clear245();ground=at;ground.y=battle.floor_height(Vector2(at.x,at.z))+.025
 kind=material;flip=1.;lifetime=0.;planted+=1;history.clear();enter245("drop");show();shadow.show();shadow.position=ground+Vector3.UP*.005
 render245()
func offer245(packet: Dictionary,aim: Vector3) -> bool:
 if phase not in ["drop","settle","ready"] or not pending.is_empty() or packet.get("specs",[]).is_empty():return false
 pending=packet.duplicate(true);target=aim
 flip=-1. if battle.camera.unproject_position(aim).x<battle.camera.unproject_position(ground).x else 1.
 if phase=="ready":enter245("puff")
 return true
func mouth245() -> Vector3:
 return global_position+battle.camera.global_basis.x*(.686*flip)+battle.camera.global_basis.y*.625
func burst245() -> void:
 var palette=[Color("807054"),Color("665a43"),Color("a5a466")]
 if kind=="stone":palette=[Color("92949c"),Color("626575"),Color("b7b8c2")]
 if kind=="wood_indoor":palette=[Color("e3cead"),Color("d3b692"),Color("af8f72")]
 for i in 6:
  var node=MeshInstance3D.new();var mesh=SphereMesh.new();mesh.radius=.018;mesh.height=.036;mesh.radial_segments=4;mesh.rings=2;node.mesh=mesh;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  var material=StandardMaterial3D.new();material.albedo_color=palette[i%3];material.roughness=1.;node.material_override=material;battle.add_child(node);node.position=ground
  var angle=TAU*i/6.;chips.append({"node":node,"velocity":Vector3(cos(angle)*.45,.6+float(i%2)*.2,sin(angle)*.45),"age":0.})
func _process(delta: float) -> void:
 if not is_instance_valid(battle) or battle.combat_paused:return
 for i in range(chips.size()-1,-1,-1):
  var chip=chips[i];chip.age+=delta;chip.velocity+=Vector3.DOWN*delta*4.;chip.node.position+=chip.velocity*delta;chip.node.scale=Vector3.ONE*maxf(.01,1.-chip.age/.4)
  if chip.age>=.4:chip.node.queue_free();chips.remove_at(i)
 if phase=="gone":return
 if not battle.active114:clear245();return
 age+=delta;lifetime+=delta
 if phase=="drop" and age>=.28:enter245("settle");burst245()
 elif phase=="settle" and age>=.18:enter245("puff" if not pending.is_empty() else "ready")
 elif phase=="ready" and ready_timeout245()>=0. and lifetime>ready_timeout245():enter245("roll")
 elif phase=="puff" and age>=.12:
  enter245("fire");emitted+=1;battle.emit_relay245(pending,mouth245(),target);pending.clear()
 elif phase=="fire" and age>=.18:enter245("roll")
 elif phase=="roll" and age>=.36:clear245();return
 render245()
func render245() -> void:
 var height=0.;var unfold=1.;var angle=0.;var opacity=1.
 if phase=="drop":height=2.4*(1.-pow(clampf(age/.28,0.,1.),2.));unfold=.06
 elif phase=="settle":unfold=lerpf(.06,1.,smoothstep(0.,.18,age));angle=sin(age/.18*TAU)*.045*(1.-age/.18)
 elif phase=="ready":angle=sin(lifetime*3.)*.012
 elif phase=="puff":angle=-sin(age/.12*PI)*.025
 elif phase=="fire":angle=sin(age/.18*PI)*.04
 elif phase=="roll":unfold=1.-smoothstep(0.,.3,age);opacity=1.-smoothstep(.14,.36,age)
 var insertion=.035 if kind=="soil_grass" else (.008 if kind=="stone" else 0.)
 if phase=="drop":insertion=0.
 elif phase=="settle":
  insertion*=smoothstep(0.,.18,age)
  if kind=="wood_indoor":height+=sin(age/.18*PI)*.04
 global_position=ground+Vector3.UP*(height-insertion)
 pieces[2].texture=firing if phase=="fire" else idle;inks[2].set_shader_parameter("paint",pieces[2].texture)
 var normal=Vector3(battle.camera.global_basis.z.x,0.,battle.camera.global_basis.z.z).normalized()
 for i in 3:
  inks[i].set_shader_parameter("foot199",ground+normal*float(i)*.003);inks[i].set_shader_parameter("camera199",battle.camera.global_position);inks[i].set_shader_parameter("plane_normal199",normal)
  inks[i].set_shader_parameter("settle245",sin(age/.18*TAU)*.018*(1.-age/.18) if phase=="settle" else 0.)
  inks[i].set_shader_parameter("flip245",flip);inks[i].set_shader_parameter("unfold245",unfold if i>0 else 1.);inks[i].set_shader_parameter("angle245",angle if i>0 else 0.);inks[i].set_shader_parameter("opacity245",opacity)
func _exit_tree() -> void:
 if is_instance_valid(shadow):shadow.queue_free()
 for chip in chips:
  if is_instance_valid(chip.node):chip.node.queue_free()

func shader245() -> Shader:return preload("res://scripts/art/relay_flag245.gdshader")
func ready_timeout245() -> float:return 5.
