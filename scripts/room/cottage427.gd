extends "res://scripts/room/cottage426.gd"

const MASONRY := preload("res://assets/wall77/painted_moss_stone77.png")
const DAISIES := preload("res://assets/atmosphere41/daisy_sprig.png")
const FLOWERS := preload("res://assets/decor42/flowers.png")
var front_glass: Array[MeshInstance3D]=[]
var facade_layers: Array[Dictionary]=[]
var plant_cards: Array[Sprite3D]=[]

func _ready() -> void:
 super._ready()
 apply_facade427()

func apply_facade427() -> void:
 for node in shell.find_children("*","MeshInstance3D",true,false):
  if node.material_override!=plaster and not node.has_meta("base_course427"):continue
  # Leave the new roof liner and its interior-specific plaster alone.
  var material:=wall_ink(node.has_meta("base_course427"))
  node.material_override=material
  var cut:=false
  for entry in front_cut:
   if entry.node!=node:continue
   entry.original=material
   entry.ink=material
   cut=true
   break
  if cut:facade_layers.append({"node":node,"ink":material})

func wall_ink(is_stone: bool) -> ShaderMaterial:
 var ink:=ShaderMaterial.new()
 ink.shader=preload("res://scripts/room/facade427.gdshader")
 ink.set_shader_parameter("paint",plaster.albedo_texture)
 ink.set_shader_parameter("stone_paint",MASONRY)
 ink.set_shader_parameter("stone_course",is_stone)
 return ink

func base_course(x0: float,x1: float,z: float) -> void:
 var mesh:=block(shell,Vector3((x0+x1)*.5,.285,z+.10),Vector3(x1-x0,.57,.43),stone)
 mesh.set_meta("base_course427",true)

func polygon(parent: Node3D,points: PackedVector2Array,z: float,ink: Material) -> void:
 if parent==shell and is_equal_approx(z,FRONT) and points.size()==3 and points[0].x< -2.99:
  central_gable()
  return
 super.polygon(parent,points,z,ink)

func central_gable() -> void:
 var lower:=3.385
 var top:=4.655
 var r:=.71
 for side in [-1.,1.]:
  var at_x: float=side*r
  var roof_y: float=lerpf(6.85,3.31,r/3.)
  super.polygon(shell,PackedVector2Array([Vector2(side*3.,3.31),Vector2(at_x,roof_y),Vector2(at_x,lower),Vector2(0,lower),Vector2(0,3.31)]),FRONT,plaster)
 super.polygon(shell,PackedVector2Array([Vector2(-r,lerpf(6.85,3.31,r/3.)),Vector2(0,6.85),Vector2(r,lerpf(6.85,3.31,r/3.)),Vector2(r,top-.005),Vector2(-r,top-.005)]),FRONT,plaster)

func window(parent: Node3D,at: Vector3,width: float,height: float,leaf: float) -> void:
 if parent!=shell:
  super.window(parent,at,width,height,leaf)
  return
 var node:=Node3D.new()
 node.name="FrontGlazedOpening427"
 node.position=at-Vector3.UP*height*.5
 shell.add_child(node)
 var tall:=at.y>3.
 if not tall:
  width=.81
  height=1.11
 # The wall returns wrap around a real opening rather than covering the pane.
 var r:=width*.5
 var spring:=height-r
 var curve: Array[Vector2]=[]
 for i in 23:
  var a:=PI*i/22.
  curve.append(Vector2(-cos(a)*r,spring+sin(a)*r))
 for i in 22:
  var a:=curve[i]
  var b:=curve[i+1]
  var cap:=height if tall else 1.12
  for face in [-.12,.045]:
   super.polygon(node,PackedVector2Array([a,b,Vector2(b.x,cap),Vector2(a.x,cap)]),face,plaster)
 var frame:=preload("res://scripts/room/timber_frame399.gd").new()
 frame.position.z=.052
 node.add_child(frame)
 var head:=frame.beam399(curve,.106,.26,0.,"GlazedFrame427")
 head.material_override=wood
 for side in [-1.,1.]:
  block(node,Vector3(side*r,spring*.5,.058),Vector3(.11,spring+.024,.24),wood)
  var panel:=block(node,Vector3(side*(r+leaf*.50+.12),height*.46,.112),Vector3(leaf,height*.88,.105),shutter)
  panel.rotation.y=side*.12
  for y in [.22,.68]:
   block(node,Vector3(panel.position.x,height*y,.172),Vector3(leaf+.014,.063,.052),shutter)
 block(node,Vector3(0,height*.45,.052),Vector3(width,.059,.11),wood)
 block(node,Vector3(0,height*.49,.052),Vector3(.055,height*.97,.10),wood)
 block(node,Vector3(0,-.025,.070),Vector3(width+.24,.118,.36),wood)
 block(node,Vector3(0,-.19,.26),Vector3(width+.31,.23,.35),wood)
 var glass:=ShaderMaterial.new()
 glass.shader=preload("res://scripts/room/glass427.gdshader")
 super.polygon(node,arch_points(width,height),.018,glass)
 var pane: MeshInstance3D=node.get_child(node.get_child_count()-1)
 pane.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 front_glass.append(pane)
 for i in 4:
  flower_card(node,DAISIES,Vector3(lerpf(-width*.44,width*.44,i/3.),-.08,.40+i%2*.045),.32+.035*(i%2),false)

func build_planting() -> void:
 for side in [-1.,1.]:
  var pos:=Vector3(side*1.79,.0,FRONT+.66)
  var pot:=CylinderMesh.new()
  pot.height=.57
  pot.top_radius=.31
  pot.bottom_radius=.213
  pot.radial_segments=20
  var clay:=stone.duplicate() as StandardMaterial3D
  clay.albedo_color=Color("a77455")
  var ceramic:=mesh_at(terrace,pot,pos+Vector3.UP*.06,clay)
  ceramic.create_trimesh_collision()
  var rim:=TorusMesh.new()
  rim.inner_radius=.246
  rim.outer_radius=.319
  var lip:=mesh_at(terrace,rim,pos+Vector3.UP*.327,clay)
  lip.scale.y=.58
  for i in 4:
   flower_card(terrace,DAISIES,pos+Vector3((i-1.5)*.113,.31,.08*cos(i)),.47+i%2*.1,false)
  for i in 5:
   flower_card(terrace,FLOWERS,Vector3(side*(3.30+i*.59),-.12,2.51+.13*sin(i*1.1)),.38+.12*(i%3),true)

func flower_card(parent: Node3D,source: Texture2D,at: Vector3,height: float,ground: bool) -> void:
 var sprite:=Sprite3D.new()
 if source==FLOWERS:
  var crop:=AtlasTexture.new()
  crop.atlas=source
  crop.region=Rect2(7,22,745,471)
  crop.filter_clip=true
  sprite.texture=crop
 else:sprite.texture=source
 var size:=sprite.texture.get_size()
 sprite.pixel_size=height/size.y
 sprite.offset=Vector2(0,size.y*.5)
 sprite.position=at
 sprite.rotation_degrees.x=-25.
 sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD
 sprite.alpha_scissor_threshold=.42
 sprite.shaded=true
 sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 parent.add_child(sprite)
 plant_cards.append(sprite)
 if ground:
  var shadow:=PlaneMesh.new()
  shadow.size=Vector2(height*1.3,.27)
  var ink:=ShaderMaterial.new()
  ink.shader=preload("res://scripts/art/foot_contact16.gdshader")
  mesh_at(parent,shadow,Vector3(at.x,-.202,at.z),ink).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func set_cut(value: float) -> void:
 super.set_cut(value)
 var level:=1.-smoothstep(.25,.91,value)
 var height:=lerpf(.16,5.25,level)
 for layer in facade_layers:
  layer.ink.set_shader_parameter("cut_height",20. if level>.998 else height)
 for pane in front_glass:
  pane.visible=level>.002
  pane.material_override.set_shader_parameter("cut_height",20. if level>.998 else height)
 for sprite in plant_cards:
  if sprite.get_parent()!=terrace:sprite.visible=level>.002 and to_local(sprite.global_position).y<height
