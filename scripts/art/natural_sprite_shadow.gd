extends Node2D
const ACTOR_POSE = preload("res://scripts/art/actor_shadow_pose.gd")
## Natural-light channel: copies alpha only, independently of point-light shadows.
var actor: Node2D
var visual: Sprite2D
var natural_light: Node2D
@export var body_height := 27.0
@export var max_length := 100.0
var image: Sprite2D
var projected := Vector2.ZERO
var opacity := 0.0
var _cache_key: Array = []
var _settled := false
var rebuild_count := 0
var cache_hits := 0
var _projection_epoch := -1
var merge_mask := false

func _ready() -> void:
	z_index = -1
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	image = Sprite2D.new()
	image.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var shade := ShaderMaterial.new()
	shade.shader = preload("res://scripts/art/projected_actor_shadow.gdshader")
	image.material = shade
	add_child(image)

func update_shadow(delta: float,enabled: bool) -> void:
	if not is_instance_valid(actor) or not is_instance_valid(visual):
		hide()
		queue_free()
		return
	if not enabled or not actor.is_visible_in_tree() or not visual.visible:
		image.hide()
		_cache_key.clear()
		return
	var key := [natural_light.projection_epoch,natural_light.shadow_revision,actor.global_position,visual.texture,visual.centered,visual.offset,visual.flip_h,visual.flip_v,visual.position,visual.scale,body_height,max_length]
	key.append(ACTOR_POSE.opacity(actor,visual))
	key.append(ACTOR_POSE.lift(actor,visual))
	if natural_light.cache_enabled and _settled and key==_cache_key:
		cache_hits += 1
		return
	_cache_key = key
	rebuild_count += 1
	global_position = actor.global_position
	image.texture = visual.texture
	image.centered = visual.centered
	image.offset = visual.offset
	image.flip_h = visual.flip_h
	image.flip_v = visual.flip_v
	var result: Dictionary = natural_light.sample_shadow(body_height,max_length)
	if natural_light and _projection_epoch!=natural_light.projection_epoch:
		if _projection_epoch>=0:
			projected = result.vector
			opacity = 0.0
		_projection_epoch = natural_light.projection_epoch
	if delta<=0:
		projected = result.vector
		opacity = result.opacity
	else:
		projected = projected.lerp(result.vector,1-exp(-delta*11))
		opacity = lerpf(opacity,result.opacity,1-exp(-delta*23))
	_settled = projected.distance_to(result.vector)<0.001 and absf(opacity-result.opacity)<0.00001
	if _settled:
		projected = result.vector
		opacity = result.opacity
	image.visible = enabled and actor.is_visible_in_tree() and visual.visible and opacity>0.003 and projected.length()>0.7
	if not image.visible: return
	var direction := projected.normalized()
	var width_axis := (Vector2.RIGHT if ACTOR_POSE.is_character(actor) else Vector2(-direction.y,direction.x))*absf(visual.scale.x)
	var height_axis := -projected*absf(visual.scale.y)/maxf(1,body_height)
	var origin := Vector2.ZERO
	if visual.centered:
		origin = projected*ACTOR_POSE.lift(actor,visual)/maxf(1,body_height)
	else:
		origin = width_axis*(visual.position.x/maxf(0.0001,absf(visual.scale.x)))+height_axis*(visual.position.y/maxf(0.0001,absf(visual.scale.y)))
	image.transform = Transform2D(width_axis,height_axis,origin)
	var strength := opacity
	strength *= ACTOR_POSE.opacity(actor,visual)
	image.material.set_shader_parameter("strength",strength)
	image.material.set_shader_parameter("shadow_tint",natural_light.current_tint)
	if merge_mask: image.material.set_shader_parameter("coverage",ACTOR_POSE.opacity(actor,visual))
