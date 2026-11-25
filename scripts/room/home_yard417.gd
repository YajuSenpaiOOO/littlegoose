extends "res://scripts/room/home_yard415.gd"
var ridge_directions417: Array=[]
func build_house404(room: Node3D) -> void:
 super.build_house404(room)
 facade403.free();facade403=Node3D.new();facade403.name="SemiOpenCottageA417";add_child(facade403);glow404.clear();windows414.clear();masses415=0
 # Main hall and its N-S ridge are a coherent central volume.
 for side in [-1.,1.]:box413(Vector3(side*2.28,1.95,3.0),Vector3(2.42,3.9,.22),plaster413)
 var top:=SurfaceTool.new();top.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 32:
  var a: float=-1.075+2.15*i/32.;var b: float=-1.075+2.15*(i+1)/32.
  quad404(top,[Vector3(a,1.82+sqrt(maxf(0.,1.075*1.075-a*a)),3.12),Vector3(b,1.82+sqrt(maxf(0.,1.075*1.075-b*b)),3.12),Vector3(b,3.9,3.12),Vector3(a,3.9,3.12)])
 top.generate_normals();kit.shape(facade403,top.commit(),Vector3.ZERO,plaster413)
 mass415(0,7.0,3.9,6.35,3.15,-4.9);ridge_directions417.append(Vector3.BACK)
 for side in [-1.,1.]:
  box413(Vector3(side*5.0,1.75,1.95),Vector3(3.05,3.5,.22),plaster413)
  box413(Vector3(side*6.51,1.75,-.95),Vector3(.20,3.5,5.9),plaster413)
  var group:=Node3D.new();facade403.add_child(group)
  var shell: Node3D=facade403;facade403=group
  # Build around its local origin, then rotate the entire roof module 90 degrees.
  mass415(0,6.05,3.5,4.58,1.72,-1.72)
  facade403=shell;group.position=Vector3(side*5.0,0,-.95);group.rotation.y=PI*.5
  ridge_directions417.append(Vector3.RIGHT)
  for x in [side*3.52,side*6.36]:box413(Vector3(x,1.75,2.12),Vector3(.25,3.5,.32),wood413)
  box413(Vector3(side*5.,3.5,2.16),Vector3(3.10,.22,.38),wood413)
  window413(Vector3(side*5.0,1.95,2.16),1.65,1.75)
 box413(Vector3(0,1.95,-4.76),Vector3(13.1,3.9,.20),plaster413)
 box413(Vector3(0,3.87,3.34),Vector3(7.05,.27,.46),wood413)
 window413(Vector3(0,4.95,3.24),1.78,1.60)
 build_arch413();door_hood414();foundation414()
 for node in facade403.get_children():
  if node is Node3D and absf(node.position.x)>3.4 and node.position.y<1.12 and node.position.z>3.2:node.position.z-=1.02
 for body in get_children():
  if body is StaticBody3D and absf(body.position.x)>3.4 and body.position.y<1.12 and body.position.z>3.2:body.position.z-=1.02
 print("HOME417_ROOF_AXES ",ridge_directions417)
func build403(room: Node3D) -> void:
 super.build403(room)
 for side in [-1.,1.]:
  var at: Vector3=(Vector3(side*4.6,1.6,1.57)-position)/scale
  room.collider(self,at,Vector3(2.8,3.2,.18)/scale)
