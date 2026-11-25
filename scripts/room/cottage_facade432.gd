extends "res://scripts/room/cottage430.gd"

const TIMBER = preload("res://scripts/room/timber_frame399.gd")
const PORTAL_TINTS := ["cfc0a4","baae9a","cec5b3","b9af9e","c5b7a6"]
var portal_inks: Array[StandardMaterial3D]=[]
var brace_ink: StandardMaterial3D
var join_ink: StandardMaterial3D

func brace(start: Vector3,side: float,length: float,rise: float) -> void:
 if start.z<FRONT:
  super.brace(start,side,length,rise)
  return
 if brace_ink==null:
  brace_ink=wood.duplicate() as StandardMaterial3D
  brace_ink.albedo_color=Color("c09876")
  join_ink=wood.duplicate() as StandardMaterial3D
  join_ink.albedo_color=Color("ad8666")
 var frame:=TIMBER.new()
 frame.name="PorchJoinery"
 frame.position.z=start.z-.09
 shell.add_child(frame)
 var path: Array[Vector2]=[]
 for i in 13:
  var t:=float(i)/12.
  path.append(Vector2(start.x+side*length*t*t,start.y+rise*t))
 var curved:=frame.beam399(path,.25,.23,0.,"PorchKneeBrace")
 curved.material_override=brace_ink
 block(frame,Vector3(start.x,start.y+.035,.022),Vector3(.31,.21,.25),join_ink)
 block(frame,Vector3(start.x-side*.06,start.y+.033,.155),Vector3(.09,.09,.039),brace_ink).rotation.z=.16

func portal_stone(points: PackedVector2Array,index: int) -> void:
 if portal_inks.is_empty():
  for tint in PORTAL_TINTS:
   var ink:=stone.duplicate() as StandardMaterial3D
   ink.albedo_color=Color(tint)
   portal_inks.append(ink)
 super.portal_stone(points,index)
 jambs.back().material_override=portal_inks[posmod(index,portal_inks.size())]

func portal_face(st: SurfaceTool,vertices: Array,center: Vector2) -> void:
 # Lower the raised faces toward the existing bevel rim; preserve the arch opening.
 for i in vertices.size():
  var point: Vector3=vertices[i]
  if point.z>FRONT+.39:point.z=FRONT+.368
  vertices[i]=point
 super.portal_face(st,vertices,center)

func flower_card(parent: Node3D,source: Texture2D,at: Vector3,height: float,ground: bool) -> void:
 var added:=parent.get_child_count()
 super.flower_card(parent,source,at,height,ground)
 if parent.position.y<3. or added==parent.get_child_count():return
 var box_art:=parent.get_child(added) as Sprite3D
 box_art.scale=Vector3(1.06,1.18,1.)
 box_art.position.y-=.025

func build_planting() -> void:
 super.build_planting()
 var drape:=shell.get_node("PaintedIvy429") as Node3D
 drape.position=Vector3(1.06,2.33,FRONT+.43)
 drape.get_child(0).scale=Vector3(1.55,1.08,1.)

func build_entry_planter(_side: float) -> void:
 # CottageDecor432 places the new entry props against the world terrain.
 pass
