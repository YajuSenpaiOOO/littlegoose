extends "res://scripts/world/world24.gd"
var trail_batch: Node2D
var actor_shadows: Array[MeshInstance3D] = []
var silhouettes_enabled := true
var ordinary_hitstop := false
var perf_label: Label
var perf_clock := 0.
var floor_tiles: Dictionary = {}
var status_next := 0
var tracks_state := ""
var tracks_active := false

func _assign_ground_materials() -> void:
	tracks_state = ""
	super._assign_ground_materials()

func _sync_tracks() -> void:
	var active := false
	for mark in tracks.marks:
		var age: float = tracks.elapsed-mark.z
		if age>=-.001 and age<tracks.lifetime:
			active = true
			break
	var state := str(tracks.enabled and active)+"/"+str(tracks.lifetime)
	var changed := state!=tracks_state
	tracks_state = state
	tracks_active = active
	for material in ground_materials:
		if changed:
			material.set_shader_parameter("footprints_enabled",tracks.enabled and active)
			material.set_shader_parameter("footprint_lifetime",tracks.lifetime)
		if active and tracks.enabled: material.set_shader_parameter("footprint_clock",tracks.elapsed)
		if uploaded_revision!=tracks.revision: material.set_shader_parameter("footprints",tracks.marks)
	uploaded_revision = tracks.revision

func _cache_floor() -> void:
	floor_tiles.clear()
	var bounds: Rect2 = meadow.world_bounds.grow(6.)
	for i in meadow.chunks.size():
		var chunk: Dictionary = meadow.chunks[i]
		var vertices: PackedVector3Array = ground.mesh.surface_get_arrays(i)[Mesh.ARRAY_VERTEX]
		var key := Vector2i(((chunk.rect.position-bounds.position)/16.).round())
		floor_tiles[key] = {"rect":chunk.rect,"vertices":vertices,"width":int(round(sqrt(vertices.size())))}

func floor_height(at: Vector2) -> float:
	if meadow.bridge_rect.has_point(at): return meadow.bridge_height(at.x)
	var bounds: Rect2 = meadow.world_bounds.grow(6.)
	var key := Vector2i(((at-bounds.position)/16.).floor())
	if not floor_tiles.has(key): return meadow.walk_height(at,terrain_enabled)
	var tile: Dictionary = floor_tiles[key]
	var w: int = tile.width
	var uv: Vector2 = (at-tile.rect.position)/tile.rect.size*(w-1)
	var x := clampi(int(floor(uv.x)),0,w-2)
	var y := clampi(int(floor(uv.y)),0,w-2)
	var f := uv-Vector2(x,y)
	var a: int = y*w+x
	var p: PackedVector3Array = tile.vertices
	# Same diagonal and barycentric interpolation as the actual collider mesh.
	return p[a].y+(p[a+1].y-p[a].y)*f.x+(p[a+w+1].y-p[a+1].y)*f.y if f.x>=f.y else p[a].y+(p[a+w+1].y-p[a+w].y)*f.x+(p[a+w].y-p[a].y)*f.y

func floor_normal(at: Vector2) -> Vector3:
	var h := floor_height(at)
	return Vector3((h-floor_height(at+Vector2(.02,0)))/.02,1.,(h-floor_height(at+Vector2(0,.02)))/.02).normalized()

func _rebuild_terrain() -> void:
	super._rebuild_terrain()
	if world_ready: _cache_floor()

func _ready() -> void:
	super._ready()
	while not is_instance_valid(fx_layer): await get_tree().physics_frame
	_cache_floor()
	trail_batch = preload("res://scripts/combat/trail_batch25.gd").new()
	trail_batch.battle = self
	fx_layer.add_child(trail_batch)
	_add_actor_shadow(hero,hero.visual)
	if is_instance_valid(goose) and not goose.has_node("GroundedActorSilhouette"): _add_actor_shadow(goose,goose.visual)
	# Remove the old generic capsule shadow once the authored silhouette exists.
	for child in hero.get_children():
		if child is MeshInstance3D and child.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY: child.hide()
	perf_label = Label.new()
	perf_label.position = Vector2(20,104)
	perf_label.add_theme_font_size_override("font_size",16)
	perf_label.add_theme_color_override("font_shadow_color",Color.BLACK)
	perf_label.add_theme_constant_override("shadow_offset_x",1)
	perf_label.add_theme_constant_override("shadow_offset_y",1)
	label.get_parent().add_child(perf_label)
	print("WORLD25_GROUNDED_PERFORMANCE_READY")

func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
	var shadow := preload("res://scripts/combat/actor_shadow25.gd").new()
	shadow.battle = self
	shadow.visual = sprite
	shadow.enabled = silhouettes_enabled
	actor.add_child(shadow)
	actor_shadows.append(shadow)

func start_combat(reposition := true) -> void:
	super.start_combat(reposition)
	if is_instance_valid(trail_batch): trail_batch.particles.clear()
	for i in range(actor_shadows.size()-1,-1,-1):
		if not is_instance_valid(actor_shadows[i]): actor_shadows.remove_at(i)
	for enemy in enemies: _add_actor_shadow(enemy,enemy.visual)
	if is_instance_valid(goose) and not goose.has_node("GroundedActorSilhouette"): _add_actor_shadow(goose,goose.visual)

func emit_trail(at: Vector3,direction: Vector3) -> void:
	if is_instance_valid(trail_batch): trail_batch.emit_at(at,direction)

func hitstop(duration: float,force := false) -> void:
	if duration<=.012 and not ordinary_hitstop: return
	super.hitstop(duration,force)

func _update_prop_contacts() -> void:
	if not world_ready:
		super._update_prop_contacts()
		return
	# Avoid rebuilding depth-fitted meshes for furniture whose shadow is culled.
	var all_props := props15
	var all_cards := fitted_cards
	var all_marks := contact_marks
	var all_house := house_contacts
	props15 = []
	fitted_cards = []
	contact_marks = []
	if house_art.global_position.distance_to(hero.position)>40.: house_contacts = []
	for prop in all_props:
		if prop.root.position.distance_to(hero.position)<40.: props15.append(prop)
	for entry in all_cards:
		if entry.prop.root.position.distance_to(hero.position)<40.: fitted_cards.append(entry)
		else: entry.card.hide()
	for foot in all_marks:
		if foot.prop.root.position.distance_to(hero.position)<40.: contact_marks.append(foot)
	super._update_prop_contacts()
	props15 = all_props
	fitted_cards = all_cards
	contact_marks = all_marks
	house_contacts = all_house

func _fit_contact(mark: Node3D,at: Vector3,lift: float) -> void:
	var normal := floor_normal(Vector2(at.x,at.z))
	var right := Vector3.RIGHT.slide(normal).normalized()
	var scale_before := mark.scale
	mark.global_basis = Basis(right,normal,right.cross(normal)).scaled(scale_before)
	mark.global_position = Vector3(at.x,floor_height(Vector2(at.x,at.z))+lift,at.z)

func _process(delta: float) -> void:
	super._process(delta)
	if not world_ready: return
	# Correct after inherited pose/follow updates: +Y is the PlaneMesh normal.
	_fit_contact(hero_contact,hero.global_position,.026)
	for enemy in enemies:
		if is_instance_valid(enemy): _fit_contact(enemy.shadow,enemy.global_position,.026)
	if is_instance_valid(goose): _fit_contact(goose.shadow,goose.global_position,.026)
	perf_clock += delta
	if perf_clock>.4 and is_instance_valid(perf_label):
		perf_clock = 0.
		perf_label.text = "%d FPS · Y 角色投影 %s · X 普通命中微顿 %s"%[Engine.get_frames_per_second(),"开" if silhouettes_enabled else "关","开" if ordinary_hitstop else "关"]

func _status() -> void:
	# The inherited HUD builds several successive strings and triggers text
	# shaping on every render frame. Human-readable status only needs 5 Hz.
	var now := Time.get_ticks_msec()
	if world_ready and now<status_next: return
	status_next = now+200
	super._status()
	if world_ready: label.text = label.text.replace("连续世界24","连续世界25")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_Y:
			silhouettes_enabled = not silhouettes_enabled
			for shadow in actor_shadows:
				if is_instance_valid(shadow): shadow.enabled = silhouettes_enabled
			return
		if event.physical_keycode==KEY_X:
			ordinary_hitstop = not ordinary_hitstop
			return
	super._unhandled_input(event)
