extends "res://scripts/combat/tuantuan_rest265.gd"
func _ready() -> void:
 super._ready();sleep265=preload("res://assets/tuantuan_rest266/sleep.png")
 layout265=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_rest266/layout.json"))["sleep.png"]
func rest265(sleeping: bool) -> void:
 super.rest265(sleeping)
 collision_layer=2|16
 var foot=get_child(0) as CollisionShape3D;var shape=CylinderShape3D.new();shape.radius=1.15;shape.height=1.1;foot.shape=shape;foot.position.y=.22+.55
func _process(delta: float) -> void:
 super._process(delta)
 if resting265 and (sleeping265 or wake_left265>.45):
  var b: Array=layout265.alpha_bbox;visual.pixel_size=3.0/float(b[2]-b[0]);visual.position.y=.22
 elif resting265:visual.position.y=.22
