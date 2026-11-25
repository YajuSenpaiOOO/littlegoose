extends "res://scripts/room/home_yard418.gd"

func window413(at: Vector3,width: float,height: float) -> void:
 # Keep glazing subordinate to the timber bays, including the attic.
 super.window413(at,width*.76,height*.82)

func mass415(center: float,width: float,eave: float,peak: float,front: float,back: float) -> void:
 super.mass415(center,width,eave,lerpf(eave,peak,.88),front,back)

func build_house404(room: Node3D) -> void:
 super.build_house404(room)
 # The desk window opens through the central exterior rear wall.
 for panel in permanent418.get_children():
  if panel is MeshInstance3D and absf(panel.position.x)<.01 and panel.position.z< -4.7:
   panel.hide()
 for data in [[Vector3(-2.45,1.95,-4.76),Vector3(2.1,3.9,.20)], [Vector3(1.95,1.95,-4.76),Vector3(3.1,3.9,.20)], [Vector3(-.5,.55,-4.76),Vector3(1.8,1.1,.20)], [Vector3(-.5,3.45,-4.76),Vector3(1.8,.9,.20)]]:
  var panel:=BoxMesh.new();panel.size=data[1]
  kit.shape(permanent418,panel,data[0],plaster413)
 for side in [-1.,1.]:
  # Unbroken main posts and braces read as load-bearing members.
  box413(Vector3(side*3.30,2.10,3.56),Vector3(.44,3.25,.44),wood413)
  for x in [side*3.65,side*6.30]:
   var brace: Array[Vector2]=[]
   for i in 17:
    var t:=float(i)/16.
    brace.append(Vector2(x+(-side if absf(x)>5. else side)*.62*t*t,2.65+.69*t))
   curve414(brace,.18,.28,2.40,wood413)
  box413(Vector3(side*5.,.78,2.25),Vector3(3.0,.16,.30),wood413)
 # Rear structural lines follow the actual three volumes and remain indoors.
 for x in [-6.35,-3.45,3.45,6.35]:
  box413(Vector3(x,1.75,-4.60),Vector3(.24,3.5,.24),wood413,permanent418)
 for side in [-1.,1.]:
  box413(Vector3(side*5.,3.35,-4.59),Vector3(3.,.22,.26),wood413,permanent418)
