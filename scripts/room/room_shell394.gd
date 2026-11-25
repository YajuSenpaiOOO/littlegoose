extends "res://scripts/room/room_shell393.gd"
var furniture394: Array[Dictionary]=[]
var use_furniture394:=true
var lamp_light394: OmniLight3D
var old_light394: Vector3
var new_light394: Vector3
func build_furniture() -> void:
 super.build_furniture()
 install394("desk","desk.png",Rect2(157,5,1220,1008),2.60,Vector2(767,1012),.60,1.15,Vector2(.23,.46),Vector4(.13,.175,.825,.87),.80)
 install394("tea","tea.png",Rect2(335,9,851,966),1.62,Vector2(760,974),.55,1.10,Vector2(.22,.57),Vector4(.225,.285,.715,.775),.83)
 install394("desk_chair","chairs.png",Rect2(257,88,306,569),.67,Vector2(410,656),.26,.48,Vector2(.12,.65))
 install394("tea_chair","chairs.png",Rect2(887,53,395,620),.78,Vector2(1084,672),.26,.45,Vector2(.12,.68))
 install394("goose_stool","chairs.png",Rect2(1614,365,264,300),.48,Vector2(1746,664),.20,.30,Vector2(.12,.54))
 var desk: Node3D=item356("desk").root
 for c in desk.get_children():
  if c is OmniLight3D:lamp_light394=c;old_light394=c.position
 var row: Dictionary=furniture394[0]
 # Point on the painted shade; same projection and anchor as desk, not a guessed 2D offset.
 var shade: Vector3=row.sprite.global_position+row.sprite.global_basis.x*((1124.-767.)*row.density)+row.sprite.global_basis.y*((1012.-155.)*row.density)
 new_light394=desk.to_local(shade)
 var shade_proxy:=cylinder(desk,new_light394,.23,.28,"d9c28f",.13)
 row.shadows.append(shade_proxy)
 row.shadows.append(cylinder(desk,new_light394-Vector3(0,.29,0),.025,.36,"b78a42"))
 # Four-leg shadow geometry replaces the old tea table's single pedestal.
 var tea: Node3D=item356("tea").root
 var tea_row: Dictionary=furniture394[1]
 for x in [-.49,.49]:
  for z in [-.39,.39]:
   var leg:=cylinder(tea,Vector3(x,.43,z),.055,.86,"795337")
   tea_row.shadows.append(leg)
 var chair: Node3D=item356("tea_chair").root
 var chair_row: Dictionary=furniture394[3]
 for x in [-.23,.23]:
  for z in [-.21,.21]:chair_row.shadows.append(cylinder(chair,Vector3(x,.27,z),.04,.54,"795337"))
 chair_row.shadows.append(box(chair,Vector3(-.21,.95,-.05),Vector3(.10,.65,.49),"795337"))
 var stool: Node3D=item356("goose_stool").root
 for angle in [0.,TAU/3.,TAU*2./3.]:furniture394[4].shadows.append(cylinder(stool,Vector3(cos(angle)*.17,.15,sin(angle)*.17),.035,.30,"795337"))
 set_furniture394(true)
func install394(id: String,file: String,bounds: Rect2,width: float,anchor: Vector2,front: float,depth: float,top: Vector2,rear: Vector4=Vector4(-1,-1,-1,-1),rear_depth: float=.0) -> void:
 var root: Node3D=item356(id).root
 var originals: Array[MeshInstance3D]=[]
 var shadows: Array[MeshInstance3D]=[]
 for c in root.get_children():
  if not c is MeshInstance3D:continue
  originals.append(c)
  # Retain the actual tabletop and legs as independent shadow volumes, not image bounds.
  if id=="desk" and c.position.y<1.2 and c.position.z<.5:shadows.append(c)
  elif id=="desk_chair":shadows.append(c)
  elif id in ["tea_chair","goose_stool"] and c.position.y>.30:shadows.append(c)
  elif id=="tea" and c.mesh is CylinderMesh and c.position.y>.9 and c.position.y<1.:shadows.append(c)
 var tex: Texture2D=load("res://assets/room394/"+file)
 var atlas:=AtlasTexture.new();atlas.atlas=tex;atlas.region=bounds;atlas.filter_clip=true
 var sprite:=Sprite3D.new();sprite.texture=atlas;sprite.name="Painted394_"+id
 var density: float=width/bounds.size.x
 sprite.pixel_size=density;sprite.offset=Vector2(bounds.size.x*.5-(anchor.x-bounds.position.x),(anchor.y-bounds.position.y)-bounds.size.y*.5)
 sprite.shaded=true;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(sprite)
 sprite.global_basis=world.camera.global_basis
 sprite.global_position=root.global_position+Vector3(0,.012,front)
 var mat:=ShaderMaterial.new();mat.shader=preload("res://scripts/room/furniture394.gdshader")
 mat.set_shader_parameter("paint",tex)
 mat.set_shader_parameter("region394",Vector4(bounds.position.x/tex.get_width(),bounds.position.y/tex.get_height(),bounds.size.x/tex.get_width(),bounds.size.y/tex.get_height()))
 mat.set_shader_parameter("foot394",sprite.global_position);mat.set_shader_parameter("depth394",depth)
 mat.set_shader_parameter("top_range394",top);mat.set_shader_parameter("rear_legs394",rear);mat.set_shader_parameter("rear_depth394",rear_depth)
 sprite.material_override=mat
 furniture394.append({"id":id,"sprite":sprite,"originals":originals,"shadows":shadows,"density":density,"bounds":bounds,"anchor":anchor})
func set_furniture394(value: bool) -> void:
 use_furniture394=value
 for row in furniture394:
  row.sprite.visible=value
  for c in row.originals:c.visible=not value;c.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
  for c in row.shadows:
   c.visible=true if value or c in row.originals else false
   c.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if value else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 if is_instance_valid(lamp_light394):lamp_light394.position=new_light394 if value else old_light394+(Vector3.ZERO if use_window393 else Vector3(-1.82,0,0))
func set_window393(value: bool) -> void:
 super.set_window393(value)
 # Old window comparison must not move hidden old lamp meshes independently of the painted desk.
 if is_instance_valid(lamp_light394) and use_furniture394:lamp_light394.position=new_light394
