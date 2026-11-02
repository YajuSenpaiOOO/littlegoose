extends MultiMeshInstance3D
const LIMIT227 := 256
var battle: Node3D
var submitted227 := 0
var unique227 := {}
var field_revision227 := -1
func _ready() -> void:
 name="DepthTestedPaperLandingRings227"
 cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 multimesh=MultiMesh.new();multimesh.transform_format=MultiMesh.TRANSFORM_3D;multimesh.use_colors=true;multimesh.use_custom_data=true
 var vertices=PackedVector3Array();var uvs=PackedVector2Array()
 for i in 48:
  var a=Vector3(cos(TAU*i/48.),0,sin(TAU*i/48.));var b=Vector3(cos(TAU*(i+1)/48.),0,sin(TAU*(i+1)/48.))
  vertices.append_array(PackedVector3Array([a,b,a,a,b,b]));uvs.append_array(PackedVector2Array([Vector2(0,0),Vector2(0,0),Vector2(0,1),Vector2(0,1),Vector2(0,0),Vector2(0,1)]))
 var arrays=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_TEX_UV]=uvs
 var geometry=ArrayMesh.new();geometry.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
 multimesh.mesh=geometry;multimesh.instance_count=LIMIT227;multimesh.visible_instance_count=0
 var ink=ShaderMaterial.new();ink.shader=preload("res://scripts/combat/paper_markers227.gdshader");material_override=ink
 # Vertex shader places every vertex on the cached terrain; do not cull by its unwarped Y.
 custom_aabb=AABB(Vector3(-150,-40,-150),Vector3(350,100,350))
func clear227() -> void:
 if multimesh!=null:multimesh.visible_instance_count=0
 submitted227=0;unique227.clear()
func ring227(at: Vector3,radius: float,color: Color) -> void:
 var key=Vector3(roundf(at.x*10.)/10.,roundf(at.z*10.)/10.,radius)
 if unique227.has(key):
  var old: Dictionary=unique227[key]
  if old.color.a<color.a:old.color=color
 else:unique227[key]={"at":at,"radius":radius,"color":color}
func update227(paper: Node3D,enabled: bool) -> void:
 clear227()
 if not enabled or battle.shadow_field113.height_texture==null:return
 if field_revision227!=battle.shadow_field113.revision:
  battle.shadow_field113.bind_shader(material_override);field_revision227=battle.shadow_field113.revision
 if paper.pending_mark149.is_finite():ring227(paper.pending_mark149,paper.marker_radius150(),Color(1.,.91,.62,.45))
 for f in paper.planes149:
  var alpha=1.-smoothstep(float(f.release)+.25,float(f.release)+.8,float(f.age))
  if alpha<=0.:continue
  var color=Color(.97,.8,.53,.75*alpha) if not f.replay else Color(.68,.85,1.,.65*alpha)
  ring227(f.mark,paper.marker_radius150(),color);ring227(f.mark,.15,color)
  if f.has("coverage151"):
   for i in f.coverage151.size():
    if i>=int(f.next):ring227(f.coverage151[i],.16,Color(.98,.89,.65,.3*alpha))
 for entry in unique227.values():
  if submitted227>=LIMIT227:break
  # World-space instance locations, independent of the notebook manager transform.
  multimesh.set_instance_transform(submitted227,global_transform.affine_inverse()*Transform3D(Basis.IDENTITY,entry.at))
  multimesh.set_instance_color(submitted227,entry.color);multimesh.set_instance_custom_data(submitted227,Color(entry.radius,0,0,0));submitted227+=1
 multimesh.visible_instance_count=submitted227
