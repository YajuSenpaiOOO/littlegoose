extends Node3D
## One world wind vector for grass tips, fixed ribbon knots and sparse seabird flights.
var world: Node3D
const WIND143=Vector3(.95,0.,-.31)
var ribbons143: Array[MeshInstance3D]=[]
var birds143: Array[MeshInstance3D]=[]
var shader_cache143: Dictionary={}
var clipped_materials143: Dictionary={}
var scan_wait143 := 0.
var pending_scans143: Array=[]
var next_bird143 := 8.
var bird_age143 := -1.
var flight_count143 := 0
var cloth_clock143 := 0.
var cloth143: StandardMaterial3D
var bird_mat143: StandardMaterial3D
func _ready() -> void:
 name="CoastalBreeze143"
 cloth143=StandardMaterial3D.new();cloth143.albedo_color=Color(.85,.68,.48);cloth143.roughness=1.;cloth143.cull_mode=BaseMaterial3D.CULL_DISABLED
 bird_mat143=StandardMaterial3D.new();bird_mat143.albedo_color=Color(.88,.92,.89);bird_mat143.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;bird_mat143.cull_mode=BaseMaterial3D.CULL_DISABLED
 var g: Vector2=world.meadow.landmarks.grove
 for index in [1,6]:
  var p: Vector2=world.park99.fence_points140[mini(index,world.park99.fence_points140.size()-1)]
  var node := MeshInstance3D.new();node.material_override=cloth143;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  add_child(node);node.position=Vector3(g.x+p.x,world.floor_height(g+p)+.65,g.y+p.y);ribbons143.append(node)
 for i in 3:
  var node := MeshInstance3D.new();node.material_override=bird_mat143;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;node.hide();add_child(node);birds143.append(node)
 scan_shadows143(world)
 # Runtime binding only ever targets materials on NEW nodes (shader swaps on
 # existing materials reuse the same instance and stay skipped by the
 # clipped_materials143 dedupe), so react to node_added instead of walking
 # the whole 6.5k-node tree every second.
 world.get_tree().node_added.connect(_node_added143)
func _node_added143(node: Node) -> void:
 pending_scans143.append(node)
# Reject projected fragments bridging steep cliffs in mid-air, as well as
# fragments outside the coastline. Keep shadows on the actual land.
func clipped_shader143(source: Shader) -> Shader:
 var key := source.get_instance_id()
 if shader_cache143.has(key): return shader_cache143[key]
 var code: String=source.code
 var declarations := "\nuniform bool clip_west_water143=false;\nuniform vec4 coast_bounds143;\nuniform vec2 coast_origin143;\nuniform vec2 coast_points143[13];\nvarying vec2 shadow_xz143;\nvarying float shadow_y143;\n"
 code=code.replace("shader_type spatial;","shader_type spatial;"+declarations)
 var expression := "(INV_VIEW_MATRIX*vec4(VERTEX,1.)).xz" if code.contains("skip_vertex_transform") else "(MODEL_MATRIX*vec4(VERTEX,1.)).xz"
 if not code.contains("float terrain113("):
  var terrain_code: String=preload("res://scripts/art/actor_shadow113.gdshader").code
  code=code.replace("void fragment()",terrain_code.substr(terrain_code.find("uniform sampler2D terrain_heights113"),terrain_code.find("void vertex()")-terrain_code.find("uniform sampler2D terrain_heights113"))+"\nvoid fragment()")
 var y_expression := "(INV_VIEW_MATRIX*vec4(VERTEX,1.)).y" if code.contains("skip_vertex_transform") else "(MODEL_MATRIX*vec4(VERTEX,1.)).y"
 var start := code.find("void vertex()")
 if start<0: start=code.find("void vertex() ")
 if start<0:
  code+="\nvoid vertex(){shadow_xz143="+expression+";shadow_y143="+y_expression+";}\n"
 else:
  var opening := code.find("{",start);var depth := 1;var end := opening+1
  while depth>0:
   if code[end]=="{": depth+=1
   elif code[end]=="}": depth-=1
   end+=1
  code=code.insert(end-1,"shadow_xz143="+expression+";shadow_y143="+y_expression+";\n")
 var fragment := code.find("void fragment()")
 if fragment<0: return source
 var opening := code.find("{",fragment)
 var clip := "\nif(shadow_xz143.x<coast_bounds143.x || shadow_xz143.y<coast_bounds143.y || shadow_xz143.x>coast_bounds143.z || shadow_xz143.y>coast_bounds143.w) discard; vec2 p143=shadow_xz143-coast_origin143; float edge143=1.; if(p143.y<coast_points143[0].y){edge143=p143.x-coast_points143[12].x; for(int i=0;i<12;i++){vec2 a143=coast_points143[i];vec2 b143=coast_points143[i+1];if(p143.y>=b143.y){edge143=p143.x-mix(a143.x,b143.x,(p143.y-a143.y)/(b143.y-a143.y));break;}}} if(clip_west_water143 && p143.x< -30. && p143.y> -27. && p143.y< -3. && shadow_y143<8.) discard; if(edge143<.035 || abs(shadow_y143-terrain113(shadow_xz143)-.024)>.12) discard;\n"
 code=code.insert(opening+1,clip)
 var shader := Shader.new();shader.code=code;shader_cache143[key]=shader;shader_cache143[shader.get_instance_id()]=shader
 return shader
func bind143(mat: Material) -> void:
 if not mat is ShaderMaterial or mat.shader==null or clipped_materials143.has(mat.get_instance_id()): return
 var code: String=mat.shader.code
 if not code.contains("shader_type spatial") or not (mat.shader.resource_path.contains("shadow") or code.contains("silhouette")): return
 mat.shader=clipped_shader143(mat.shader)
 world.shadow_field113.bind_shader(mat)
 var bounds: Rect2=world.meadow.world_bounds.grow(6.)
 mat.set_shader_parameter("coast_bounds143",Vector4(bounds.position.x,bounds.position.y,bounds.end.x,bounds.end.y))
 mat.set_shader_parameter("clip_west_water143",world.has_method("painted_shadow_height145"))
 mat.set_shader_parameter("coast_origin143",world.meadow.landmarks.grove)
 mat.set_shader_parameter("coast_points143",PackedVector2Array(world.coast_edge140.coastline140()))
 clipped_materials143[mat.get_instance_id()]=true
func scan_shadows143(node: Node) -> void:
 if node is GeometryInstance3D: bind143(node.material_override)
 if node is MeshInstance3D and node.mesh!=null:
  for surface in node.mesh.get_surface_count():
   bind143(node.get_surface_override_material(surface));bind143(node.mesh.surface_get_material(surface))
 for child in node.get_children(): scan_shadows143(child)
func ribbon_mesh143(phase: float) -> ArrayMesh:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for j in 10:
  var ring: Array[Vector3]=[]
  for step in [j,j+1]:
   var t := float(step)/10.
   var p := WIND143*t*.76+Vector3.UP*(-.09*t+sin(world.clock*4.4-t*7.+phase)*.055*t*t)
   var width := Vector3.UP*.045*(1.-t*.32)
   ring.append(p-width);ring.append(p+width)
  for k in [0,2,3,0,3,1]: st.set_normal(Vector3(0,0,1));st.add_vertex(ring[k])
 return st.commit()
func bird_mesh143(phase: float) -> ArrayMesh:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var flap := sin(world.clock*5.+phase)*.12
 for side in [-1.,1.]:
  for at in [Vector3(0,0,0),Vector3(side*.28,.04+flap,0),Vector3(side*.15,-.015,0),Vector3(0,-.035,0),Vector3(side*.15,-.015,0),Vector3(side*.06,.02,0)]:
   st.set_normal(Vector3(0,0,1));st.add_vertex(at)
 return st.commit()
func _process(delta: float) -> void:
 if not pending_scans143.is_empty():
  for node in pending_scans143:
   if is_instance_valid(node): scan_shadows143(node)
  pending_scans143.clear()
 cloth_clock143-=delta
 if cloth_clock143<=0.:
  cloth_clock143=.05
  for i in ribbons143.size(): ribbons143[i].mesh=ribbon_mesh143(i*1.4)
 next_bird143-=delta
 if bird_age143<0. and next_bird143<=0.:
  bird_age143=0.;flight_count143+=1;next_bird143=29.+float(flight_count143%3)*7.
 if bird_age143>=0.:
  bird_age143+=delta
  var g: Vector2=world.meadow.landmarks.grove
  for i in birds143.size():
   var bird: MeshInstance3D=birds143[i];bird.visible=bird_age143<18.
   bird.position=Vector3(g.x-51.,15.8,g.y-36.)+WIND143*bird_age143*1.3+Vector3(-i*.9,i*.27,-i*.6)
   bird.basis=world.coast141.panorama141.global_basis;bird.mesh=bird_mesh143(i*1.7)
  if bird_age143>=18.: bird_age143=-1.
