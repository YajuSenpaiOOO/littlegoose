extends RefCounted
## Small physical cardstock flakes. No texture, collision, glow or shadow.
static func spawn(parent: Node3D, at: Vector3, normal: Vector3, broken: bool) -> Node3D:
 var root := Node3D.new()
 parent.add_child(root)
 root.global_position = at
 root.set_meta("paper_hit329", true)
 var colors := [Color(.94,.75,.53),Color(.88,.83,.67),Color(.55,.25,.30)]
 var flutter := Curve.new()
 for point in [Vector2(0.,1.),Vector2(.17,.22),Vector2(.34,.95),Vector2(.52,.3),Vector2(.7,.8),Vector2(1.,0.)]:
  flutter.add_point(point)
 for i in colors.size():
  var particles := CPUParticles3D.new()
  particles.amount = 6 if broken else 3
  particles.lifetime = 1.15
  particles.one_shot = true
  particles.explosiveness = 1.
  particles.randomness = .35
  particles.direction = Vector3(normal.x,maxf(.55,normal.y),normal.z).normalized()
  particles.spread = 55.
  particles.gravity = Vector3(0.,-2.4,0.)
  particles.initial_velocity_min = 1.2
  particles.initial_velocity_max = 3. if broken else 2.1
  particles.angle_min = -180.
  particles.angle_max = 180.
  particles.angular_velocity_min = -320.
  particles.angular_velocity_max = 320.
  particles.scale_amount_min = .7
  particles.scale_amount_max = 1.4
  particles.split_scale = true
  particles.scale_curve_y = flutter
  particles.color = colors[i]
  particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  var sheet := QuadMesh.new()
  sheet.size = Vector2(.07 if i == 2 else .11,.14)
  particles.mesh = sheet
  var ink := StandardMaterial3D.new()
  ink.vertex_color_use_as_albedo = true
  ink.cull_mode = BaseMaterial3D.CULL_DISABLED
  ink.roughness = 1.
  particles.material_override = ink
  root.add_child(particles)
  particles.emitting = true
 parent.get_tree().create_timer(1.4).timeout.connect(root.queue_free)
 return root
