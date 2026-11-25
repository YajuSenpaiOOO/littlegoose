extends MeshInstance3D

func build(room: Node3D) -> void:
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var models: Array[Node3D]=[room.desk_model395]
 models.append_array(room.solids396.values())
 models.append_array(room.cabinets398.values())
 for model in models:
  if not room.is_ancestor_of(model):continue
  var feet: Array= model.legs395 if model==room.desk_model395 else model.legs396
  if feet.is_empty():continue
  var bounds:=AABB()
  for foot in feet:
   var center: Vector3=room.to_local(foot.global_position)
   var diameter: float=maxf(foot.mesh.get_aabb().size.x,foot.mesh.get_aabb().size.z)
   var radius:=diameter*.5+.14
   stamp(surface,center,Vector2.ONE*radius,.52)
   var box:=AABB(center-Vector3(.08,0,.08),Vector3(.16,0,.16))
   bounds=box if bounds.size==Vector3.ZERO else bounds.merge(box)
  stamp(surface,bounds.get_center(),Vector2(bounds.size.x,bounds.size.z)*.64+Vector2.ONE*.12,.16)
 var bedside: Node3D=room.item356("bedside").root
 stamp(surface,room.to_local(bedside.global_position),Vector2(.42,.43),.32)
 # Reuse the painted bed's registered floor and two front feet.
 var bed_center: Vector3=room.to_local(room.contact362.global_position)
 stamp(surface,bed_center,Vector2(1.47,1.68),.30)
 for marker in room.foot_contacts363:
  stamp(surface,room.to_local(marker.global_position),Vector2(.25,.19),.49)
 mesh=surface.commit()
 var ink:=ShaderMaterial.new()
 ink.shader=preload("res://scripts/room/furniture_contact.gdshader")
 ink.render_priority=-90
 material_override=ink
 cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func stamp(surface: SurfaceTool,center: Vector3,radius: Vector2,strength: float) -> void:
 # The wood is y=.006 and the alpha-cut rug y=.013 in this room.
 # Place the decals over both so the cloth weave remains visible underneath.
 for uv in [Vector2.ZERO,Vector2.DOWN,Vector2.RIGHT,Vector2.RIGHT,Vector2.DOWN,Vector2.ONE]:
  var offset: Vector2=(uv*2.-Vector2.ONE)*radius
  surface.set_uv(uv)
  surface.set_color(Color(1.,1.,1.,strength))
  surface.add_vertex(Vector3(center.x+offset.x,.019,center.z+offset.y))
