extends "res://scripts/art/paper_fire303.gd"
func width_axis303(_start: Vector3,_forward: Vector3,_camera_at: Vector3) -> Vector3:return Vector3.UP
func show303(start: Vector3,end: Vector3,camera_at: Vector3,reveal: float,clock: float) -> void:
 end.y=start.y
 super.show303(start,end,camera_at,reveal,clock)
