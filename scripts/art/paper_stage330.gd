extends "res://scripts/art/paper_stage327.gd"

const HEAVY330 := preload("res://assets/paper_stage330/heavy.png")
const MORTAR330 := preload("res://assets/paper_stage330/mortar.png")

func projectile330(heavy: bool, at: Vector3) -> Sprite3D:
 var texture: Texture2D = HEAVY330 if heavy else MORTAR330
 # Center anchors: projectile position is its volume center, not a ground foot.
 var sprite := card298(texture,{"span":[1080. if heavy else 670.],"foot":[618.,642.] if heavy else [609.5,637.]},1.05 if heavy else .78,self)
 sprite.rotation.x = deg_to_rad(-25.)
 sprite.material_override.albedo_color = Color(.92,.92,.92)
 sprite.global_position = at
 return sprite

func make_flight327(at: Vector3, meteor: bool) -> Sprite3D:
 return super.make_flight327(at,true) if meteor else projectile330(false,at)

func flight_position330(flight: Dictionary, t: float) -> Vector3:
 var at: Vector3 = Vector3(flight.from).lerp(flight.ground,t)
 if not flight.meteor: at.y += sin(PI*t)*2.8
 return at

func pose_mortar330(flight: Dictionary, t: float) -> void:
 var previous := flight_position330(flight,maxf(0.,t-.005))
 var next := flight_position330(flight,minf(1.,t+.005))
 var camera: Camera3D = battle.camera
 var delta_screen := camera.unproject_position(next)-camera.unproject_position(previous)
 # The painted nose points toward screen-down. Rotate in the camera plane.
 flight.sprite.rotation.z = -delta_screen.angle()+PI*.5

func muzzle330(source: int) -> Vector3:
 var cannon := cannons326[source]
 # Mouth center (625,210) in the intact 887px atlas cell; same display transform.
 return cannon.to_global(Vector3((625.-454.)*cannon.pixel_size,(825.-210.)*cannon.pixel_size,.12))