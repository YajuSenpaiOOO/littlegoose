extends "res://scripts/room/room_shell400.gd"
var compact402:=true
var shell_state402: Array=[]
var prop_state402: Array=[]
var foreground402: Node3D
var roof402: Node3D
var blockers402: Array[StaticBody3D]=[]
func build_shell() -> void:
 super.build_shell()
 for c in get_children():
  if c is MeshInstance3D and c.mesh is BoxMesh:shell_state402.append({"node":c,"at":c.position,"mesh":c.mesh})
  elif c is StaticBody3D and c.get_child_count()>0 and c.get_child(0) is CollisionShape3D:
   shell_state402.append({"node":c,"at":c.position,"shape":c.get_child(0).shape})
 roof402=Node3D.new();roof402.name="CutawayVault402";add_child(roof402)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 64:
  var x0: float=-6.3+12.6*float(i)/64.;var x1: float=-6.3+12.6*float(i+1)/64.
  var y0: float=frame399.outer399(x0)+.04;var y1: float=frame399.outer399(x1)+.04
  for p in [Vector3(x0,y0,-4.5),Vector3(x1,y1,2.7),Vector3(x1,y1,-4.5),Vector3(x0,y0,-4.5),Vector3(x0,y0,2.7),Vector3(x1,y1,2.7)]:st.set_normal(Vector3.DOWN);st.add_vertex(p)
 var plaster:=StandardMaterial3D.new();plaster.albedo_color=Color("c8b18e");plaster.roughness=1.;plaster.cull_mode=BaseMaterial3D.CULL_DISABLED
 shape(roof402,st.commit(),Vector3.ZERO,plaster)
 var trim:=preload("res://scripts/room/timber_frame399.gd").new();roof402.add_child(trim)
 var arch: Array[Vector2]=[]
 for i in 65:
  var x: float=-6.25+12.5*float(i)/64.;arch.append(Vector2(x,trim.outer399(x)-.12))
 trim.beam399(arch,.30,.32,2.7,"ForegroundDoorArch")
 for side in [-1.,1.]:trim.block399(Vector3(side*6.12,1.7,2.7),Vector3(.25,3.4,.25),"ForegroundDoorPost")
 # Starts beyond the retained floor and moved doorstep: no coplanar overlap.
 var deck:=PlaneMesh.new();deck.size=Vector2(12.6,2.10)
 shape(roof402,deck,Vector3(0,-.005,5.45),painted_floor391).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
func build_furniture() -> void:
 super.build_furniture()
 for row in footprints:prop_state402.append({"row":row,"at":row.at,"approach":row.approach,"position":row.root.position})
 foreground402=Node3D.new();foreground402.name="ForegroundBlockout402";add_child(foreground402)
 block_prop402(Vector3(-4.65,0,1.75),Vector3(1.65,.65,1.1),"92704f")
 box(foreground402,Vector3(-4.65,.70,1.75),Vector3(1.73,.14,1.16),"a18560")
 box(foreground402,Vector3(-4.8,.96,1.68),Vector3(.95,.36,.65),"8e9472")
 for x in [-5.15,-4.15]:box(foreground402,Vector3(x,.42,2.31),Vector3(.055,.55,.035),"c4a56b")
 block_prop402(Vector3(-3.25,0,1.45),Vector3(.65,.55,.65),"ad9367")
 box(foreground402,Vector3(-3.25,.60,1.45),Vector3(.56,.12,.56),"ddd0af")
 block_prop402(Vector3(-5.75,0,.35),Vector3(.60,.48,.60),"8b7050")
 for at in [Vector3(-5.9,.78,.32),Vector3(-5.55,.89,.35),Vector3(-5.72,1.10,.24)]:box(foreground402,at,Vector3(.48,.43,.43),"78875b")
 set_layout402(true)
func block_prop402(at: Vector3,size: Vector3,color: String) -> void:
 box(foreground402,at+Vector3.UP*size.y*.5,size,color)
 blockers402.append(collider(foreground402,at+Vector3.UP*size.y*.5,size))
func set_layout402(value: bool) -> void:
 compact402=value;roof402.visible=value;foreground402.visible=value
 for body in blockers402:body.collision_layer=1 if value else 0
 for saved in shell_state402:
  var c: Node3D=saved.node;c.position=saved.at
  if saved.has("mesh"):c.mesh=saved.mesh
  else:c.get_child(0).shape=saved.shape
  if not value:continue
  var size: Vector3=saved.mesh.size if saved.has("mesh") else saved.shape.size
  if absf(saved.at.z-4.5)<.01 or absf(saved.at.z-5.25)<.01 or absf(saved.at.z-6.05)<.01:
   c.position.z-=1.8
   # Moved doorstep lies beneath the retained floor; separate its visible top.
   # Keep the existing walkable collision top, and restore the old mesh on 6.
   if saved.has("mesh") and absf(saved.at.z-5.25)<.01 and size.x>2.:c.position.y-=.03
  elif absf(absf(saved.at.x)-6.4)<.02 and size.z>=9.:
   c.position.z=-.9;var copy=saved.mesh.duplicate() if saved.has("mesh") else saved.shape.duplicate();copy.size.z-=1.8
   if saved.has("mesh"):c.mesh=copy
   else:c.get_child(0).shape=copy
  elif absf(absf(saved.at.x)-6.24)<.02 and size.z>8.:
   c.position.z=-.9;var copy=saved.mesh.duplicate();copy.size.z-=1.8;c.mesh=copy
 for saved in prop_state402:
  var row: Dictionary=saved.row;row.at=saved.at;row.approach=saved.approach;row.root.position=saved.position
  var delta:=Vector2.ZERO
  if value:
   match row.id:
    "tea":delta=Vector2(.30,-.10)
    "tea_chair":delta=Vector2(.30,.10)
    "goose_stool":delta=Vector2(.35,.15)
  row.at+=delta;row.approach+=delta;row.root.position+=Vector3(delta.x,0,delta.y)
 for row in furniture394:row.sprite.material_override.set_shader_parameter("foot394",row.sprite.global_position)
