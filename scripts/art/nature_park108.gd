extends "res://scripts/art/nature_park102.gd"
var log108: MeshInstance3D
var log_material108: ShaderMaterial
func _cylinder97(a: Vector3,b: Vector3,radius: float,material: Material,solid := false,parent: Node3D=null) -> MeshInstance3D:
 var node := super._cylinder97(a,b,radius,material,solid,parent)
 if material==bark97 and radius>.4 and a.distance_to(b)>4.:
  log108=node;node.name="PaintedIrregularLog108"
 return node
func _ready() -> void:
 super._ready()
 # The inherited builder adjusts the CylinderMesh before adding the stumps.
 # Replace only after it completes, keeping its actual collision body intact.
 var original: CylinderMesh=log108.mesh
 log108.mesh=_log_mesh108(original.height,original.bottom_radius)
 log_material108=ShaderMaterial.new();log_material108.shader=preload("res://scripts/art/log108.gdshader")
 log_material108.set_shader_parameter("paint108",load("res://assets/woodland108/painted_log108.png"))
 world.porch49.shade_material(log_material108);log108.material_override=log_material108
func ring108(row: int,segment: int,length: float,radius: float) -> Vector3:
 var t := float(row)/5.;var angle := TAU*float(segment%14)/14.
 var r := radius*lerpf(1.,.80,t)*(1.+.055*sin(angle*3.+t*1.8)+.025*cos(angle*5.-t))
 return Vector3(cos(angle)*r+.055*sin(t*PI*1.4),length*(t-.5),sin(angle)*r+.035*sin(t*PI))
func _log_mesh108(length: float,radius: float) -> ArrayMesh:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for row in 5:
  for segment in 14:
   for corner in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
    var r: int=row+corner.y;var s: int=segment+corner.x;var angle := TAU*float(s)/14.
    st.set_normal(Vector3(cos(angle),.025,sin(angle)).normalized());st.set_uv(Vector2(float(s)/14.,float(r)/5.))
    st.add_vertex(ring108(r,s,length,radius))
 for row in [0,5]:
  var normal := Vector3.DOWN if row==0 else Vector3.UP
  var centre := Vector3(.055*sin(float(row)/5.*PI*1.4),length*(float(row)/5.-.5),.035*sin(float(row)/5.*PI))
  var cap_radius := radius*(1. if row==0 else .8)
  for segment in 14:
   var points := [centre,ring108(row,segment+(0 if row==5 else 1),length,radius),ring108(row,segment+(1 if row==5 else 0),length,radius)]
   for p in points:
    st.set_normal(normal);st.set_uv(Vector2(.5,.5)+Vector2(p.x-centre.x,p.z-centre.z)/(cap_radius*2.18));st.add_vertex(p)
 return st.commit()
