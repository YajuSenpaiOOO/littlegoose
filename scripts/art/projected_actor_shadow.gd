extends Node2D
const ACTOR_POSE = preload("res://scripts/art/actor_shadow_pose.gd")
## Finite ground-plane silhouette, driven by real lights and current actor artwork.
@export var body_height := 27.0
@export var max_length := 34.0
var actor: Node2D
var visual: Sprite2D
var sources: Array[Dictionary] = []
var natural_light: Node2D
var image: Sprite2D
var shade: ShaderMaterial
var projected := Vector2.ZERO
var opacity := 0.0
var target_vector := Vector2.ZERO
var target_opacity := 0.0

func _ready() -> void:
	z_index = -1
	# Walk frames use different pixel resolutions. Their texture, foot offset and
	# matching scale must switch atomically, like the actor's visual Sprite2D.
	# Interpolating raw-pixel transforms pairs a new image with the old scale.
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	image = Sprite2D.new()
	image.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	shade = ShaderMaterial.new()
	shade.shader = preload("res://scripts/art/projected_actor_shadow.gdshader")
	image.material = shade
	add_child(image)

func update_shadow(delta: float,enabled: bool) -> void:
	if not is_instance_valid(actor) or not is_instance_valid(visual):
		hide()
		queue_free()
		return
	if not enabled:
		image.hide()
		return
	global_position = actor.global_position
	image.texture = visual.texture
	image.centered = visual.centered
	image.offset = visual.offset
	image.flip_h = visual.flip_h
	image.flip_v = visual.flip_v
	var result := preload("res://scripts/art/ground_shadow_math.gd").evaluate(actor.global_position,sources,body_height,max_length)
	target_vector = result.vector
	target_opacity = result.opacity
	if natural_light: target_opacity *= natural_light.local_shadow_visibility
	if delta<=0:
		projected = target_vector
		opacity = target_opacity
	else:
		projected = projected.lerp(target_vector,1-exp(-delta*11))
		opacity = lerpf(opacity,target_opacity,1-exp(-delta*23))
	image.visible = enabled and actor.is_visible_in_tree() and visual.visible and opacity>0.003 and projected.length()>0.7
	if not image.visible: return
	var direction := projected.normalized()
	var width_axis := (Vector2.RIGHT if ACTOR_POSE.is_character(actor) else Vector2(-direction.y,direction.x))*absf(visual.scale.x)
	var height_axis := -projected*absf(visual.scale.y)/body_height
	var lift := ACTOR_POSE.lift(actor,visual)
	var origin := projected*lift/body_height
	if not visual.centered:
		origin = width_axis*(visual.position.x/maxf(0.0001,absf(visual.scale.x)))+height_axis*(visual.position.y/maxf(0.0001,absf(visual.scale.y)))
	image.transform = Transform2D(width_axis,height_axis,origin)
	shade.set_shader_parameter("strength",opacity*ACTOR_POSE.opacity(actor,visual))
