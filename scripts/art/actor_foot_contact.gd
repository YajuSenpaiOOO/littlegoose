extends Node2D
const ACTOR_POSE = preload("res://scripts/art/actor_shadow_pose.gd")
## A thin alpha-shaped shoe contact, shared by sun and local lighting.
var actor: Node2D
var visual: Sprite2D
var image: Sprite2D
var enabled := true
var _key: Array = []

static func ensure(owner_actor: Node2D,source: Sprite2D) -> Node2D:
	var existing := owner_actor.get_node_or_null("FootContact")
	if existing:
		existing.set_process(true)
		existing.update_contact(true)
		return existing
	var contact := load("res://scripts/art/actor_foot_contact.gd").new() as Node2D
	contact.name = "FootContact"
	contact.actor = owner_actor
	contact.visual = source
	owner_actor.add_child(contact)
	return contact

func _ready() -> void:
	z_index = -1
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	image = Sprite2D.new()
	image.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var shade := ShaderMaterial.new()
	shade.shader = preload("res://scripts/art/actor_foot_contact.gdshader")
	image.material = shade
	add_child(image)
	update_contact()

func _process(_delta: float) -> void: update_contact(enabled)

func update_contact(value := true) -> void:
	enabled = value
	if not is_instance_valid(actor) or not is_instance_valid(visual):
		hide()
		return
	var lift := ACTOR_POSE.lift(actor,visual)
	var strength := 0.24*clampf(1.0-lift/6.0,0,1)
	strength *= ACTOR_POSE.opacity(actor,visual)
	var key := [enabled,actor.is_visible_in_tree(),visual.visible,visual.texture,visual.centered,visual.position.x,visual.offset,visual.scale,visual.flip_h,visual.flip_v,strength]
	if key==_key: return
	_key = key
	image.visible = enabled and actor.is_visible_in_tree() and visual.visible and strength>0.001
	if not image.visible: return
	image.texture = visual.texture
	image.centered = visual.centered
	image.offset = visual.offset
	image.flip_h = visual.flip_h
	image.flip_v = visual.flip_v
	image.position = Vector2(visual.position.x,0)
	# Keep feet at the true ground anchor, with only a one-pixel thick flattened contact.
	image.scale = Vector2(absf(visual.scale.x),absf(visual.scale.y)*0.35)
	image.material.set_shader_parameter("source_scale_y",absf(visual.scale.y))
	image.material.set_shader_parameter("strength",strength)
