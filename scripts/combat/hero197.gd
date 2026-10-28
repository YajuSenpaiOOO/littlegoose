extends "res://scripts/combat/hero192.gd"
var camera_facing197 := true
func set_camera_facing197(on: bool) -> void:
 camera_facing197=on;render_pose()
func render_pose() -> void:
 super.render_pose()
 if not is_instance_valid(visual): return
 # Align the visual plane only. Compose the authored walking roll in that
 # plane; enabling Sprite3D full billboard would overwrite that animation.
 if camera_facing197 and is_instance_valid(battle) and is_instance_valid(battle.camera):
  var roll := visual.rotation.z
  var animated_scale := visual.scale
  var parent_basis: Basis=visual.get_parent().global_basis.orthonormalized()
  var plane: Basis=parent_basis.inverse()*battle.camera.global_basis.orthonormalized()
  visual.basis=plane*Basis(Vector3.BACK,roll)*Basis.from_scale(animated_scale)
 # 192 tilts the lighting normal on an upright card. The camera-facing
 # geometry already supplies that tilt, so do not apply it a second time.
 if receiver192!=null: receiver192.normal_enabled=not camera_facing197
