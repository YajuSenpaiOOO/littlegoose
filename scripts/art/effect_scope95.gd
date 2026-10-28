extends Node
## Keep resident meshes, but budget custom CPU projections outside a padded view.
var world: Node3D
var enabled95 := true
var shadows95: Array[Node]=[]
var active95: Array[Node]=[]
var scan_left95 := 0.
var cursor95 := 0
var updates95 := 0
var scans95 := 0
var plant_checks95 := 0

func near_view95(at: Vector3,radius := 3.) -> bool:
	if world.review72: return true
	var camera: Camera3D=world.camera
	if camera.is_position_behind(at): return false
	var size: Vector2=world.get_viewport().get_visible_rect().size
	# A quarter viewport plus the object's projected radius, beyond every edge.
	var padding := size*.25
	var screen := camera.unproject_position(at)
	var extent: float=maxf(camera.unproject_position(at+Vector3.RIGHT*radius).distance_to(screen),camera.unproject_position(at+Vector3.UP*radius).distance_to(screen))
	return Rect2(-padding-Vector2.ONE*extent,size+padding*2.+Vector2.ONE*extent*2.).has_point(screen)

func shadow_near95(shadow: Node) -> bool:
	if not is_instance_valid(shadow.visual): return false
	var visual: Sprite3D=shadow.visual
	return caster_near95(visual)

func caster_near95(visual: Sprite3D) -> bool:
	var at: Vector3=visual.global_position
	var height: float=visual.texture.get_height()*visual.pixel_size
	# Broad safety allowance covers slopes below an elevated caster, too.
	var radius: float=visual.texture.get_width()*visual.pixel_size*.6+3.
	if near_view95(at,radius) or near_view95(at+Vector3.UP*height,radius): return true
	# An offscreen caster can project an onscreen shadow. Include that endpoint.
	var ray: Vector3=-world.sun.global_basis.z.normalized()
	if ray.y<-.025:
		var end := at+Vector3.UP*height+ray*(-height/ray.y)
		if near_view95(end,radius): return true
		if near_view95(at.lerp(end,.5),radius): return true
	return false

func _collect95(node: Node) -> void:
	if node.get_script()==preload("res://scripts/art/grounded_prop_shadow63.gd"):
		shadows95.append(node);node.set_process(false)
	for child in node.get_children(): _collect95(child)

func refresh95() -> void:
	active95.clear();scans95+=1
	for shadow in shadows95:
		if not is_instance_valid(shadow): continue
		if shadow_near95(shadow): active95.append(shadow)
		else: shadow.hide()
	if not active95.is_empty(): cursor95%=active95.size()
	if is_instance_valid(world.forest87):
		for plant in world.forest87.plants94:
			var visual: Sprite3D=plant.visual
			var active := near_view95(visual.global_position,2.)
			visual.set_meta("active95",active);plant_checks95+=1

func set_enabled95(value: bool) -> void:
	enabled95=value
	for shadow in shadows95:
		shadow.set_process(not value)
		if not value: shadow.update_shadow()
	scan_left95=0.

func _ready() -> void:
	_collect95(world);refresh95()
	print("EFFECT_SCOPE95 projections=",shadows95.size()," active=",active95.size())

func _process(delta: float) -> void:
	if not enabled95: return
	scan_left95-=delta
	if scan_left95<=0.:
		scan_left95=.12;refresh95()
	# At most two expensive terrain-fitted projection updates in one frame.
	for i in mini(2,active95.size()):
		var shadow: Node=active95[cursor95%active95.size()];cursor95+=1
		shadow.update_shadow();updates95+=1
