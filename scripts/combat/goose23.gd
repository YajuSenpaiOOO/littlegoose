extends Node3D
## Old relative-offset spring on a 3D floor: translating the hero creates no follow lag.
var battle: Node3D
var visual: Sprite3D
var shadow: MeshInstance3D
var textures: Array[Texture2D] = []
var offset_xz := Vector2(.6,0)
var spring_velocity := Vector2.ZERO
var age := 0.

func _ready() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	for file in ["hover_gentle_v1","flap_mid_v1","flap_down_v1"]:
		textures.append(load("res://assets/black_goose_v2/"+file+".png"))
	visual = Sprite3D.new()
	visual.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	visual.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visual.pixel_size = .014788189987163029/24.
	visual.texture = textures[0]
	visual.offset = Vector2(visual.texture.get_width()*.5-671.5,1043.-visual.texture.get_height()*.5)
	add_child(visual)
	shadow = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(.55,.36)
	shadow.mesh = plane
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/foot_contact16.gdshader")
	shadow.material_override = material
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(shadow)

func update_follow(delta: float,target: Vector3,snap := false) -> void:
	if not battle.combat_paused: age += delta
	var delta_xz := Vector2(target.x-battle.hero.position.x,target.z-battle.hero.position.z)
	if not target.is_finite() or delta_xz.length_squared()<.001: delta_xz = Vector2.RIGHT
	var wanted := delta_xz.normalized()*clampf(delta_xz.length(),.45,1.05)
	if snap:
		offset_xz = wanted
		spring_velocity = Vector2.ZERO
	elif not battle.combat_paused:
		spring_velocity += (wanted-offset_xz)*26.*delta
		spring_velocity -= spring_velocity*6.5*delta
		offset_xz += spring_velocity*delta
		offset_xz = offset_xz.limit_length(1.35)
	position = battle.hero.position+Vector3(offset_xz.x,.43,offset_xz.y)
	_update_follow_visual(target,snap)

func _update_follow_visual(target: Vector3,snap := false) -> void:
	visual.texture = textures[[0,1,2,1][int(age/.12)%4]]
	visual.position.y = sin(age*TAU/.48)*.025
	visual.flip_h = target.x>position.x
	# The silhouette replaces this ellipse; do not solve invisible legacy terrain.
	if shadow.visible or not bool(battle.get("combat_budget105")):
		var at := Vector2(position.x,position.z)
		shadow.global_position = Vector3(at.x,battle.meadow.walk_height(at,battle.terrain_enabled)+.027,at.y)
		var normal: Vector3 = battle.meadow.normal_at(at.x,at.y,battle.terrain_enabled)
		shadow.rotation = Vector3(atan2(-normal.z,normal.y),0,atan2(normal.x,normal.y))
	if snap: reset_physics_interpolation()

func muzzle() -> Vector3:
	return global_position+Vector3(.108 if visual.flip_h else -.108,.416+visual.position.y,0)

func recoil(direction: Vector3) -> void:
	spring_velocity -= Vector2(direction.x,direction.z).normalized()*battle.goose_recoil_strength()
