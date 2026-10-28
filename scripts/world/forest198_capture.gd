extends "res://scripts/world/forest192_capture.gd"
func world_script192() -> Script: return preload("res://scripts/world/woodland_world198.gd")
func result_prefix192() -> String: return "forest198"
func extra_checks192() -> void:
 verify(sample.hero.get_script()==preload("res://scripts/combat/hero192.gd") and not sample.hero.has_method("set_camera_facing197"),"working baseline uses the actual upright 192 controller instead of a toggle on 197")
 var restored: bool=not sample.upright196
 for record in sample.angle_cards196: restored=restored and record.node.billboard==record.billboard and record.node.rotation.is_equal_approx(record.rotation)
 verify(restored,"props retain their original display orientations outside the 196 experiment")
