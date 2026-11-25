extends "res://scripts/room/room_shell357.gd"
var bed358: Node3D
var blanket358: Node3D
var slots358: Node3D
var sleep_anchors358: Array[Node3D]=[]
var bed_texture358: Texture2D
var bed_solid358:=true
func build_furniture() -> void:
 super.build_furniture()
 var row:=item356("bed")
 row.title="双人床（结构试版）"
 bed358=Node3D.new();bed358.name="LayeredDoubleBed";row.root.add_child(bed358)
 # Keep accepted floor footprint; split real solid frame and soft surface layers.
 part358(bed358,Vector3(0.,.36,0.),Vector3(2.5,.28,2.98),Vector2i(0,1))
 for x in [-1.12,1.12]:
  for z in [-1.33,1.33]:part358(bed358,Vector3(x,.17,z),Vector3(.18,.34,.18),Vector2i(0,1))
 part358(bed358,Vector3(0.,.63,.02),Vector3(2.36,.26,2.78),Vector2i(1,1))
 part358(bed358,Vector3(0.,1.02,-1.4),Vector3(2.5,.94,.13),Vector2i(0,1))
 part358(bed358,Vector3(0.,.49,1.43),Vector3(2.5,.22,.12),Vector2i(0,1))
 for x in [-.59,.59]:
  part358(bed358,Vector3(x,.82,-.95),Vector3(.95,.12,.57),Vector2i(1,0))
  var anchor:=Node3D.new();anchor.name="SleepLeft" if x<0 else "SleepRight";anchor.position=Vector3(x,.78,-.60);bed358.add_child(anchor);sleep_anchors358.append(anchor)
 blanket358=Node3D.new();blanket358.name="BlanketAboveSleepers";bed358.add_child(blanket358)
 part358(blanket358,Vector3(0.,.91,.39),Vector3(2.4,.12,1.92),Vector2i(0,0))
 for x in [-1.21,1.21]:part358(blanket358,Vector3(x,.70,.39),Vector3(.035,.36,1.92),Vector2i(0,0))
 part358(blanket358,Vector3(0.,.69,1.37),Vector3(2.4,.34,.035),Vector2i(0,0))
 slots358=Node3D.new();slots358.name="DebugSleepVolumes_NotActors";bed358.add_child(slots358)
 for anchor in sleep_anchors358:
  var m:=StandardMaterial3D.new();m.albedo_color=Color(.42,.72,.88,.6);m.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  var b:=BoxMesh.new();b.size=Vector3(.64,.10,1.32)
  shape(slots358,b,anchor.position+Vector3(0.,.035,.37),m).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 slots358.hide()
 # Mattress and headboard collision follow their real sizes; no large sprite-depth approximation.
 for child in row.root.get_children():
  if child is StaticBody3D:
   child.position=Vector3(0.,.38,0.);child.get_child(0).shape.size=Vector3(2.55,.76,3.)
 collider(row.root,Vector3(0.,1.02,-1.4),Vector3(2.5,.94,.13))
 row.height=.76
 set_art356(true)
func part358(parent: Node3D,at: Vector3,size: Vector3,tile: Vector2i) -> void:
 var mesh:=SurfaceTool.new();mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 for face in [[Vector3.RIGHT,Vector3.BACK,Vector3.UP],[Vector3.LEFT,Vector3.FORWARD,Vector3.UP],[Vector3.UP,Vector3.RIGHT,Vector3.FORWARD],[Vector3.DOWN,Vector3.RIGHT,Vector3.BACK],[Vector3.BACK,Vector3.RIGHT,Vector3.UP],[Vector3.FORWARD,Vector3.LEFT,Vector3.UP]]:
  for index in [0,2,1,0,3,2]:
   var uv: Vector2=[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)][index]
   var n: Vector3=face[0];var u: Vector3=face[1];var v: Vector3=face[2]
   mesh.set_normal(n);mesh.set_uv((Vector2(tile)+Vector2(.004,.004)+uv*.992)*.5)
   mesh.add_vertex((n+u*(uv.x*2.-1.)+v*(1.-uv.y*2.))*size*.5)
 if bed_texture358==null:bed_texture358=source358()
 var mat:=StandardMaterial3D.new();mat.albedo_texture=bed_texture358;mat.albedo_color=Color(.83,.83,.83);mat.roughness=1.;mat.metallic_specular=0.;mat.cull_mode=BaseMaterial3D.CULL_DISABLED;mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
 shape(parent,mesh.commit(),at,mat)
func source358() -> Texture2D:
 return source356("res://assets/room358/bed_atlas.png")
func set_art356(value: bool) -> void:
 super.set_art356(value)
 if not is_instance_valid(bed358):return
 bed358.visible=value and bed_solid358
 for row in cards356:
  if row.id=="bed" and value:
   row.sprite.visible=not bed_solid358;row.shadow.visible=not bed_solid358
func toggle_bed358() -> void:
 bed_solid358=not bed_solid358;set_art356(true)
