extends "res://scripts/combat/paper_scatter152.gd"
var book_follow162=preload("res://scripts/combat/float_follow162.gd").new()
var float_age162 := 0.
func _ready() -> void:
 super._ready();process_priority=80
 book146.physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
func reset146() -> void:
 super.reset146();book_follow162.reset();float_age162=0.
func _process(delta: float) -> void:
 if not battle.combat_paused: float_age162+=delta
 super._process(delta)
 if not book146.visible: book_follow162.reset()
func update_book_pose146(delta: float) -> void:
 var owner: Node3D=battle.goose if writing146 else battle.hero
 var base := owner.get_global_transform_interpolated().origin
 var target := base+(Vector3(.32,.48,-.08) if writing146 else Vector3(.62,.95,.12))
 target+=Vector3(sin(float_age162*1.3)*.035,sin(float_age162*2.1)*.055,cos(float_age162*1.6)*.025)
 book146.global_position=book_follow162.advance(target,0. if battle.combat_paused else delta,14. if writing146 else 11.)
 book146.basis=battle.camera.global_basis
 var lean: float=clampf(book_follow162.velocity.dot(battle.camera.global_basis.x)*-.035,-.12,.12)
 book146.rotate_object_local(Vector3.FORWARD,lean+sin(float_age162*(7.2 if writing146 else 1.8))*(.045 if writing146 else .035))
