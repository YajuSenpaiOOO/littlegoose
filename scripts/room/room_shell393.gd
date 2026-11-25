extends "res://scripts/room/room_shell392.gd"
var dressing393: MeshInstance3D
var old_window393: Array[MeshInstance3D]=[]
var upper_wall393: MeshInstance3D
var old_upper393: Mesh
var arch393: ArrayMesh
var use_window393:=true
var garden393: MeshInstance3D
var garden_mat393: StandardMaterial3D
var lamp_nodes393: Array[Dictionary]=[]
func build_shell() -> void:
 super.build_shell()
 for c in get_children():
  if not c is MeshInstance3D:continue
  var p: Vector3=c.position
  if c.mesh is QuadMesh and p.z<-4.55:
   old_window393.append(c)
  elif c.mesh is BoxMesh:
   if p.distance_to(Vector3(-.5,3.2,-4.5))<.01:upper_wall393=c
   elif (absf(p.z+4.25)<.01 and ((absf(p.y-2.)<.01 and c.mesh.size.x<.11) or (absf(p.x+.5)<.01 and c.mesh.size.x<3.2 and c.mesh.size.y<.11))) or absf(p.z+4.10)<.01 and absf(p.y-2.04)<.01 or absf(p.z+4.01)<.01 and absf(p.y-1.78)<.01:
    old_window393.append(c)
 old_upper393=upper_wall393.mesh
 arch393=make_arch393()
 var mat:=StandardMaterial3D.new()
 mat.albedo_texture=preload("res://assets/room393/window.png")
 mat.albedo_color=Color(.90,.94,.97)
 mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
 mat.alpha_scissor_threshold=.5;mat.roughness=1.;mat.specular_mode=BaseMaterial3D.SPECULAR_DISABLED
 mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 var quad:=QuadMesh.new();quad.size=Vector2(4.,4.*1008./1560.)
 dressing393=shape(self,quad,Vector3(-.5,2.35,-4.10),mat);dressing393.name="CurtainsFrameFlowers393"
 garden_mat393=StandardMaterial3D.new();garden_mat393.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 garden_mat393.albedo_texture=preload("res://assets/room393/garden.png")
 var landscape:=QuadMesh.new();landscape.size=Vector2(3.15,2.1)
 garden393=shape(self,landscape,Vector3(-.5,2.25,-4.58),garden_mat393);garden393.name="OutsideGarden393"
 garden393.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 # Wall-mounted elevation, parallel to the rear wall, never a camera billboard.
 # Alpha-tested silhouette casts only one shadow; the blank rectangular card does not.
 set_window393(true)
func make_arch393() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 48:
  var x0: float=-1.5+3.*float(i)/48.;var x1: float=-1.5+3.*float(i+1)/48.
  var y0: float=2.80+.50*sqrt(maxf(0.,1.-pow(x0/1.5,2.)))-3.2
  var y1: float=2.80+.50*sqrt(maxf(0.,1.-pow(x1/1.5,2.)))-3.2
  var a:=Vector3(x0,y0,.11);var b:=Vector3(x1,y1,.11)
  var c:=Vector3(x1,.4,.11);var d:=Vector3(x0,.4,.11)
  # Inner front face plus curved reveal into the wall thickness.
  for v in [a,b,c,a,c,d]:st.add_vertex(v)
  var e:=a-Vector3(0,0,.22);var f:=b-Vector3(0,0,.22)
  for v in [e,f,b,e,b,a,d,c,c-Vector3(0,0,.22),d,c-Vector3(0,0,.22),d-Vector3(0,0,.22),f,e,Vector3(x0,.4,-.11),f,Vector3(x0,.4,-.11),Vector3(x1,.4,-.11)]:st.add_vertex(v)
 st.generate_normals();return st.commit()
func build_furniture() -> void:
 super.build_furniture()
 # The old shelf immediately over the window intersects the new lintel/rod.
 for c in get_children():
  if c is MeshInstance3D and c.mesh is BoxMesh and c.position.x>-1.9 and c.position.x<.9 and c.position.y>=3. and c.position.z>-4.31 and c.position.z<-3.8:
   old_window393.append(c);c.visible=not use_window393
 var desk: Node3D=item356("desk").root
 for c in desk.get_children():
  if (c is MeshInstance3D or c is OmniLight3D) and absf(c.position.x+.94)<.01:
   lamp_nodes393.append({"node":c,"original":c.position});c.position.x+=1.82
func set_window393(value: bool) -> void:
 use_window393=value
 for c in old_window393:
  c.visible=not value
  if c.mesh is QuadMesh:
   c.visible=not value
 dressing393.visible=value;upper_wall393.mesh=arch393 if value else old_upper393
 garden393.visible=value
 for row in lamp_nodes393:row.node.position=row.original+(Vector3(1.82,0,0) if value else Vector3.ZERO)
func set_garden_night393(value: bool) -> void:
 garden_mat393.albedo_color=Color(.13,.19,.28) if value else Color(.92,.95,.92)
