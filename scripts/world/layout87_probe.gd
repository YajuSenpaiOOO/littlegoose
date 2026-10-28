extends SceneTree
func _initialize() -> void:
 var s=preload("res://scripts/world/world_surface85.gd").new()
 print("GROVE87 ",s.landmarks.grove," hub=",s.landmarks.junction)
 var g: Vector2=s.landmarks.grove
 for dx in [-26.,-20.,-12.,0.,12.,24.]:
  var x=g.x+dx
  print("EDGE87 ",x," ",s.upper_front73(x))
 quit()
