extends Node2D
## Tree transforms are the source of truth; airborne leaves sort at their landing point.
var sources: Array[Dictionary] = []
var world: Node2D
var active := true
var timers: Array[float] = []
var flying: Array[Leaf] = []
var settled: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
const COLORS := [Color("b2c963"),Color("8fab4a"),Color("d2ce75")]

class Leaf extends Node2D:
	var height := 0.0
	var start_height := 0.0
	var age := 0.0
	var duration := 7.0
	var phase := 0.0
	var drift := 0.0
	var landing := Vector2.ZERO
	var tint := Color.WHITE
	func _draw() -> void:
		draw_set_transform(Vector2(0,-height).round(),sin(age*2+phase)*0.5)
		draw_colored_polygon(PackedVector2Array([Vector2(-2,0),Vector2(0,-1),Vector2(2,0),Vector2(0,1)]),tint)

func _ready() -> void:
	rng.seed = 14026
	for i in sources.size():
		timers.append(rng.randf_range(0.5,8.0))

func _spawn(source: Dictionary) -> Leaf:
	var node: Node2D = source.node
	var sprite: Sprite2D = source.visual
	var crown: Rect2 = source.crown
	var pixel := crown.position+Vector2(rng.randf_range(4,crown.size.x-4),rng.randf_range(4,crown.size.y-4))
	for attempt in 16:
		if source.image.get_pixelv(Vector2i(pixel)).a>0.5: break
		pixel = crown.position+Vector2(rng.randf_range(4,crown.size.x-4),rng.randf_range(4,crown.size.y-4))
	if sprite.centered: pixel -= sprite.texture.get_size()*0.5
	var start := sprite.to_global(pixel)
	var leaf := Leaf.new()
	leaf.name = "FallingTreeLeaf"
	leaf.landing = Vector2(start.x,node.global_position.y+rng.randf_range(4,16))
	leaf.position = leaf.landing
	leaf.start_height = maxf(8,leaf.landing.y-start.y)
	leaf.height = leaf.start_height
	leaf.phase = rng.randf_range(0,TAU)
	leaf.duration = rng.randf_range(6,9)
	leaf.drift = rng.randf_range(3,9)
	leaf.tint = COLORS[rng.randi_range(0,COLORS.size()-1)]
	world.add_child(leaf)
	flying.append(leaf)
	return leaf

func _process(delta: float) -> void:
	if not active: return
	for i in sources.size():
		timers[i] -= delta
		if timers[i]<=0:
			_spawn(sources[i])
			timers[i] = rng.randf_range(9,16)
	for i in range(flying.size()-1,-1,-1):
		var leaf := flying[i]
		leaf.age += delta
		var progress := minf(1,leaf.age/leaf.duration)
		leaf.height = leaf.start_height*(1-progress)
		leaf.position = leaf.landing+Vector2(sin(leaf.age*1.6+leaf.phase)*leaf.drift,0)
		leaf.queue_redraw()
		if progress>=1:
			settled.append({"position":to_local(leaf.global_position),"tint":leaf.tint,"life":7.0})
			leaf.queue_free()
			flying.remove_at(i)
	for i in range(settled.size()-1,-1,-1):
		settled[i].life -= delta
		if settled[i].life<=0: settled.remove_at(i)
	queue_redraw()

func _draw() -> void:
	for leaf: Dictionary in settled:
		var color: Color = leaf.tint
		color.a = minf(0.75,leaf.life/2.0)
		var at: Vector2 = leaf.position.round()
		draw_colored_polygon(PackedVector2Array([at+Vector2(-2,0),at+Vector2(0,-1),at+Vector2(2,0),at+Vector2(0,1)]),color)
