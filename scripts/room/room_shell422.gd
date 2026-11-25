extends "res://scripts/room/room_shell421.gd"

var partitions: Array[StaticBody3D]=[]
var timbers: Node3D

func build_shell() -> void:
 super.build_shell()
 dressing393.hide()
 garden393.hide()
 var house: Node3D=world.house
 timbers=Node3D.new()
 timbers.name="InteriorTimber422"
 add_child(timbers)
 var trim:=preload("res://scripts/room/timber_frame399.gd").new()
 timbers.add_child(trim)
 # Close the rear jamb bays and the spandrels without narrowing either arch.
 for side in [-1.,1.]:
  for z in [-2.285,1.865]:
   var span:=.55 if z<0. else .45
   var at:=Vector3(side*3.,1.39,z)
   house.block(timbers,at,Vector3(.21,2.78,span),house.plaster)
   partitions.append(collider(timbers,at,Vector3(.21,2.78,span)))
  var infill:=Node3D.new()
  infill.position=Vector3(side*3.,0,-.2)
  infill.rotation.y=PI*.5
  timbers.add_child(infill)
  var points:=PackedVector2Array([Vector2(-1.82,2.86),Vector2(1.82,2.86)])
  for i in range(24,-1,-1):
   var u:=lerpf(-1.82,1.82,i/24.)
   points.append(Vector2(u,2.34+.46*(1.-pow(u/1.82,2.))))
  for face in [-.106,.106]:
   house.polygon(infill,points,face,house.plaster)
  trim.block399(Vector3(side*3.,2.87,-.225),Vector3(.26,.17,4.65),"PartitionPlate422")
  trim.block399(Vector3(side*2.82,2.79,-2.92),Vector3(.17,.19,1.68),"WallPlate422")
  trim.block399(Vector3(side*2.76,1.72,-3.61),Vector3(.20,3.42,.18),"RearPost422")
  house.beam(timbers,Vector3(side*2.72,3.03,-3.59),Vector3(side*1.93,3.68,-3.59),.16,.19,house.wood)
 for z in [-3.58,-2.14]:
  trim.block399(Vector3(0,3.71,z),Vector3(5.93,.23,.28),"TransverseTie422")
  for side in [-1.,1.]:
   var rafter: Array[Vector2]=[]
   for i in 13:
    var x: float=side*3.*i/12.
    rafter.append(Vector2(x,house.roof_height(x,3.57,3.26,6.85)-.24))
   trim.beam399(rafter,.18,.25,z,"RearRafter422")
