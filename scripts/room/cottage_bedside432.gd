extends Node3D

const LINEN = preload("res://assets/house432_interior/flower-lamp-linen.png")
const PETALS := 5
const SIDES := 60
const PROFILE := [
 Vector2(.228,.307), Vector2(.254,.358), Vector2(.257,.411),
 Vector2(.231,.487), Vector2(.166,.557), Vector2(.085,.609),
 Vector2(.060,.617),
]

func build(room: Node3D,stand: Node3D) -> void:
 name="PaintedBedside432"
 # Keep the original furniture root and its lamp binding used by the bed.
 room.strip_meshes356(stand)
 var desk: Node3D=room.desk_model395
 var wood:=desk.wood395.duplicate() as ShaderMaterial
 wood.set_shader_parameter("wood_tone",Vector3(1.20,1.17,1.12))
 var boards:=SurfaceTool.new()
 boards.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:
  append_board(boards,desk,Vector3(.082,.69,.53),Vector3(side*.238,.347,0),.016,Vector2i(0,1))
 append_board(boards,desk,Vector3(.46,.49,.050),Vector3(0,.38,-.23),.014,Vector2i(0,1))
 append_board(boards,desk,Vector3(.474,.066,.527),Vector3(0,.145,-.003),.014)
 append_board(boards,desk,Vector3(.49,.201,.062),Vector3(0,.548,.244),.020)
 append_board(boards,desk,Vector3(.611,.083,.611),Vector3(0,.698,0),.024)
 room.shape(self,boards.commit(),Vector3.ZERO,wood).name="SingleDrawerAndOpenShelf"
 var grip: MeshInstance3D=room.ellipsoid(self,Vector3(0,.552,.296),Vector3(.087,.073,.067),"ac764a")
 grip.name="RoundWoodPull"
 var book:=Node3D.new()
 book.name="BedtimeBook"
 book.position=Vector3(.158,.744,.151)
 book.rotation.y=-.14
 add_child(book)
 for height in [.010,.049]:
  append_book_cover(room,desk,book,height)
 room.shape(book,desk.rounded_box395(Vector3(.194,.031,.234),.004),Vector3.UP*.028,desk.paper395)

func append_board(surface: SurfaceTool,desk: Node3D,size: Vector3,at: Vector3,bevel: float,tile:=Vector2i.ZERO) -> void:
 var mesh: ArrayMesh=desk.rounded_box395(size,bevel,tile)
 surface.append_from(mesh,0,Transform3D(Basis.IDENTITY,at))

func append_book_cover(room: Node3D,desk: Node3D,book: Node3D,height: float) -> void:
 var cover: ArrayMesh=desk.rounded_box395(Vector3(.214,.012,.256),.004,Vector2i(0,1))
 room.shape(book,cover,Vector3.UP*height,desk.detail395)

func build_lamp(room: Node3D,desk: Node3D,mount: Node3D) -> void:
 var base:=Vector3.ZERO
 var base_profile: Array[Vector2]=[
  Vector2(.143,.002),Vector2(.157,.014),Vector2(.157,.038),
  Vector2(.138,.061),Vector2(.083,.078),Vector2(.045,.085),
 ]
 var pedestal: ArrayMesh=desk.lathe395(base_profile,Vector2i.ZERO)
 room.shape(mount,pedestal,base,desk.wood395).name="TurnedWoodLampBase"
 room.cylinder(mount,base+Vector3.UP*.188,.022,.223,"886b43",.016)
 room.ellipsoid(mount,base+Vector3.UP*.097,Vector3(.082,.057,.082),"9c7b4d")
 room.cylinder(mount,base+Vector3.UP*.293,.047,.051,"9c7b4d")
 room.cylinder(mount,base+Vector3.UP*.616,.038,.024,"9c7b4d")
 var bulb: MeshInstance3D=room.ellipsoid(mount,base+Vector3.UP*.342,Vector3(.082,.096,.082),"f2cf95")
 bulb.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

 var fabric:=StandardMaterial3D.new()
 fabric.albedo_texture=LINEN
 fabric.albedo_color=Color("e6cfb1")
 fabric.roughness=1.
 fabric.cull_mode=BaseMaterial3D.CULL_DISABLED
 fabric.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 var shade: MeshInstance3D=room.shape(mount,flower_surface(0,PROFILE.size()-1),base,fabric)
 shade.name="FlowerBudShade432"
 # The lamp's globe sits in the opening. The thin cloth lights softly on both sides.
 shade.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var piping: MeshInstance3D=room.shape(mount,flower_surface(0,1,true),base,room.material("c59667"))
 piping.material_override=piping.material_override.duplicate()
 piping.material_override.cull_mode=BaseMaterial3D.CULL_DISABLED
 piping.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var pull_at:=base+Vector3(.168,.19,.132)
 room.cylinder(mount,pull_at+Vector3.UP*.089,.007,.177,"826345")
 room.ellipsoid(mount,pull_at,Vector3(.050,.062,.050),"a97744")

func flower_surface(first_ring: int,last_ring: int,hem:=false) -> ArrayMesh:
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 surface.set_smooth_group(0)
 for row in range(first_ring,last_ring):
  for col in SIDES:
   for point in [Vector2i(col,row),Vector2i(col+1,row),Vector2i(col+1,row+1),Vector2i(col,row),Vector2i(col+1,row+1),Vector2i(col,row+1)]:
    var u:=float(point.x)/SIDES
    var angle:=TAU*fposmod(u+.35,1.)
    var petal:=.5+.5*cos(angle*PETALS)
    var influence:=1.-float(point.y)/float(PROFILE.size()-1)
    var ring: Vector2=PROFILE[point.y]
    if hem:
     ring=PROFILE[0].lerp(PROFILE[1],float(point.y)*.21)
    var radius:=ring.x*(1.+.16*(petal-.5)*influence)
    var level:=ring.y-.062*petal*influence*influence
    if hem:
     radius+=.0025
     level-=float(point.y)*.0015
    surface.set_uv(Vector2(u,1.-level/.64))
    surface.add_vertex(Vector3(cos(angle)*radius,level,sin(angle)*radius))
 surface.generate_normals()
 return surface.commit()
