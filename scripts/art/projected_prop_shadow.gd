extends Node2D
@export var profile: Resource
@export var raised_plane := Rect2(-31,-6,62,8)
@export var height := 18.0
@export var max_length := 24.0
@export var contacts := PackedVector2Array([Vector2(-30,-3),Vector2(-24,2),Vector2(24,2),Vector2(30,-3)])
var actor: Node2D
var sources: Array[Dictionary] = []
var natural_light: Node2D
@export_enum("Local lights","Natural light") var source_kind := 0
@export var sun_max_length := 110.0
var projected := Vector2.ZERO
var opacity := 0.0
var polygon := PackedVector2Array()
var _cache_key: Array = []
var _settled := false
var rebuild_count := 0
var cache_hits := 0
var _projection_epoch := -1
var merge_mask := false

func _ready() -> void:
	if profile:
		raised_plane = profile.raised_plane
		height = profile.height
		max_length = profile.max_length
		contacts = profile.contacts
	z_index = -1
	var shade := ShaderMaterial.new()
	shade.shader = preload("res://scripts/art/projected_prop_shadow.gdshader")
	material = shade

func update_shadow(delta: float,enabled: bool) -> void:
	if not is_instance_valid(actor):
		hide()
		queue_free()
		return
	if not enabled or not actor.is_visible_in_tree():
		hide()
		_cache_key.clear()
		return
	if source_kind==1 and natural_light:
		var key := [natural_light.projection_epoch,natural_light.shadow_revision,actor.global_position,raised_plane,contacts,height,sun_max_length]
		if natural_light.cache_enabled and _settled and key==_cache_key:
			cache_hits += 1
			return
		_cache_key = key
	global_position = actor.global_position
	var result: Dictionary
	if source_kind==1 and natural_light:
		result = natural_light.sample_shadow(height,sun_max_length)
		material.set_shader_parameter("shadow_tint",natural_light.current_tint)
	else:
		result = preload("res://scripts/art/ground_shadow_math.gd").evaluate(global_position,sources,height,max_length)
		if natural_light: result.opacity *= natural_light.local_shadow_visibility
	if source_kind==1 and natural_light and _projection_epoch!=natural_light.projection_epoch:
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
	visible = enabled and actor.is_visible_in_tree() and opacity>0.003
	if not visible: return
	rebuild_count += 1
	var r := raised_plane
	var vertices := PackedVector2Array([r.position,r.position+Vector2(r.size.x,0),r.end,r.position+Vector2(0,r.size.y)])
	for i in vertices.size(): vertices[i] += projected
	vertices.append_array(contacts)
	polygon = Geometry2D.convex_hull(vertices)
	queue_redraw()

func _draw() -> void:
	if polygon.size()<3: return
	if merge_mask:
		draw_colored_polygon(polygon,Color.WHITE)
		return
	var center := Vector2.ZERO
	for point in polygon: center += point
	center /= polygon.size()
	# One joined seat/feet silhouette, not overlapping independent dark wedges.
	for expand in [2.0,1.0,0.0]:
		var soft := PackedVector2Array()
		for point in polygon: soft.append(point+(point-center).normalized()*expand)
		draw_colored_polygon(soft,Color(1,1,1,opacity*(0.22 if expand>0 else 0.56)))
