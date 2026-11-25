extends "res://scripts/room/room_shell355.gd"
var cards356: Array[Dictionary]=[]
var art356:=true
func item356(id: String) -> Dictionary:
 for row in footprints:
  if row.id==id:return row
 return {}
func strip_meshes356(root: Node3D) -> void:
 for child in root.get_children():
  if child is MeshInstance3D:root.remove_child(child);child.queue_free()
func build_furniture() -> void:
 super.build_furniture()
 # Shared double bed replaces the separate home bed; remove its volume and interaction too.
 var nest:=item356("nest")
 remove_child(nest.root);nest.root.queue_free()
 footprints.erase(nest)
 # Remove only the two known bird-size dishes from this new trial, not unrelated props.
 for child in get_children():
  if child is MeshInstance3D and (child.position.distance_to(Vector3(-3.8,.08,1.8))<.01 or child.position.distance_to(Vector3(-4.3,.045,1.9))<.01):
   remove_child(child);child.queue_free()
 install356("bed","main_bed.png",Rect2(82,74,1106,1032),2.65,3.,1.25,538.)
 install356("wardrobe","wardrobe_closed.png",Rect2(122,94,793,1353),1.5,0.,2.55,533.)
func source356(path: String) -> Texture2D:
 var image:=Image.new()
 if image.load(ProjectSettings.globalize_path(path))==OK:
  image.generate_mipmaps();return ImageTexture.create_from_image(image)
 return load(path)
func install356(id: String,file: String,bounds: Rect2,width: float,depth: float,shadow_height: float,foot_x: float) -> void:
 var row:=item356(id);var root: Node3D=row.root
 var proxies: Array[Node3D]=[]
 for child in root.get_children():
  if child is MeshInstance3D:child.hide();proxies.append(child)
 var texture:=source356("res://assets/room356/"+file)
 var atlas:=AtlasTexture.new();atlas.atlas=texture;atlas.region=bounds;atlas.filter_clip=true
 var sprite:=Sprite3D.new();sprite.name="PaintedFurniture";sprite.texture=atlas
 sprite.pixel_size=width/bounds.size.x;sprite.offset=Vector2(bounds.size.x*.5-(foot_x-bounds.position.x),bounds.size.y*.5)
 sprite.shaded=true;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;root.add_child(sprite)
 sprite.global_basis=world.camera.global_basis
 sprite.global_position=root.global_position+Vector3(0.,.012,float(row.size.y)*.5)
 var ink:=ShaderMaterial.new();ink.shader=preload("res://scripts/room/card356.gdshader")
 ink.set_shader_parameter("paint",texture)
 ink.set_shader_parameter("region356",Vector4(bounds.position.x/texture.get_width(),bounds.position.y/texture.get_height(),bounds.size.x/texture.get_width(),bounds.size.y/texture.get_height()))
 ink.set_shader_parameter("foot356",sprite.global_position);ink.set_shader_parameter("camera356",world.camera.global_position);ink.set_shader_parameter("depth356",depth)
 sprite.material_override=ink
 # A separate volume casts shadows, independent of the painted image rectangle.
 var shadow: MeshInstance3D
 if id=="nest":
  shadow=cylinder(root,Vector3(0.,.26,0.),1.02,.52,"795c43")
 else:
  shadow=box(root,Vector3(0.,shadow_height*.5,0.),Vector3(float(row.size.x)*.95,shadow_height,float(row.size.y)*.95),"856449")
 shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
 cards356.append({"id":id,"sprite":sprite,"material":ink,"proxies":proxies,"shadow":shadow,"size":row.size,"depth":depth,"width":width})
func set_art356(value: bool) -> void:
 art356=value
 for row in cards356:
  row.sprite.visible=value
  row.shadow.visible=value
  for proxy in row.proxies:proxy.visible=not value
