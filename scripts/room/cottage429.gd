extends "res://scripts/room/cottage428.gd"

const ART := "res://assets/house429/"
var painted_wall: Texture2D
var window_box: Texture2D
var trailing_ivy: Texture2D
var left_pot: Texture2D
var right_pot: Texture2D
var potted_colliders: Array[StaticBody3D]=[]
var painted_troughs: Array[MeshInstance3D]=[]

func _ready() -> void:
 painted_wall=load_art("plaster.png")
 window_box=load_art("window-box.png",Rect2i(94,35,1950,662))
 trailing_ivy=load_art("ivy.png",Rect2i(83,2,618,2037))
 var sheet:=Image.load_from_file(ART+"planters.png")
 left_pot=make_texture(sheet.get_region(Rect2i(226,12,532,698)))
 right_pot=make_texture(sheet.get_region(Rect2i(1357,12,602,699)))
 super._ready()
 front_cut=front_cut.filter(func(entry):return entry.node not in painted_troughs)

func load_art(file: String,region:=Rect2i()) -> Texture2D:
 var source:=Image.load_from_file(ART+file)
 if region.has_area():source=source.get_region(region)
 return make_texture(source)

func make_texture(source: Image) -> Texture2D:
 source.generate_mipmaps()
 return ImageTexture.create_from_image(source)

func apply_facade427() -> void:
 for node in shell.find_children("*","MeshInstance3D",true,false):
  if node.material_override!=plaster:continue
  var in_roof:=false
  for entry in roof_cut:
   if entry.node==node:
    in_roof=true
    break
  if in_roof:continue
  var ink:=ShaderMaterial.new()
  ink.shader=preload("res://scripts/room/plaster429.gdshader")
  ink.set_shader_parameter("paint",painted_wall)
  node.material_override=ink
  for entry in front_cut:
   if entry.node!=node:continue
   entry.original=ink
   entry.ink=ink
   facade_layers.append({"node":node,"ink":ink})
   break

func flower_card(parent: Node3D,_source: Texture2D,at: Vector3,_height: float,_ground: bool) -> void:
 if parent.has_meta("illustrated_box429"):return
 parent.set_meta("illustrated_box429",true)
 var visible_width:=0.9
 for part in parent.get_children():
  if not part is MeshInstance3D or not part.mesh is BoxMesh:continue
  if is_equal_approx(part.position.y,-.19) and is_equal_approx(part.position.z,.26):
   visible_width=part.mesh.size.x+.13
   part.hide()
   painted_troughs.append(part)
   # Rendering gets its own card while this solid wooden trough remains.
   if part.get_children().is_empty():part.create_trimesh_collision()
 var height:=visible_width*window_box.get_height()/window_box.get_width()
 card(parent,window_box,Vector3(0,-.333,maxf(.48,at.z+.05)),height)

func build_planting() -> void:
 for side in [-1.,1.]:
  build_entry_planter(side)
  var patch:=Vector3(side*5.82,-.18,2.56)
  bouquet(terrace,patch,.38,2)
  contact_shadow(patch,.69)
 var drape:=Node3D.new()
 drape.name="PaintedIvy429"
 drape.position=Vector3(.99,2.48,FRONT+.42)
 shell.add_child(drape)
 var ivy:=card(drape,trailing_ivy,Vector3.ZERO,1.23)
 ivy.rotation_degrees.x=0.
 ivy.flip_h=true

func build_entry_planter(side: float) -> void:
 var at:=Vector3(side*1.85,-.21,FRONT+.72)
 card(terrace,left_pot if side<0 else right_pot,at,1.04)
 var footprint:=CylinderShape3D.new()
 footprint.height=.52
 footprint.radius=.27
 var body:=StaticBody3D.new()
 body.position=at+Vector3.UP*.26
 terrace.add_child(body)
 var collision:=CollisionShape3D.new()
 collision.shape=footprint
 body.add_child(collision)
 potted_colliders.append(body)
 contact_shadow(at,.66)

func card(parent: Node3D,tex: Texture2D,at: Vector3,height: float,exterior:=true) -> Sprite3D:
 var sprite:=Sprite3D.new()
 sprite.texture=tex
 sprite.position=at
 sprite.offset=Vector2(0,tex.get_height()*.5)
 sprite.pixel_size=height/tex.get_height()
 sprite.rotation_degrees.x=-25. if exterior else -12.
 sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD
 sprite.alpha_scissor_threshold=.4
 sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 sprite.shaded=true
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 parent.add_child(sprite)
 if exterior:plant_cards.append(sprite)
 return sprite

func contact_shadow(at: Vector3,width: float) -> void:
 var mesh:=PlaneMesh.new()
 mesh.size=Vector2(width,.36)
 var ink:=ShaderMaterial.new()
 ink.shader=preload("res://scripts/art/foot_contact16.gdshader")
 mesh_at(terrace,mesh,Vector3(at.x,-.207,at.z),ink).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
