extends "res://scripts/art/rail_station85.gd"

func _solid86(at: Vector3,size: Vector3,label: String) -> void:
	var body := StaticBody3D.new();body.name=label;body.collision_layer=1;body.collision_mask=0
	var collision := CollisionShape3D.new();var box := BoxShape3D.new();box.size=size
	collision.shape=box;collision.position=at;body.add_child(collision);add_child(body)

func _build_side_steps75() -> void:
	super._build_side_steps75()
	var base: float=world.meadow.LOW72-.10
	var top: float=world.meadow.MAIN72+.055
	# A closed wall and shoulder connect its top to the upper terrace. The old
	# vertical-only shell could be entered from above as the terrain sloped down.
	_solid86(Vector3(8.3,(base+top)*.5,-47.45),Vector3(7.,top-base,.70),"SolidBackWall86")
	_solid86(Vector3(8.3,top-.055,-47.90),Vector3(7.,.11,.4),"UpperShoulder86")
