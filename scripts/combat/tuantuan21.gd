extends CharacterBody3D
## Ordinary tuantuan: old pose assets and 0.5s hops on native 3D ground.
var battle: Node3D
var poses: Dictionary
var textures: Dictionary
var visual: Sprite3D
var hit_area: Area3D
var shadow: MeshInstance3D
var health_fill: MeshInstance3D
var hp := 12.
var dead := false
var age := 0.
var rest := .3
var hop_clock := 0.
var hopping := false
var hop_direction := Vector2.ZERO
var impulse := Vector2.ZERO
var flash := 0.
var health_time := 0.
var corpse_time := 0.
var route := PackedVector2Array()
var path_clock := 0.
var home := Vector2.ZERO
var active_ai := true
var hit_count := 0

func _ready() -> void:
	collision_layer = 16
	collision_mask = 1|2|16
	floor_snap_length = .45
	floor_max_angle = deg_to_rad(48)
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	var shape := CapsuleShape3D.new()
	shape.radius = .35
	shape.height = .8
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position.y = .4
	add_child(collider)
	hit_area = Area3D.new()
	hit_area.collision_layer = 8
	hit_area.collision_mask = 0
	hit_area.set_meta("enemy",self)
	var hit_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = .57
	hit_shape.shape = sphere
	hit_area.add_child(hit_shape)
	add_child(hit_area)
	visual = Sprite3D.new()
	visual.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	visual.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(visual)
	shadow = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(1.05,.72)
	shadow.mesh = plane
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/foot_contact16.gdshader")
	shadow.material_override = material
	shadow.position.y = .025
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(shadow)
	health_fill = MeshInstance3D.new()
	var bar := QuadMesh.new()
	bar.size = Vector2(.9,.075)
	health_fill.mesh = bar
	var health_material := StandardMaterial3D.new()
	health_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	health_material.albedo_color = Color("eaca82")
	health_fill.material_override = health_material
	health_fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	health_fill.rotation_degrees.x = -25
	add_child(health_fill)
	_pose("idle",0.)

func _pose(key: String,lift: float) -> void:
	var pose: Dictionary = poses[key]
	visual.texture = textures[key]
	visual.pixel_size = float(pose.scale)/24.
	visual.offset = Vector2(visual.texture.get_width()*.5-float(pose.foot[0]),float(pose.foot[1])-visual.texture.get_height()*.5)
	visual.position.y = lift
	visual.modulate = Color(1.5,1.25,1.2) if flash>0. else Color.WHITE
	hit_area.position.y = .58+lift
	health_fill.position = Vector3(-.45*(1.-hp/12.),1.55+lift,0)
	health_fill.scale.x = maxf(.001,hp/12.)
	health_fill.visible = health_time>0. and not dead
	shadow.scale = Vector3.ONE*(1.-lift*.35)
	# The silhouette replaces this ellipse; do not solve invisible legacy terrain.
	if shadow.visible or not bool(battle.get("combat_budget105")):
		var normal: Vector3 = battle.meadow.normal_at(position.x,position.z,true)
		shadow.rotation = Vector3(atan2(-normal.z,normal.y),0,atan2(normal.x,normal.y))

func receive_hit(damage: float,direction: Vector3) -> void:
	if dead: return
	hp = maxf(0.,hp-damage)
	hit_count += 1
	flash = .13
	health_time = 1.5
	impulse += Vector2(direction.x,direction.z).normalized()*4.2
	if hp<=0.:
		dead = true
		hopping = false
		hit_area.set_deferred("collision_layer",0)
		set_deferred("collision_layer",0)
		battle.enemy_defeated(self)
	_pose("defeated" if dead else "hit",0.)

func _physics_process(delta: float) -> void:
	if battle.combat_paused: return
	age += delta
	flash = maxf(0.,flash-delta)
	health_time = maxf(0.,health_time-delta)
	var at := Vector2(position.x,position.z)
	if dead:
		corpse_time += delta
		_pose("defeated",0.)
		visual.transparency = smoothstep(.9,1.5,corpse_time)
		if corpse_time>1.5: queue_free()
		return
	var player_at := Vector2(battle.hero.position.x,battle.hero.position.z)
	var target_at := player_at
	var engaged: bool = active_ai and battle.player_hp>0. and target_at.distance_to(home)<23.
	if not engaged: target_at = home
	path_clock -= delta
	if path_clock<=0.:
		route = battle.navigation.path(at,target_at)
		path_clock = .4
	while route.size()>1 and at.distance_to(route[0])<.65: route.remove_at(0)
	if not hopping:
		rest -= delta
		if rest<=0. and active_ai and (engaged or at.distance_to(home)>1.):
			hop_direction = (route[0]-at).normalized() if not route.is_empty() else Vector2.ZERO
			var separation := Vector2.ZERO
			for other in battle.enemies:
				if not is_instance_valid(other) or other==self or other.dead: continue
				var diff := at-Vector2(other.position.x,other.position.z)
				if diff.length_squared()<1.8 and diff.length_squared()>.001: separation += diff.normalized()*.45
			hop_direction = (hop_direction+separation).normalized()
			hopping = true
			hop_clock = 0.
	var lift := 0.
	var pose := "idle"
	var motion := Vector2.ZERO
	if hopping:
		hop_clock += delta
		var t := clampf(hop_clock/.5,0.,1.)
		lift = sin(t*PI)*.38
		motion = hop_direction*3.75
		pose = "airborne"
		if t>=1.:
			hopping = false
			rest = .19
			pose = "landing"
	else:
		pose = "anticipation" if rest<.10 else "landing" if rest>.12 and age>.4 else "idle"
	velocity.x = motion.x+impulse.x
	velocity.z = motion.y+impulse.y
	impulse = impulse.move_toward(Vector2.ZERO,delta*15.)
	velocity.y = -.3 if is_on_floor() else velocity.y-20.*delta
	move_and_slide()
	_pose("hit" if flash>0. else pose,lift)
	if battle.player_hp>0. and Vector2(position.x,position.z).distance_to(player_at)<.88:
		battle.hurt_player(10.,Vector2(position.x,position.z))
