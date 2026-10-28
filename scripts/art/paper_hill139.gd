extends "res://scripts/art/paper_hill136.gd"
var ramp_treads139 := 0
var closed_bases139 := 0
func _cylinder97(a: Vector3,b: Vector3,radius: float,material: Material,solid := false,parent: Node3D=null) -> MeshInstance3D:
 var p: Vector2=Vector2((a.x+b.x)*.5,(a.z+b.z)*.5)-Vector2(world.meadow.landmarks.grove)
 var exit := parent==null and maxf(a.y,b.y)<5. and HILL136.stair136(p).x<1.8
 var node := super._cylinder97(a,b,radius,material,solid and not exit,parent)
 if exit: node.hide()
 return node
func stair_piece139(p: Vector2) -> bool:
 var local: Vector2=PLAN99.to_stair99(p)
 return (absf(local.x-PLAN99.STAIR_X)<1.9 and local.y>PLAN99.STAIR_TOP-.5 and local.y<PLAN99.STAIR_FOOT+.5) or HILL136.stair136(p).x<1.9
func _prism99(poly: PackedVector2Array,at: Vector3,depth: float) -> MeshInstance3D:
 var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
 var is_stair := stair_piece139(p)
 var node := super._prism99(poly,at,maxf(depth,.8) if is_stair else depth)
 if is_stair:
  for child in node.get_children():
   if child is StaticBody3D: child.collision_layer=0;slab_bodies102.erase(child)
  for i in range(treads102.size()-1,-1,-1):
   if treads102[i].mesh==node: treads102.remove_at(i)
  ramp_treads139+=1
 return node
func quad139(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3) -> void:
 var normal := (b-a).cross(c-a).normalized()
 for v in [a,b,c,a,c,d]: st.set_normal(normal);st.add_vertex(v)
func base139(a: Vector2,b: Vector2,ha: float,hb: float,width: float) -> void:
 var crosswise := (b-a).normalized().orthogonal()*width*.5
 var g: Vector2=world.meadow.landmarks.grove
 a+=g;b+=g
 var top: Array[Vector3]=[];var bottom: Array[Vector3]=[]
 var bottom_y := minf(ha,hb)-.55
 for spec in [[a-crosswise,ha],[b-crosswise,hb],[b+crosswise,hb],[a+crosswise,ha]]:
  var point: Vector2=spec[0];top.append(Vector3(point.x,float(spec[1])-.035,point.y));bottom.append(Vector3(point.x,bottom_y,point.y))
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 quad139(st,top[0],top[1],top[2],top[3])
 quad139(st,bottom[3],bottom[2],bottom[1],bottom[0])
 for i in 4: quad139(st,top[i],bottom[i],bottom[(i+1)%4],top[(i+1)%4])
 var mesh := MeshInstance3D.new();mesh.name="ClosedStairFoundation139_%d"%closed_bases139;mesh.mesh=st.commit();mesh.material_override=stone97;add_child(mesh);closed_bases139+=1
func _ready() -> void:
 super._ready()
 # Solid closed support below the decorative steps covers the existing grass
 # cutout completely, including corners and the underside seen from below.
 base139(PLAN99.from_stair99(Vector2(PLAN99.STAIR_X,PLAN99.STAIR_FOOT+.14)),PLAN99.from_stair99(Vector2(PLAN99.STAIR_X,PLAN99.STAIR_TOP-.16)),2.1,PLAN99.DECK_Y,2.90)
 for i in 3: base139(HILL136.POINTS[i],HILL136.POINTS[i+1],HILL136.HEIGHTS[i],HILL136.HEIGHTS[i+1],2.55)
