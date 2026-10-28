extends "res://scripts/combat/hero_moment161.gd"
const RADIUS164 := 6.5
const RATE164 := 2.
var anchor164 := Vector3.ZERO
var props164: Array[Dictionary]=[]
var root164: Node3D
var ground164: MeshInstance3D
var ground_material164: ShaderMaterial
var unfolded164 := 0.
func _ready() -> void:
 super._ready();name="FixedRecessFantasyField164"
 shader161.shader=preload("res://scripts/combat/field_film164.gdshader")
 root164=Node3D.new();root164.name="GroundedPinwheels164";battle.combat_effect_root159().add_child(root164);root164.hide()
 ground164=MeshInstance3D.new();ground164.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;ground164.set_meta("environment_grade159",false)
 ground_material164=ShaderMaterial.new();ground_material164.shader=ground_shader164();ground164.material_override=ground_material164;root164.add_child(ground164)
 var head := head_texture164();var stick := Image.create(12,96,false,Image.FORMAT_RGBA8);stick.fill(Color.TRANSPARENT)
 stick.fill_rect(Rect2i(4,0,4,96),Color("624653"));stick.fill_rect(Rect2i(5,0,2,95),Color("ddbd82"))
 var stem := ImageTexture.create_from_image(stick)
 for i in 5:
  var pole := Sprite3D.new();pole.texture=stem;pole.pixel_size=.94/96.;pole.offset.y=48.;setup_sprite164(pole)
  var rotor := Sprite3D.new();rotor.texture=head;rotor.pixel_size=(.75+float(i%3)*.08)/96.;setup_sprite164(rotor)
  root164.add_child(pole);root164.add_child(rotor)
  battle._add_actor_shadow(pole,pole);battle._add_actor_shadow(rotor,rotor)
  props164.append({"pole":pole,"rotor":rotor,"base":Vector3.ZERO,"basis":Basis.IDENTITY,"turn":float(i)*1.3})
func ground_shader164() -> Shader: return preload("res://scripts/combat/field_ground164.gdshader")
func setup_sprite164(sprite: Sprite3D) -> void:
 sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;sprite.shaded=false
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;sprite.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
func paint164(image: Image,polygon: PackedVector2Array,color: Color) -> void:
 for y in 96:
  for x in 96:
   if Geometry2D.is_point_in_polygon(Vector2(x+.5,y+.5),polygon): image.set_pixel(x,y,color)
 for i in polygon.size():
  var a := polygon[i];var b := polygon[(i+1)%polygon.size()];var count := int(a.distance_to(b)*2.)+1
  for step in count+1:
   var point := a.lerp(b,float(step)/float(count)).round()
   if point.x>=0 and point.x<96 and point.y>=0 and point.y<96: image.set_pixel(int(point.x),int(point.y),Color("614455"))
func head_texture164() -> Texture2D:
 var image := Image.create(96,96,false,Image.FORMAT_RGBA8);image.fill(Color.TRANSPARENT)
 var palette := [Color("f4afb2"),Color("fff0b3"),Color("afced9"),Color("d2bdde")]
 for i in 4:
  var a := TAU*float(i)/4.;var x := Vector2(cos(a),sin(a));var y := Vector2(-x.y,x.x);var c := Vector2(48,48)
  var end := c+x*32.;var wing := c+x*29.+y*26.;var fold := c+x*10.+y*8.
  var color: Color=palette[i]
  paint164(image,PackedVector2Array([c,end,wing,fold]),color)
  paint164(image,PackedVector2Array([c,fold,wing]),Color(color.r*.78,color.g*.75,color.b*.82))
 image.fill_rect(Rect2i(45,45,7,7),Color("614455"));image.fill_rect(Rect2i(47,47,3,3),Color("ffe3a2"));image.generate_mipmaps()
 return ImageTexture.create_from_image(image)
func inside164() -> bool:
 var p: Vector3=battle.hero.global_position
 return Vector2(p.x-anchor164.x,p.z-anchor164.z).length_squared()<=RADIUS164*RADIUS164 and absf(p.y-anchor164.y)<1.2
func running161() -> bool: return super.running161() and inside164()
func request161() -> bool:
 if not super.request161(): return false
 anchor164=battle.hero.global_position;anchor164.y=battle.floor_height(Vector2(anchor164.x,anchor164.z))+.025
 build_ground164()
 for i in props164.size():
  var a := TAU*float(i)/5.+.3;var p := anchor164+Vector3(cos(a),0.,sin(a))*RADIUS164*.88
  p.y=battle.floor_height(Vector2(p.x,p.z))+.035
  var prop: Dictionary=props164[i];prop.base=p;prop.basis=battle.camera.global_basis;prop.turn=float(i)*1.3
  prop.pole.global_position=p;prop.pole.basis=prop.basis;prop.rotor.global_position=p+prop.basis.y*.91;prop.rotor.basis=prop.basis
  prop.pole.visible=absf(p.y-anchor164.y)<1.;prop.rotor.visible=prop.pole.visible
 root164.show();unfolded164=0.;battle.buffs.moment_rate161=RATE164
 battle.cooldown=minf(battle.cooldown,battle.attack_cooldown());return true
func build_ground164() -> void:
 var vertices := PackedVector3Array();var uvs := PackedVector2Array();var colors := PackedColorArray();var indices := PackedInt32Array()
 for ring in 9:
  for segment in 65:
   var a := TAU*float(segment)/64.;var uv := Vector2(cos(a),sin(a))*float(ring)/8.
   var p := anchor164+Vector3(uv.x,0.,uv.y)*RADIUS164;p.y=battle.floor_height(Vector2(p.x,p.z))+.055
   vertices.append(p);uvs.append(uv);colors.append(Color(1.,1.,1.,1. if absf(p.y-anchor164.y)<1. else 0.))
 for ring in 8:
  for segment in 64:
   var a := ring*65+segment;var b := a+65
   for index in [a,b,a+1,a+1,b,b+1]: indices.append(index)
 var arrays := [];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uvs;arrays[Mesh.ARRAY_COLOR]=colors;arrays[Mesh.ARRAY_INDEX]=indices
 var mesh := ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays);ground164.mesh=mesh
func reset161() -> void:
 super.reset161();unfolded164=0.
 if is_instance_valid(root164): root164.hide()
func step161(delta: float) -> void:
 super.step161(delta)
 battle.buffs.moment_rate161=RATE164 if running161() else 1.
func entrance_strength161() -> float: return 0.
func cone_strength161() -> float: return 0.
func update_float162(delta: float) -> void:
 foot162=battle.hero.get_global_transform_interpolated().origin
 if not battle.combat_paused and (left161>0. or tail161<.65): float_age162+=delta
 body162=anchor164+Vector3.UP*.65
 for i in stars162.size():
  var a := TAU*float(i)/14.+float_age162*.025
  var r := 1.3+float(i%4)*.7
  var p := anchor164+Vector3(cos(a)*r,.5+sin(float_age162*1.2+float(i))*.12,sin(a)*r)
  stars162[i].advance(p,0. if battle.combat_paused else delta,7.+float(i%4))
func _process(delta: float) -> void:
 super._process(delta)
 var active: bool=(left161>0. or tail161<.65) and battle.active114
 root164.visible=active
 if left161<=0. and cooldown161<=0.: label161.text="Q 主角时刻 · 固定半径6.5米\n圈内双倍射速 · 7秒／冷却20秒"
 if not active: return
 var camera: Camera3D=battle.camera
 var centre := camera.unproject_position(body162)
 shader161.set_shader_parameter("axis_right",camera.unproject_position(body162+Vector3.RIGHT*RADIUS164)-centre)
 shader161.set_shader_parameter("axis_forward",camera.unproject_position(body162+Vector3.FORWARD*RADIUS164)-centre)
 unfolded164=smoothstep(0.,.72,float_age162)
 shader161.set_shader_parameter("unfold",unfolded164)
 ground_material164.set_shader_parameter("unfold",unfolded164);ground_material164.set_shader_parameter("strength",strength161())
 if left161>0.: label161.text="主角时刻 · %s · %.1f秒\n圈内伤害＋30%% · 射速＋100%%"%["圈内增益生效" if inside164() else "圈外无增益，可返回",left161]
 elif cooldown161<=0.: label161.text="Q 主角时刻 · 固定半径6.5米\n圈内双倍射速 · 7秒／冷却20秒"
 for prop in props164:
  var rise := smoothstep(0.,.32,float_age162)
  prop.pole.scale=Vector3(1.,maxf(.02,rise),1.);prop.rotor.scale=Vector3.ONE*rise
  prop.rotor.global_position=prop.base+prop.basis.y*.91*rise;prop.rotor.basis=prop.basis
  if not battle.combat_paused: prop.turn+=delta*.8
  prop.rotor.rotate_object_local(Vector3.BACK,prop.turn)
  prop.pole.modulate.a=strength161();prop.rotor.modulate.a=strength161()
func draw161() -> void:
 if strength161()<=0. or not battle.active114: return
 for i in stars162.size():
  var p: Vector3=stars162[i].position
  if battle.camera.is_position_behind(p): continue
  var at: Vector2=battle.camera.unproject_position(p)
  if left161<=0.: at.y+=tail161*tail161*60.
  star161(at,5.+float(i%3),Color(1.,.85,.62,strength161()*.5),sin(float_age162+float(i))*.12)
