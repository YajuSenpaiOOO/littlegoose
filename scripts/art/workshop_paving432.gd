extends RefCounted

const YARD = preload("res://scripts/world/yard_layout432.gd")
const STONE := [Color("9d9786"),Color("a49d89"),Color("b2a38d"),Color("898879"),Color("a69a82")]
var shed: Node3D
var world: Node3D
var mesh: SurfaceTool
var tint: Color
var rng:=RandomNumberGenerator.new()

func build(parent: Node3D,home: Node3D) -> void:
 shed=parent
 world=home.world
 mesh=SurfaceTool.new()
 mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 rng.seed=43220
 var sizes: Array[Vector2]=[Vector2(.62,.37),Vector2(.55,.39),Vector2(.64,.38),Vector2(.45,.36),Vector2(.29,.22)]
 for i in YARD.WORKSHOP_STEPS.size():
  var at: Vector2=YARD.WORKSHOP_STEPS[i]
  var outline:=PackedVector2Array()
  for corner in 8:
   var angle: float=(corner+rng.randf_range(-.23,.23))*TAU/8.
   outline.append(at+Vector2.from_angle(angle)*sizes[i]*rng.randf_range(.45,.57))
  stone(at,outline)
 var material: StandardMaterial3D=home.house.stone.duplicate()
 material.vertex_color_use_as_albedo=true
 material.albedo_color=Color(.92,.89,.83)
 material.metallic_specular=0.
 material.roughness=.95
 mesh.generate_normals()
 var paving: MeshInstance3D=home.room.shape(shed,mesh.commit(),Vector3.ZERO,material)
 paving.name="ApproachSteppingStones"
 paving.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 build_foundation(YARD.WORKSHOP_PAVING)

func build_foundation(pad: Rect2) -> void:
 # The painted fieldstones and walkable surface follow the same terrain samples.
 var triangles:=PackedVector3Array()
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 surface.set_normal(Vector3.UP)
 for row in 12:
  for column in 16:
   for corner: Vector2 in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
    var uv: Vector2=(Vector2(column,row)+corner)/Vector2(16,12)
    var at:=pad.position+pad.size*uv
    var level: float=world.floor_height(at+YARD.WORKSHOP_SITE)-shed.global_position.y
    var point:=Vector3(at.x,level,at.y)
    triangles.append(point)
    surface.set_uv(uv)
    surface.add_vertex(point+Vector3.UP*.022)
 var body:=StaticBody3D.new()
 body.name="StoneFoundation"
 body.collision_mask=0
 var floor_shape:=ConcavePolygonShape3D.new()
 floor_shape.set_faces(triangles)
 var collision:=CollisionShape3D.new()
 collision.shape=floor_shape
 body.add_child(collision)
 shed.add_child(body)
 var paint:=StandardMaterial3D.new()
 paint.albedo_texture=preload("res://assets/workshop432/pergola-fieldstone.png")
 paint.albedo_color=Color(.80,.81,.83)
 paint.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
 paint.texture_repeat=false
 paint.metallic_specular=0.
 paint.roughness=.94
 var paving:MeshInstance3D=world.home432.room.shape(shed,surface.commit(),Vector3.ZERO,paint)
 paving.name="FieldstonePaving"
 paving.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func stone(at: Vector2,outline: PackedVector2Array) -> void:
 tint=STONE[rng.randi_range(0,STONE.size()-1)]
 var height:=rng.randf_range(.006,.021)
 var upper: Array[Vector3]=[]
 var lower: Array[Vector3]=[]
 for corner in outline:
  var cap:=corner.move_toward(at,rng.randf_range(.017,.031))
  var corner_y: float=world.open_ground432(corner+YARD.WORKSHOP_SITE)
  upper.append(surface_point(cap,height))
  lower.append(Vector3(corner.x,corner_y-.026-shed.global_position.y,corner.y))
 var center:=surface_point(at,height+.007)
 for i in outline.size():
  var j: int=(i+1)%outline.size()
  face(center,upper[i],upper[j],1.)
  face(upper[i],lower[i],lower[j],.77)
  face(upper[i],lower[j],upper[j],.85)

func surface_point(at: Vector2,height: float) -> Vector3:
 var map:=at+YARD.WORKSHOP_SITE
 var level: float=world.open_ground432(map)+.022
 return Vector3(at.x,level+height-shed.global_position.y,at.y)

func face(a: Vector3,b: Vector3,c: Vector3,shade: float) -> void:
 mesh.set_smooth_group(-1)
 for point in [a,b,c]:
  mesh.set_color(Color(tint.r*shade,tint.g*shade,tint.b*shade))
  mesh.set_uv(Vector2(point.x+point.y*.23,point.z-point.y*.46)*.86)
  mesh.add_vertex(point)
