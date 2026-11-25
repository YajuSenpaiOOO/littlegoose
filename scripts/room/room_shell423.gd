extends "res://scripts/room/room_shell422.gd"

func build_shell() -> void:
 super.build_shell()
 var house: Node3D=world.house
 var trim:=preload("res://scripts/room/timber_frame399.gd").new()
 timbers.add_child(trim)
 # A sweeping tie and timber cheeks close the edge of the overhead cut.
 var arch: Array[Vector2]=[]
 for i in 33:
  var x:=lerpf(-2.91,2.91,i/32.)
  arch.append(Vector2(x,3.34+.65*(1.-pow(x/2.91,2.))))
 trim.beam399(arch,.207,.28,-1.17,"CurvedLintel423")
 for side in [-1.,1.]:
  var rafter: Array[Vector2]=[]
  for i in 15:
   var x: float=side*3.29*i/14.
   var y: float=house.roof_height(x,3.57,3.26,6.85)-.25
   rafter.append(Vector2(x,y))
  trim.beam399(rafter,.17,.22,-1.14,"LiningRafter423")
  trim.block399(Vector3(side*2.80,3.03,-2.11),Vector3(.205,.75,.21),"BracketPost423")
  var wing_y: float=house.roof_height(.595,2.69,2.85,4.15)-.24
  trim.block399(Vector3(side*4.58,wing_y,.34),Vector3(3.18,.18,.23),"WingRoofCutTrim423")
  for x in [side*3.25,side*5.9]:
   house.beam(timbers,Vector3(x,2.80,-.24),Vector3(x,wing_y,.34),.13,.15,house.wood)
