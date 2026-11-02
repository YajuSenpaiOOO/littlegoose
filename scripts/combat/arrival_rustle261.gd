extends Node3D
## Small shaded leaf flicks, not a magic spawn circle or a new sprite asset.
var camera261: Camera3D
var leaves261: Array[MeshInstance3D]=[]
func _ready() -> void:
 var mesh=SurfaceTool.new();mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 for point in [Vector3(0,.12,0),Vector3(.035,0,0),Vector3(0,-.12,0),Vector3(0,.12,0),Vector3(0,-.12,0),Vector3(-.035,0,0)]:mesh.add_vertex(point)
 mesh.generate_normals()
 var blade=mesh.commit()
 var ink=StandardMaterial3D.new();ink.albedo_color=Color("829d63");ink.roughness=1.;ink.metallic_specular=0.;ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 for i in 5:
  var leaf=MeshInstance3D.new();leaf.mesh=blade;leaf.material_override=ink;leaf.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(leaf);leaves261.append(leaf)
func sample261(t: float) -> void:
 var weight=sin(clampf(t,0.,1.)*PI)
 for i in leaves261.size():
  var angle=float(i)*2.4
  var leaf=leaves261[i]
  leaf.position=Vector3(cos(angle)*(.12+weight*.22),.12+weight*(.15+float(i%2)*.08),sin(angle)*(.12+weight*.16))
  leaf.basis=camera261.global_basis*Basis(Vector3.FORWARD,angle+sin(t*18.+i)*.3)
  leaf.scale=Vector3.ONE*maxf(.02,weight)
