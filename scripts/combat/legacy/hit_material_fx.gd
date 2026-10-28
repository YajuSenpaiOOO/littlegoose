extends Node2D
## Bounded, cosmetic world-space sugar fragments and tuantuan juice droplets.
const MAX_SUGAR := 96
const MAX_JUICE := 64
var sugar: Array[Dictionary] = []
var juice: Array[Dictionary] = []
var visual_rng := RandomNumberGenerator.new()
var shard: AtlasTexture
var droplet: AtlasTexture
var juice_layer: Node2D
var local_coordinates := false # 3D adapter: particles stay in the projected anchor's space.

static func renderer(parent: Node):
	var effect = parent.get_node_or_null("HitMaterialFX")
	if effect == null:
		effect = new()
		effect.name = "HitMaterialFX"
		parent.add_child(effect)
	return effect

static func break_sugar(parent: Node, at: Vector2, direction: Vector2, gain: float) -> void:
	var effect = renderer(parent)
	var forward := direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	for i in mini(4,MAX_SUGAR-effect.sugar.size()):
		var side := forward.orthogonal()*(-1 if i%2==0 else 1)
		effect.sugar.append({"at":at,"velocity":-forward*effect.visual_rng.randf_range(35,55)+side*effect.visual_rng.randf_range(25,45),
			"age":0.0,"life":0.28,"size":effect.visual_rng.randf_range(3.8,5.0)*gain,
			"angle":effect.visual_rng.randf_range(-PI,PI),"spin":effect.visual_rng.randf_range(-7,7)})
	effect.set_process(true)

static func splash_juice(parent: Node, at: Vector2, direction: Vector2, finishing: bool) -> void:
	var effect = renderer(parent)
	var forward := direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	var count := 3 if finishing else 2
	for i in mini(count,MAX_JUICE-effect.juice.size()):
		var scatter: Vector2 = forward.orthogonal()*effect.visual_rng.randf_range(-15,15)
		effect.juice.append({"at":at,"velocity":-forward*effect.visual_rng.randf_range(18,32)+scatter+Vector2(0,-30),
			"age":0.0,"life":0.34,"size":(3.8 if finishing else 2.8)+effect.visual_rng.randf_range(-0.3,0.3)})
	effect.set_process(true)

func _ready() -> void:
	visual_rng.randomize() # Never consume gameplay's random sequence.
	z_index = 24
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	shard = AtlasTexture.new()
	shard.atlas = preload("res://assets/perfect_dodge_v1/animated/a_starcut_parts_v1.png")
	# The old full 512px cell had mostly transparent padding: visible shards
	# ended up about one world pixel wide. Register the actual opaque shape.
	shard.region = Rect2(1209,158,144,208)
	shard.filter_clip = true
	droplet = AtlasTexture.new()
	droplet.atlas = preload("res://assets/slime_girl_v2/slime_water_drop_trial1.png")
	droplet.region = Rect2(390,296,563,614)
	droplet.filter_clip = true
	juice_layer = Node2D.new()
	var material := ShaderMaterial.new()
	material.shader = preload("res://scripts/art/tuantuan_juice.gdshader")
	juice_layer.material = material
	add_child(juice_layer)
	juice_layer.draw.connect(_draw_juice)
	set_process(false)

func _process(delta: float) -> void:
	for kind in 2:
		var collection: Array[Dictionary] = sugar if kind == 0 else juice
		for i in range(collection.size()-1,-1,-1):
			var particle: Dictionary = collection[i]
			particle.age += delta
			if particle.age >= particle.life:
				collection.remove_at(i)
				continue
			if kind == 1:
				particle.at += particle.velocity*delta+Vector2(0,0.5*150*delta*delta)
				particle.velocity += Vector2(0,150*delta)
			else:
				particle.at += particle.velocity*delta
				particle.velocity *= exp(-5*delta)
				particle.angle += particle.spin*delta
	queue_redraw()
	juice_layer.queue_redraw()
	if sugar.is_empty() and juice.is_empty():
		set_process(false)

func _draw() -> void:
	for particle in sugar:
		var k: float = particle.age/particle.life
		var size: float = particle.size*(1-0.4*k)
		draw_set_transform(particle.at if local_coordinates else to_local(particle.at),particle.angle)
		var extent := Vector2(size,size*208.0/144.0)
		draw_texture_rect(shard,Rect2(-extent*0.5,extent),false,Color(1,1,1,1-smoothstep(0.35,1,k)))
	draw_set_transform(Vector2.ZERO,0)

func _draw_juice() -> void:
	for particle in juice:
		var k: float = particle.age/particle.life
		var scale: float = particle.size/563.0
		juice_layer.draw_set_transform(particle.at if local_coordinates else to_local(particle.at),particle.velocity.angle()+PI*0.5)
		juice_layer.draw_texture_rect(droplet,Rect2(-Vector2(281.5,369)*scale,droplet.get_size()*scale),false,
			Color(1,1,1,1-smoothstep(0.6,1,k)))
	juice_layer.draw_set_transform(Vector2.ZERO,0)
