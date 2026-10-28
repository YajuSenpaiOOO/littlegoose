extends "res://scripts/combat/paper_squad169.gd"
var ground204: MeshInstance3D
var vertices204 := PackedVector3Array()
var marks204: Array=[]
var clipped204 := 0
func _ready() -> void:
 super._ready()
 ground204=MeshInstance3D.new();ground204.name="TerrainPaperMarks204"
 ground204.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/combat/ground_mark204.gdshader");ink.render_priority=-10
 ground204.material_override=ink;add_child(ground204)
func reset146() -> void:
 super.reset146()
 if is_instance_valid(ground204): ground204.mesh=null;ground204.hide()
 marks204.clear();vertices204.clear()
func ring150(_at: Vector3,_radius: float,_color: Color) -> void:
 # Retire the screen-space rings. Gameplay still uses the original mark/radius.
 pass
func add_mark204(at: Vector3,radius: float,color: Color) -> void:
 for mark in marks204:
  if mark.at.distance_squared_to(at)<.0001 and absf(mark.radius-radius)<.001:
   if color.a>mark.color.a: mark.color=color
   return
 marks204.append({"at":at,"radius":radius,"color":color})
func rebuild204() -> void:
 if not is_instance_valid(ground204): return
 marks204.clear();vertices204.clear();clipped204=0
 if pending_mark149.is_finite(): add_mark204(pending_mark149,marker_radius150(),Color(1.,.91,.62,.45))
 for f in planes149:
  var alpha := 1.-smoothstep(float(f.release)+.25,float(f.release)+.8,float(f.age))
  if alpha<=0.: continue
  var color := Color(.97,.8,.53,.75*alpha) if not f.replay else Color(.68,.85,1.,.65*alpha)
  add_mark204(f.mark,marker_radius150(),color);add_mark204(f.mark,.15,color)
  if f.has("coverage151"):
   for i in f.coverage151.size():
    if i>=int(f.next): add_mark204(f.coverage151[i],.16,Color(.98,.89,.65,.3*alpha))
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for mark in marks204:
  var segments: int=maxi(24,ceili(TAU*mark.radius/.12))
  for i in segments:
   var points: Array[Vector3]=[]
   for spec in [Vector2(0,-1),Vector2(1,-1),Vector2(1,1),Vector2(0,-1),Vector2(1,1),Vector2(0,1)]:
    var angle: float=TAU*(float(i)+spec.x)/segments
    var radius: float=mark.radius+spec.y*.013
    var at: Vector3=mark.at+Vector3(cos(angle),0.,sin(angle))*radius
    at.y=battle.floor_height(Vector2(at.x,at.z))+.035;points.append(at)
   var low := INF;var high := -INF
   for at in points: low=minf(low,at.y);high=maxf(high,at.y)
   # Discontinuous ledges should interrupt a ground marking, not grow a wall.
   if high-low>.20: clipped204+=1;continue
   for at in points:
    st.set_color(mark.color);st.set_normal(Vector3.UP);st.add_vertex(at);vertices204.append(at)
 ground204.visible=not vertices204.is_empty()
 ground204.mesh=st.commit() if ground204.visible else null
func _process(delta: float) -> void:
 super._process(delta);rebuild204()
func draw146() -> void:
 # Keep the notebook UI; plane coverage and sector markers are world meshes.
 # The old flight-count dots are redundant with the existing on-screen HUD.
 if not is_instance_valid(book146) or not book146.visible: return
 var base: Vector2=battle.camera.unproject_position(book146.position)
 for i in pages146.size():
  var offset := Vector2(-11+i*10,1.)
  if pages146[i].plane:
   art146.draw_colored_polygon(PackedVector2Array([base+offset+Vector2(-3,-3),base+offset+Vector2(5,0),base+offset+Vector2(-3,3),base+offset]),Color("756081"))
  else: art146.draw_circle(base+offset,2.,Color("756081"))
 if writing146:
  var phase := fmod(write_age146/.65*3.,1.);var edge := cos(phase*PI)*16.;var lift := sin(phase*PI)*5.
  art146.draw_colored_polygon(PackedVector2Array([base+Vector2(0,-12),base+Vector2(edge,-12-lift),base+Vector2(edge,11-lift),base+Vector2(0,11)]),Color("fff2cc"))
  for row in 3: art146.draw_line(base+Vector2(0,-6+row*5),base+Vector2(edge*.85,-6+row*5-lift),Color("9cb9c7"),1.)
