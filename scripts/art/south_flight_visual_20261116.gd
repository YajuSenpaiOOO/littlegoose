extends "res://scripts/combat/flight_visual383.gd"
# Preview-only extension: preserves the real wing rig/material/union shadow.
var poses: Array[Texture2D] = []
var pose_state := preload("res://scripts/art/south_pose_hold_20261116.gd").new()
func _ready() -> void:
 super._ready()
 var source := ImageTexture.create_from_image(Image.load_from_file("res://art/concepts/black_goose_south_attack_20261116/bodies-no-wings.png"))
 for i in 2: poses.append(atlas381(source, Rect2(i*512, 0, 512, 1024)))
func advance_pose(dt: float, trigger: bool, rate: float, beam: bool, shot: bool, preparing: bool) -> void:
 pose_state.advance(dt, trigger, rate, beam, shot, preparing)
 super._process(dt)
 var active: bool = pose_state.phase != "idle"
 body379.texture = poses[1 if pose_state.phase == "release" else 0] if active else front_body381
 body379.pixel_size = 1.44/767.0 if active else 1.44/860.0
 body379.offset = Vector2(0, 887-512) if active else Vector2(-25, 423)
 body379.material_override.albedo_texture = body379.texture.atlas
 # Northward recoil in actual world space; no shrinking the head on release.
 position.z -= pose_state.kick
 update_shadow380()
func hand_position() -> Vector3:
 # Same body-source projection and actual bob/recoil as the visible palm.
 var p := Vector2(178, 576) if pose_state.phase == "release" else Vector2(224, 546)
 return body379.to_global(Vector3((p.x-256)*body379.pixel_size, (887-p.y)*body379.pixel_size, .025))
