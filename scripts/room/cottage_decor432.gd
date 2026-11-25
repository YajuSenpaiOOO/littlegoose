extends Node3D

const DRIED_FLOWERS = preload("res://assets/house432_wall/dried-flowers.png")
const GOOSE_PLAQUE = preload("res://assets/house432_wall/goose-plaque.png")
const RIGHT_IVY = preload("res://assets/house432_wall/right-wall-ivy.png")
const KUMQUAT = preload("res://assets/house432_entry/kumquat.png")
const CABINET_FRONT = preload("res://assets/house432_entry/shoe-cabinet-front.png")
const ENTRANCE_MAT = preload("res://assets/house432_interior/entrance-mat.png")
const BOOK_SPINES = preload("res://assets/house432_interior/book-spines.png")
const SCHOOL_AWARD = preload("res://assets/house432_interior/school-award.png")
const GOOSE_PLUSH = preload("res://assets/house432_interior/goose-plush.png")
const FOOT_CONTACT = preload("res://scripts/art/foot_contact16.gdshader")
const YARD = preload("res://scripts/world/yard_layout432.gd")
const BEDSIDE = preload("res://scripts/room/cottage_bedside432.gd")

var home: Node3D
var room: Node3D
var house: Node3D
var canopy: Node3D
var sand_glow: OmniLight3D
var egg_glow: OmniLight3D
var egg_shell: StandardMaterial3D
var pulse: Tween

func build(host: Node3D) -> void:
 home=host
 room=home.room
 house=home.house
 move_tea_outside()
 build_sand_lamp()
 build_wall_decor()
 build_entry_props()
 build_entrance_mat()
 build_bookshelf()
 # Keep the front half of the bedroom arch open for the foot-of-bed approach.
 room.place("bed",Vector2(-4.60,-.87),Vector2(-4.31,1.22))
 var bed: Dictionary=room.item356("bed")
 bed["thought"]="我和小黑鹅最喜欢的，\n柔软的床"
 bed["thought_anchor"]=Vector3(0,1.3,.72)
 room.place("bedside",Vector2(-2.72,-.65),Vector2(-2.35,-.10))
 var bedside:=BEDSIDE.new()
 var stand: Node3D=room.item356("bedside").root
 stand.add_child(bedside)
 bedside.build(room,stand)
 var lamp_mount:=Node3D.new()
 lamp_mount.name="FlowerLampMount432"
 lamp_mount.position=Vector3(-.086,.74,-.065)
 stand.add_child(lamp_mount)
 bedside.build_lamp(room,room.desk_model395,lamp_mount)
 var bedside_light: OmniLight3D=room.lamps362[0]
 bedside_light.reparent(lamp_mount,false)
 bedside_light.position=Vector3(0,.33,0)
 build_bed_display()
 build_school_award()
 build_egg_lamp()

func wall_shelf(label: String,at: Vector3,width: float,depth: float) -> Node3D:
 var shelf:=Node3D.new()
 shelf.name=label
 shelf.position=at
 room.add_child(shelf)
 var desk: Node3D=room.desk_model395
 room.shape(shelf,desk.rounded_box395(Vector3(width,.069,depth),.017),Vector3.DOWN*.035,desk.wood395)
 for side in [-1.,1.]:
  var support: ArrayMesh=desk.rounded_box395(Vector3(.065,.15,.105),.012,Vector2i(0,1))
  room.shape(shelf,support,Vector3(side*width*.34,-.11,-depth*.5+.048),desk.wood395)
 return shelf

func build_bed_display() -> void:
 room.get_node("BedWallShelf355").hide()
 for old in room.find_children("BedWallBook355_*","MeshInstance3D",false,false):old.hide()
 var shelf:=wall_shelf("BedKeepsakes432",Vector3(-4.96,2.18,-2.23),1.25,.36)
 var pages:=SurfaceTool.new()
 pages.begin(Mesh.PRIMITIVE_TRIANGLES)
 var spines:=SurfaceTool.new()
 spines.begin(Mesh.PRIMITIVE_TRIANGLES)
 fill_bookshelf_row(pages,spines,0.,-.145,[7,2,5])
 add_book_meshes(shelf,pages,spines)
 var crop:=AtlasTexture.new()
 crop.atlas=GOOSE_PLUSH
 crop.region=Rect2(319,163,636,865)
 crop.filter_clip=true
 var goose: Sprite3D=house.card(shelf,crop,Vector3(-.39,.004,.02),.29,false)
 goose.name="PaintedClothGoose432"
 var shade:=PlaneMesh.new()
 shade.size=Vector2(.25,.15)
 var ink:=ShaderMaterial.new()
 ink.shader=FOOT_CONTACT
 var contact: MeshInstance3D=room.shape(shelf,shade,Vector3(-.39,.003,.012),ink)
 contact.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func build_school_award() -> void:
 var frame:=Node3D.new()
 frame.name="SchoolAward432"
 # The left wall faces toward the bed on +X.
 frame.position=Vector3(-6.005,1.92,-1.57)
 frame.rotation.y=PI*.5
 room.add_child(frame)
 var desk: Node3D=room.desk_model395
 room.shape(frame,desk.rounded_box395(Vector3(.76,.57,.045),.013),Vector3.ZERO,desk.wood395)
 var paper:=StandardMaterial3D.new()
 paper.albedo_texture=SCHOOL_AWARD
 paper.albedo_color=Color("e4d6bd")
 paper.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 paper.roughness=1.
 var surface:=QuadMesh.new()
 surface.size=Vector2(.704,.528)
 var image: MeshInstance3D=room.shape(frame,surface,Vector3.BACK*.025,paper)
 image.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func build_egg_lamp() -> void:
 var stand:=Node3D.new()
 stand.name="GooseEggLamp432"
 stand.position=Vector3(3.53,.006,-1.55)
 room.add_child(stand)
 var desk: Node3D=room.desk_model395
 var top: ArrayMesh=desk.rounded_box395(Vector3(.48,.071,.46),.021)
 room.shape(stand,top,Vector3.UP*.74,desk.wood395)
 for x in [-.17,.17]:
  for z in [-.16,.16]:
   var leg: ArrayMesh=desk.rounded_box395(Vector3(.061,.73,.061),.012,Vector2i(0,1))
   room.shape(stand,leg,Vector3(x,.365,z),desk.wood395)
 room.collider(stand,Vector3.UP*.39,Vector3(.48,.78,.46))
 var cup_profile: Array[Vector2]=[
  Vector2(.158,0),Vector2(.177,.018),Vector2(.198,.066),Vector2(.197,.083),
  Vector2(.151,.088),Vector2(.132,.039),Vector2(.032,.028),
 ]
 var cup: ArrayMesh=desk.lathe395(cup_profile,Vector2i.ZERO,false)
 room.shape(stand,cup,Vector3.UP*.776,desk.wood395)
 var profile: Array[Vector2]=[
  Vector2(.055,0),Vector2(.122,.031),Vector2(.160,.095),Vector2(.169,.159),
  Vector2(.153,.228),Vector2(.127,.293),Vector2(.087,.35),Vector2(.045,.391),Vector2(0,.403),
 ]
 var egg: ArrayMesh=desk.lathe395(profile,Vector2i.ZERO)
 egg_shell=StandardMaterial3D.new()
 egg_shell.albedo_color=Color("cbc2aa")
 egg_shell.roughness=.63
 egg_shell.metallic_specular=.22
 egg_shell.emission_enabled=true
 egg_shell.emission=Color("ffc57d")
 var globe: MeshInstance3D=room.shape(stand,egg,Vector3.UP*.82,egg_shell)
 globe.name="MatteGooseEgg"
 globe.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 egg_glow=OmniLight3D.new()
 egg_glow.name="EggLampSpill"
 egg_glow.position=Vector3(0,1.00,.095)
 egg_glow.light_color=Color("ffc286")
 egg_glow.omni_range=2.2
 egg_glow.omni_attenuation=1.6
 stand.add_child(egg_glow)

func at_ground(label: String,at: Vector2) -> Node3D:
 var stand:=Node3D.new()
 stand.name=label
 add_child(stand)
 stand.global_position=Vector3(at.x,home.world.open_ground432(at)+.015,at.y)
 return stand

func build_entry_props() -> void:
 var tree:=at_ground("EntryKumquat",YARD.KUMQUAT)
 var crop:=AtlasTexture.new()
 crop.atlas=KUMQUAT
 crop.region=Rect2(29,31,1021,1385)
 crop.filter_clip=true
 var sprite: Sprite3D=house.card(tree,crop,Vector3.ZERO,1.44,false)
 sprite.rotation_degrees.x=-25.
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
 var pot:=CylinderShape3D.new()
 pot.height=.51
 pot.radius=.25
 var body:=StaticBody3D.new()
 body.collision_mask=0
 tree.add_child(body)
 var collision:=CollisionShape3D.new()
 collision.position.y=pot.height*.5
 collision.shape=pot
 body.add_child(collision)

 var cabinet:=at_ground("EntryShoeCabinet",YARD.SHOE_CABINET)
 var timber:=house.wood.duplicate() as StandardMaterial3D
 timber.albedo_color=Color("c49a77")
 house.block(cabinet,Vector3(0,.335,0),Vector3(1.02,.53,.44),timber)
 house.block(cabinet,Vector3(0,.628,0),Vector3(1.08,.064,.49),timber)
 house.block(cabinet,Vector3(0,.046,0),Vector3(.93,.092,.39),timber)
 var doors:=QuadMesh.new()
 doors.size=Vector2(.978,.514)
 var paint:=StandardMaterial3D.new()
 paint.albedo_texture=CABINET_FRONT
 paint.albedo_color=Color("e4d8c8")
 paint.roughness=.94
 paint.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 var panel: MeshInstance3D=room.shape(cabinet,doors,Vector3(0,.335,.223),paint)
 panel.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 room.collider(cabinet,Vector3(0,.33,0),Vector3(1.06,.66,.47))

 entry_contact(tree,Vector2(.69,.51))
 entry_contact(cabinet,Vector2(1.32,.65))

func entry_contact(prop: Node3D,size: Vector2) -> void:
 var shade:=PlaneMesh.new()
 shade.size=size
 var ink:=ShaderMaterial.new()
 ink.shader=FOOT_CONTACT
 var mark: MeshInstance3D=room.shape(prop,shade,Vector3.DOWN*.006,ink)
 mark.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func build_entrance_mat() -> void:
 var surface:=PlaneMesh.new()
 surface.size=Vector2(1.72,.80)
 var cloth:=ShaderMaterial.new()
 cloth.shader=preload("res://scripts/room/rug391.gdshader")
 cloth.set_shader_parameter("painted_fabric",ENTRANCE_MAT)
 cloth.set_shader_parameter("region",Vector4(18./1774.,44./887.,1738./1774.,797./887.))
 var mat: MeshInstance3D=room.shape(room,surface,Vector3(0,.021,2.66),cloth)
 mat.name="SafePassageMat432"
 mat.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func build_bookshelf() -> void:
 var shelf:=Node3D.new()
 shelf.name="DeskBookshelf432"
 shelf.position=Vector3(-2.04,.006,-3.30)
 room.add_child(shelf)
 # Use the desk's rounded joinery and wood atlas for all shelf pieces.
 var desk: Node3D=room.desk_model395
 var frame:=SurfaceTool.new()
 frame.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:
  var upright: ArrayMesh=desk.rounded_box395(Vector3(.093,1.91,.47),.014,Vector2i(0,1))
  frame.append_from(upright,0,Transform3D(Basis.IDENTITY,Vector3(side*.498,.955,0)))
 var back: ArrayMesh=desk.rounded_box395(Vector3(.93,1.76,.042),.012,Vector2i(0,1))
 frame.append_from(back,0,Transform3D(Basis.IDENTITY,Vector3(0,1.02,-.212)))
 var plank: ArrayMesh=desk.rounded_box395(Vector3(.97,.065,.445),.014)
 for level in [.25,.81,1.35]:
  frame.append_from(plank,0,Transform3D(Basis.IDENTITY,Vector3(0,level,.004)))
 var crown: ArrayMesh=desk.rounded_box395(Vector3(1.14,.106,.53),.023)
 frame.append_from(crown,0,Transform3D(Basis.IDENTITY,Vector3(0,1.91,.013)))
 var apron: ArrayMesh=desk.rounded_box395(Vector3(1.00,.10,.074),.014)
 frame.append_from(apron,0,Transform3D(Basis.IDENTITY,Vector3(0,.175,.186)))
 room.shape(shelf,frame.commit(),Vector3.ZERO,desk.wood395).name="BevelledWoodenFrame"
 room.collider(shelf,Vector3(0,.98,0),Vector3(1.09,1.96,.48))

 var pages:=SurfaceTool.new()
 pages.begin(Mesh.PRIMITIVE_TRIANGLES)
 var spines:=SurfaceTool.new()
 spines.begin(Mesh.PRIMITIVE_TRIANGLES)
 fill_bookshelf_row(pages,spines,.282,-.422,[3,5,7,6,4,0])
 fill_bookshelf_row(pages,spines,.842,-.28,[0,1,2,4,9,8])
 fill_bookshelf_row(pages,spines,1.382,-.419,[5,9,11,7,10])
 add_book_meshes(shelf,pages,spines)

func add_book_meshes(shelf: Node3D,pages: SurfaceTool,spines: SurfaceTool) -> void:
 room.shape(shelf,pages.commit(),Vector3.ZERO,room.desk_model395.paper395).name="BookPageBlocks"
 var bookcloth:=StandardMaterial3D.new()
 bookcloth.albedo_texture=BOOK_SPINES
 bookcloth.roughness=.95
 bookcloth.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 var painted_spines: MeshInstance3D=room.shape(shelf,spines.commit(),Vector3.ZERO,bookcloth)
 painted_spines.name="PaintedBookSpines"
 painted_spines.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func fill_bookshelf_row(pages: SurfaceTool,spines: SurfaceTool,bottom: float,left: float,editions: Array[int]) -> void:
 for index in editions:
  var width:=.083+float(posmod(index,4))*.012
  var height:=.25+float(posmod(index*7,6))*.027
  var depth:=.23+float(posmod(index,3))*.024
  var center:=Vector3(left+width*.5,bottom+height*.5,-.059+float(posmod(index*3,5))*.01)
  var body:=BoxMesh.new()
  body.size=Vector3(width,height,depth)
  pages.append_from(body,0,Transform3D(Basis.IDENTITY,center))
  for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
   # Front faces share the strip texture, with a small inset to keep adjacent colors out of the seams.
   spines.set_uv(Vector2((float(index)+lerpf(.014,.986,corner.x))/12.,corner.y))
   spines.set_normal(Vector3.BACK)
   spines.add_vertex(center+Vector3((corner.x-.5)*width,(.5-corner.y)*height,depth*.5+.002))
  left+=width+.012

func move_tea_outside() -> void:
 var set_points := {
  "tea":Vector2(-3.18,-3.94),
  "tea_chair":Vector2(-3.93,-4.08),
  "goose_stool":Vector2(-2.48,-3.83),
 }
 for id in set_points:
  var row: Dictionary=room.item356(id)
  var piece: Node3D=row.root
  var stand:=at_ground(id+"Outside",set_points[id])
  stand.scale=Vector3.ONE*.82
  var former_height:=piece.position.y
  piece.reparent(stand,false)
  piece.position=Vector3.UP*former_height
  room.footprints.erase(row)
 var parasol:=at_ground("WoodenParasol",Vector2(-2.41,-4.64))
 room.cylinder(parasol,Vector3(0,.91,0),.028,1.82,"755637")
 room.cylinder(parasol,Vector3(0,.075,0),.16,.15,"82786a")
 room.collider(parasol,Vector3(0,.55,0),Vector3(.24,1.1,.24))
 canopy=Node3D.new()
 canopy.position=Vector3.UP*1.78
 parasol.add_child(canopy)
 for i in 8:
  var a:=TAU*i/8.
  var b:=TAU*(i+1)/8.
  var st:=SurfaceTool.new()
  st.begin(Mesh.PRIMITIVE_TRIANGLES)
  var tip:=Vector3(0,.34,0)
  var ea:=Vector3(cos(a)*.73,0,sin(a)*.73)
  var eb:=Vector3(cos(b)*.73,0,sin(b)*.73)
  var mid:=Vector3(cos((a+b)*.5)*.70,-.045,sin((a+b)*.5)*.70)
  for point in [tip,ea,mid,tip,mid,eb]:st.add_vertex(point)
  st.generate_normals()
  var ink: StandardMaterial3D=room.material("ceb583" if i%2==0 else "ac8e77")
  ink.cull_mode=BaseMaterial3D.CULL_DISABLED
  room.shape(canopy,st.commit(),Vector3.ZERO,ink)
 room.ellipsoid(canopy,Vector3.UP*.34,Vector3(.10,.11,.10),"9b7950")
 toggle_parasol()

func toggle_parasol() -> void:
 # A gathered canopy stays visible on the pole as a direct silhouette comparison.
 canopy.scale=Vector3(.19,1.12,.19) if canopy.scale.x>.5 else Vector3.ONE

func build_sand_lamp() -> void:
 var root: Node3D=room.prop("sand_lamp",Vector2(1.98,-2.66),Vector2(.80,.73),1.82,"试亮沙灯",Vector2(1.98,-1.82))
 var entry: Dictionary=room.item356("sand_lamp")
 entry["thought"]="轻轻一碰，\n时光沙就亮起来了。"
 entry["thought_anchor"]=Vector3(0,1.64,0)
 room.cylinder(root,Vector3(0,.10,0),.38,.20,"775237")
 room.cylinder(root,Vector3(0,.28,0),.31,.24,"a17249")
 room.cylinder(root,Vector3(0,.45,0),.40,.11,"92603d")
 room.hour.reparent(root,false)
 room.hour.position=Vector3.UP*.49
 room.hour.scale=Vector3.ONE*.55
 room.hour.show()
 for light in room.hour.find_children("*","OmniLight3D",true,false):
  sand_glow=light
  sand_glow.light_energy=.26
  sand_glow.omni_range=1.55
  sand_glow.shadow_enabled=false

func light_sand_lamp() -> void:
 if is_instance_valid(pulse):pulse.kill()
 pulse=create_tween().set_trans(Tween.TRANS_SINE)
 pulse.tween_property(sand_glow,"light_energy",.58,.42)
 pulse.tween_property(sand_glow,"light_energy",.26,1.2)

func wall_art(wall: Node3D,texture: Texture2D,bounds: Rect2,base: Vector3,height: float) -> Sprite3D:
 var crop:=AtlasTexture.new()
 crop.atlas=texture
 crop.region=bounds
 crop.filter_clip=true
 var sprite: Sprite3D=house.card(wall,crop,base,height)
 # These cutouts are attached to the wall in the building's plane.
 sprite.rotation=Vector3.ZERO
 return sprite

func build_wall_decor() -> void:
 var wall:=Node3D.new()
 wall.name="WallDecor432"
 house.shell.add_child(wall)
 wall_art(wall,DRIED_FLOWERS,Rect2(137,95,818,1205),Vector3(1.81,1.50,3.355),1.07).name="PaintedDriedFlowers"
 wall_art(wall,GOOSE_PLAQUE,Rect2(300,194,882,646),Vector3(1.81,.84,3.362),.60).name="PaintedGoosePlaque"
 var lantern:=Vector3(5.77,1.92,2.37)
 room.box(wall,lantern+Vector3(0,.23,0),Vector3(.065,.09,.25),"5c4332")
 room.cylinder(wall,lantern+Vector3.UP*.18,.15,.075,"69503a",.06)
 var wick: MeshInstance3D=room.cylinder(wall,lantern,.103,.27,"ffd890")
 var ink:=wick.material_override.duplicate() as StandardMaterial3D
 ink.emission_enabled=true
 ink.emission=Color("ffc36b")
 ink.emission_energy_multiplier=.65
 wick.material_override=ink
 room.cylinder(wall,lantern-Vector3.UP*.152,.12,.05,"69503a")
 var porch_light:=OmniLight3D.new()
 porch_light.position=lantern+Vector3(0,0,.08)
 porch_light.light_color=Color("ffd08e")
 porch_light.light_energy=.33
 porch_light.omni_range=1.55
 wall.add_child(porch_light)
 house.front_lamps.append({"node":porch_light,"energy":.33})
 var ivy:=wall_art(wall,RIGHT_IVY,Rect2(70,104,1088,1007),Vector3(4.65,1.00,2.36),1.58)
 ivy.name="PaintedRightWallIvy"
 ivy.scale.x=1.14
 for mesh in wall.find_children("*","MeshInstance3D",true,false):
  house.register_cut(mesh,house.front_cut)
  house.front_cut.back().ink.set_shader_parameter("house_origin",home.global_position)
 for i in 4:
  var plant:=at_ground("ShortFlowerBorder",Vector2(-1.84+float(i)*.27,-5.99+float(i)*.35))
  var daisies: Sprite3D=house.card(plant,house.DAISIES,Vector3.ZERO,.43+float(i%2)*.08,false)
  daisies.rotation_degrees.x=-25.
  daisies.flip_h=i%2!=0

