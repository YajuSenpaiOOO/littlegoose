extends MeshInstance3D
## Three sequential native mesh sections reveal one original paper-fire image.
var extent303 := 0.
func _ready() -> void:
 top_level=true;cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink=StandardMaterial3D.new();ink.albedo_texture=preload("res://assets/paper_attack303/fire.png");ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;ink.cull_mode=BaseMaterial3D.CULL_DISABLED;ink.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;ink.albedo_color=Color(.94,.94,.94,1.);material_override=ink;hide()
func show303(start: Vector3,end: Vector3,camera_at: Vector3,reveal: float,clock: float) -> void:
 var forward=end-start;var length=forward.length()
 if length<.01 or reveal<=.001:hide();extent303=0.;return
 forward/=length
 var cross=width_axis303(start,forward,camera_at)
 if cross.length()<.1:cross=Vector3.RIGHT
 var width=1.65*(1.+sin(clock*15.)*.025)
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var cut=clampf(reveal,0.,1.);extent303=length*cut
 for i in 3:
  var a=float(i)/3.;var b=minf(float(i+1)/3.,cut)
  if a>=cut:break
  for uv in [Vector2(a,0),Vector2(b,0),Vector2(b,1),Vector2(a,0),Vector2(b,1),Vector2(a,1)]:
   var folded=Vector3.UP*sin(uv.x*PI*3.)*.055*sin(clock*7.)
   st.set_uv(uv);st.add_vertex(start+forward*length*uv.x+cross*(.60-uv.y)*width+folded)
 mesh=st.commit();global_transform=Transform3D.IDENTITY;show()
func width_axis303(start: Vector3,forward: Vector3,camera_at: Vector3) -> Vector3:return (camera_at-start).normalized().cross(forward).normalized()
