extends "res://scripts/world/storybook_world89.gd"
var terrain_shader90: Shader
var terrace_ready90 := false
var seated_trees90 := 0
var moved_trees90 := 0

func _build_lab_floor() -> void:
	super._build_lab_floor()
	meadow=preload("res://scripts/world/world_surface90.gd").new()

func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 90 · 连续林台 / 西侧岩肩 / 林地入口")
func _time_script() -> Script: return preload("res://scripts/world/terrace_time90.gd")
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props90.gd")

func _build_lab_grass() -> void:
	super._build_lab_grass()
	# The old warm-cache loader uses a different mesh index than a fresh build.
	# Select this short-grass geometry explicitly for repeatable terrain previews.
	var short_grass: ArrayMesh=meadow.blades(2)
	for batch in grass_batches: batch.node.multimesh.mesh=short_grass

func _safe_tree90(at: Vector2) -> bool:
	if not meadow.world_bounds.grow(-1.5).has_point(at) or meadow.route_distance(at)<2.8: return false
	if ((at-Vector2(meadow.landmarks.grove))/meadow.ROOT_BUFFER76).length()<1.08: return false
	if meadow.normal_at(at.x,at.y,true).y<.94: return false
	var low := INF;var high := -INF
	for offset in [Vector2.ZERO,Vector2(-1.,0),Vector2(1.,0),Vector2(0,1.8)]:
		var height: float=meadow.height_at(at.x+offset.x,at.y+offset.y,true)
		low=minf(low,height);high=maxf(high,height)
	return high-low<.42

func _build_woodland() -> void:
	super._build_woodland()
	var g: Vector2=meadow.landmarks.grove
	var keep: Array[Dictionary]=[]
	for tree in trees:
		var at := Vector2(tree.root.position.x,tree.root.position.z)
		if at.x> -28. or at.y> -27. or at.y< -82.: keep.append(tree);continue
		if not _safe_tree90(at):
			var found := false
			for offset in [Vector2(0,-4.),Vector2(-3.,-3.),Vector2(3.,-4.),Vector2(-4.,1.),Vector2(4.,1.),Vector2(0,-7.)]:
				if _safe_tree90(at+offset): at+=offset;found=true;break
			if found: moved_trees90+=1
			else:
				distant_roots.erase(tree.root);tree.root.free();continue
		# All surviving cards and their root fans start on the new surface.
		tree.root.position=Vector3(at.x,meadow.height_at(at.x,at.y,true),at.y)
		seated_trees90+=1
		keep.append(tree)
	trees.assign(keep)
	# A few intentional top trees establish that the cliff carries a broad forest.
	for at in [g+Vector2(-16.,-25.),g+Vector2(-6.,-27.),g+Vector2(8.,-24.),g+Vector2(-26.,-6.),g+Vector2(-27.,-16.)]:
		if not _safe_tree90(at): continue
		var near := false
		for tree in trees:
			if Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)<3.: near=true;break
		if not near: _add_route_tree(at,7.0)

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	if terrain_shader90==null:
		terrain_shader90=Shader.new()
		var code: String=floor_shader89.code
		# Triplanar rock pigment follows actual side normals, including west faces.
		var old := "col=mix(col,painted87,face87*.94);"
		var replacement := """
  col=mix(col,painted87,face87*.94);
  float zone90=smoothstep(-83.,-78.,world.x)*(1.-smoothstep(-30.,-26.,world.x));
  zone90*=smoothstep(-82.,-77.,world.z)*(1.-smoothstep(-29.,-26.,world.z));
  float face90=(1.-smoothstep(.78,.95,normal76.y))*zone90*smoothstep(2.15,2.6,world.y);
  vec3 weights90=pow(abs(normal76),vec3(5.));weights90/=max(.001,weights90.x+weights90.y+weights90.z);
  vec3 stone90=texture(cliff_paint87,world.zy/vec2(4.8,4.8)).rgb*weights90.x;
  stone90+=texture(cliff_paint87,world.xy/vec2(4.8,4.8)).rgb*weights90.z;
  stone90+=texture(cliff_paint87,world.xz/4.8).rgb*weights90.y;
  stone90*=vec3(.68,.76,.80);
  col=mix(col,stone90,face90*.96);
"""
		terrain_shader90.code=code.replace(old,replacement)
	for material in ground_materials:
		material.shader=terrain_shader90
		if is_instance_valid(porch49): porch49.shade_material(material,terrain_shader90)

func _ready() -> void:
	super._ready()
	while soil_texture89==null or not is_instance_valid(scenery78): await get_tree().physics_frame
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	terrace_ready90=true;_title35();time55.update_guide()
	print("TERRACE90_READY seated_trees=",seated_trees90," moved_trees=",moved_trees90)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and not event.alt_pressed:
		if event.physical_keycode==KEY_6:
			set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(14.,8.));return
		if event.physical_keycode==KEY_8:
			set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(-6.,-11.));return
	super._unhandled_input(event)
