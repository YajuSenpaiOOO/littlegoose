@tool
extends Node2D
## Atomic sorting unit: neighboring trees never merge into this object.
class FootprintGuide extends Node2D:
	var prop: Node2D
	func _draw() -> void:
		prop._draw_collision(self)
@export var profile: Resource
@export var size_factor := 1.0
@export_group("Instance collision tuning")
@export var collision_adjust := Vector2.ZERO:
	set(value):
		collision_adjust = value
		if is_node_ready(): _refresh_collision()
@export var footprint_override := Vector2(-1,-1):
	set(value):
		footprint_override = value
		if is_node_ready(): _refresh_collision()
var collision_debug := false:
	set(value):
		collision_debug = value
		if is_node_ready(): _sync_guide()
var collision_overlay: Node2D
var visual: Node2D
var emitter: Node2D
var solar: Node2D
var local_projection: Node2D
var _attached := false

func _ready() -> void:
	set_process(Engine.is_editor_hint())
	if not profile: return
	y_sort_enabled = false
	if profile.art_scene:
		visual = profile.art_scene.instantiate()
		visual.scale = Vector2.ONE*size_factor
	else:
		var sprite := Sprite2D.new()
		sprite.texture = profile.texture
		sprite.centered = false
		sprite.scale = Vector2.ONE*profile.draw_scale*size_factor
		sprite.position = -profile.anchor_px*sprite.scale
		if profile.wind>0:
			var wind := ShaderMaterial.new()
			wind.shader = preload("res://scripts/art/garden_foliage.gdshader")
			wind.set_shader_parameter("strength",profile.wind)
			wind.set_shader_parameter("phase",position.x*.09+position.y*.03)
			sprite.material = wind
		visual = sprite
	visual.name = "Visual"
	add_child(visual)
	_surface_mask(visual)
	_refresh_collision()
	if profile.contact_size!=Vector2.ZERO:
		var contact := preload("res://scripts/art/contact_shadow.gd").create()
		contact.name = "ContactShadow"
		contact.scale = profile.contact_size*size_factor/Vector2(96,30)
		contact.z_index = -1
		add_child(contact)
	if profile.light_profile:
		emitter = preload("res://scripts/art/station_light.gd").new()
		emitter.profile = profile.light_profile
		add_child(emitter)
	if not Engine.is_editor_hint(): _attach_lighting.call_deferred()

func effective_footprint() -> Vector2:
	return footprint_override if footprint_override.x>=0 and footprint_override.y>=0 else profile.footprint

func effective_offset() -> Vector2:
	return profile.footprint_offset+collision_adjust

func _refresh_collision() -> void:
	if not profile: return
	var body := get_node_or_null("Footprint")
	if effective_footprint()==Vector2.ZERO:
		if body:
			remove_child(body)
			body.queue_free()
		queue_redraw()
		_sync_guide()
		return
	if not body:
		body = StaticBody2D.new()
		body.name = "Footprint"
		body.collision_layer = 1
		body.collision_mask = 0
		var hit := CollisionShape2D.new()
		hit.name = "Shape"
		body.add_child(hit)
		add_child(body)
	body.position = effective_offset()*size_factor
	var hit: CollisionShape2D = body.get_child(0)
	var dimensions := effective_footprint()*size_factor
	if profile.footprint_shape==1:
		var polygon := ConvexPolygonShape2D.new()
		var points := PackedVector2Array([Vector2(-0.5,-0.20),Vector2(-0.30,-0.5),Vector2(0.30,-0.5),Vector2(0.5,-0.20),Vector2(0.5,0.20),Vector2(0.30,0.5),Vector2(-0.30,0.5),Vector2(-0.5,0.20)])
		for i in points.size(): points[i] *= dimensions
		polygon.points = points
		hit.shape = polygon
	else:
		var rectangle := RectangleShape2D.new()
		rectangle.size = dimensions
		hit.shape = rectangle
	queue_redraw()
	_sync_guide()

func _sync_guide() -> void:
	var enabled := Engine.is_editor_hint() or collision_debug
	if enabled and not is_instance_valid(collision_overlay):
		collision_overlay = FootprintGuide.new()
		collision_overlay.prop = self
		collision_overlay.name = "CollisionGuide"
		collision_overlay.z_index = 50
		var ink := CanvasItemMaterial.new()
		ink.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		collision_overlay.material = ink
		add_child(collision_overlay)
	if is_instance_valid(collision_overlay):
		collision_overlay.visible = enabled
		collision_overlay.queue_redraw()

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() or not profile or not visual: return
	if visual is Sprite2D:
		visual.texture = profile.texture
		visual.scale = Vector2.ONE*profile.draw_scale*size_factor
		visual.position = -profile.anchor_px*visual.scale
	else: visual.scale = Vector2.ONE*size_factor
	_refresh_collision()
	var contact := get_node_or_null("ContactShadow")
	if contact: contact.scale = profile.contact_size*size_factor/Vector2(96,30)
	queue_redraw()

func _draw_collision(canvas: Node2D) -> void:
	if (not Engine.is_editor_hint() and not collision_debug) or not profile: return
	# Draw the live physics shape, not a second approximation of its resource.
	var body := get_node_or_null("Footprint")
	if body:
		var hit: CollisionShape2D = body.get_child(0)
		canvas.draw_set_transform(body.position+hit.position)
		if hit.shape is RectangleShape2D:
			canvas.draw_rect(Rect2(-hit.shape.size/2,hit.shape.size),Color(1,0.77,0.15,0.95),false,0.8)
		elif hit.shape is ConvexPolygonShape2D:
			var outline: PackedVector2Array = hit.shape.points.duplicate()
			outline.append(outline[0])
			canvas.draw_polyline(outline,Color(1,0.77,0.15,0.95),0.8)
		canvas.draw_set_transform(Vector2.ZERO)
	canvas.draw_circle(Vector2.ZERO,1.3,Color.CYAN)

func _surface_mask(node: Node) -> void:
	if node is CanvasItem: node.light_mask = 2
	for child in node.get_children(): _surface_mask(child)

func _attach_lighting() -> void:
	if _attached or profile.projection_kind==2: return
	var map := get_parent()
	while map and not map.has_method("register_world_prop"): map = map.get_parent()
	if not map: return
	_attached = true
	var rig: Node2D = map.get_node("WorldLighting")
	if profile.projection_kind==0:
		solar = rig.project_sprite(self,visual,profile.height*size_factor,profile.max_shadow_length)
		local_projection = preload("res://scripts/art/projected_actor_shadow.gd").new()
		local_projection.visual = visual
		local_projection.body_height = profile.height*size_factor
		local_projection.max_length = 55
	else:
		var feet := PackedVector2Array()
		for foot in profile.contacts: feet.append(foot*size_factor)
		var plane := Rect2(profile.raised_plane.position*size_factor,profile.raised_plane.size*size_factor)
		solar = rig.project_plane(self,plane,feet,profile.height*size_factor,profile.max_shadow_length)
		local_projection = preload("res://scripts/art/projected_prop_shadow.gd").new()
		local_projection.height = profile.height*size_factor
		local_projection.raised_plane = plane
		local_projection.contacts = feet
		local_projection.max_length = 55
	local_projection.actor = self
	local_projection.sources = map.local_sources
	local_projection.natural_light = rig
	map.add_child(local_projection)
	tree_exiting.connect(local_projection.queue_free,CONNECT_ONE_SHOT)
	map.register_world_prop(self)
