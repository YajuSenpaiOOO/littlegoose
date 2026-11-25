extends "res://scripts/room/room_shell417.gd"
var retired419: Array[Node3D]=[]
func build_furniture() -> void:
 super.build_furniture()
 # Retire the rectangular stage walls; exterior shell owns the wall boundary.
 for node in walls392+caps392+low392:
  node.hide();retired419.append(node)
 for saved in shell_state402:
  var node: Node3D=saved.node
  if saved.has("mesh"):
   var size: Vector3=saved.mesh.size
   if node.position.y>0 and (absf(node.position.x)>5.4 or node.position.z< -3.7):
    node.hide();retired419.append(node)
  elif absf(node.position.x)>5.4 and node.position.y>1.:
   node.position.x=signf(node.position.x)*5.98
   node.position.z=-1.34
   node.get_child(0).shape=node.get_child(0).shape.duplicate()
   node.get_child(0).shape.size.z=6.2
 # Interior panels sit against the same rear wall, with the retained desk window.
 for side in [-1.,1.]:
  box(self,Vector3(side*4.42,1.50,-4.22),Vector3(2.80,3.0,.12),"dfc8a4")
  box(self,Vector3(side*5.89,1.50,-1.30),Vector3(.12,3.0,5.95),"dfc8a4")
  box(self,Vector3(side*4.45,3.05,-4.12),Vector3(2.9,.18,.20),"795337")
