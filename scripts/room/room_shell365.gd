extends "res://scripts/room/room_shell364.gd"
const LINEN365=preload("res://scripts/room/linen_mesh365.gd")
var linen365: Node3D
var skirt365: MeshInstance3D
var fitted365: MeshInstance3D
var old_mattress365: MeshInstance3D
var old_support365: Array[MeshInstance3D]=[]
var old_legs365: Array[MeshInstance3D]=[]
var show_linen365:=true
var pattern365: RefCounted
func build_furniture() -> void:
 super.build_furniture()
 for n in craft364.get_children():
  if n is MeshInstance3D:
   if n.material_override==support_mat364:old_mattress365=n
   if n.mesh is BoxMesh:
    old_support365.append(n)
    if n.mesh.size.is_equal_approx(Vector3(.15,.32,.15)):old_legs365.append(n)
 linen365=Node3D.new();linen365.name="FittedSheetAndGatheredSkirt365";craft364.add_child(linen365)
 fitted365=shape(linen365,CRAFT364.pillow364(),Vector3(0.,.64,0.),linen_material365("sheet_fabric.png"));fitted365.name="FittedCreamSheet";fitted365.rotation_degrees.x=-90.;fitted365.scale=Vector3(2.39/.96,2.81/.65,.316/.28);fitted365.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 pattern365=LINEN365.new()
 skirt365=shape(linen365,pattern365.mesh365(),Vector3.ZERO,linen_material365("skirt_hem.png"));skirt365.name="ContinuousGatheredSkirt";skirt365.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 # Inset runners are real support; the old square-ended rails no longer poke through rounded skirt corners.
 for x in [-1.02,1.02]:box(linen365,Vector3(x,.33,0.),Vector3(.10,.18,2.60),"886345")
 box(linen365,Vector3(0.,.33,1.30),Vector3(2.10,.18,.10),"886345")
 var wood: Material=head364.get_child(0).material_override
 for z in [-1.20,1.34]:
  var xs: Array=[-.93,.93] if z>0. else [-1.06,1.06]
  for x in xs:add_piece364(linen365,LINEN365.foot365(),Vector3(x,0.,z),wood)
 var row:=item356("bed")
 for x in [-.93,.93]:
  var plane:=PlaneMesh.new();plane.size=Vector2(.35,.30)
  var shadow:=ShaderMaterial.new();shadow.shader=preload("res://scripts/art/foot_contact16.gdshader")
  var foot_shadow:=shape(linen365,plane,Vector3(x,.014,1.34),shadow);foot_shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 set_linen365(true)
func linen_material365(file: String) -> ShaderMaterial:
 var m:=ShaderMaterial.new();m.shader=preload("res://scripts/room/painted_linen365.gdshader");m.set_shader_parameter("paint",source356("res://assets/room365/"+file));craft_mats364.append(m);return m
func set_linen365(value: bool) -> void:
 show_linen365=value
 if not is_instance_valid(linen365):return
 linen365.visible=value;old_mattress365.visible=not value
 for n in old_support365:n.visible=not value
 contact_pillow364.position.y=.804 if value else .787
