extends "res://scripts/world/world86.gd"
var forest87: Node3D
var ground_shader87: Shader
var forest_trees87 := 0
var replaced_rocks87 := 0
func _time_script() -> Script: return preload("res://scripts/world/world_time87.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 87 · 林间苔岩 / 蕨草与后林层次")
func _forest_script87() -> Script: return preload("res://scripts/art/forest_props87.gd")

func _build_woodland() -> void:
	super._build_woodland()
	var g: Vector2=meadow.landmarks.grove
	for offset in [Vector2(-26.,-10.),Vector2(-24.,-17.),Vector2(-15.,-26.),Vector2(-5.,-27.),Vector2(10.,-26.)]:
		var at: Vector2=g+offset
		if meadow.route_distance(at)<2.8 or meadow.normal_at(at.x,at.y,true).y<.88: continue
		var near: Dictionary={};var distance := 4.0
		for tree in trees:
			var d := Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)
			if d<distance: near=tree;distance=d
		if not near.is_empty():
			near.root.position=Vector3(at.x,meadow.height_at(at.x,at.y,true),at.y)
		else: _add_route_tree(at,6.4+forest_trees87*.25)
		forest_trees87+=1

func _assign_ground_materials() -> void:
	super._assign_ground_materials()
	if ground_shader87==null:
		ground_shader87=Shader.new()
		var code: String=ground_shader84.code
		code=code.replace("shader_type spatial;","shader_type spatial;\nuniform vec2 grove87;\nuniform sampler2D cliff_paint87 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;\nuniform bool forest_enabled87=true;")
		var cover := """
 if(forest_enabled87){
  vec2 q87=(world.xz-grove87)/vec2(22.,17.);
  float area87=1.-smoothstep(.8,1.4,length(q87));
  float clusters87=soft_noise(world.xz*.27+vec2(8.,19.));
  float moss87=smoothstep(.44,.72,clusters87)*area87*(1.-path)*smoothstep(.82,.96,normal76.y);
  float pale87=smoothstep(.59,.81,soft_noise(world.xz*.34-vec2(14.,6.)))*area87*(1.-path);
  vec3 moss_tone87=mix(col,vec3(.30,.38,.19),.36);
  col=mix(col,moss_tone87,moss87);
  col=mix(col,col*vec3(1.07,1.025,.90)+vec3(.018,.012,.002),pale87*.55);
  float rear87=(1.-smoothstep(-55.,-52.,world.z))*smoothstep(grove87.x-31.,grove87.x-25.,world.x)*(1.-smoothstep(grove87.x+18.,grove87.x+25.,world.x));
  float ledges87=max(exp(-pow((world.x-grove87.x+17.)/7.,2.)),max(exp(-pow((world.x-grove87.x+1.)/6.,2.)),exp(-pow((world.x-grove87.x-13.)/5.,2.))));
  float face87=rear87*ledges87*(1.-smoothstep(.72,.94,normal76.y))*smoothstep(2.35,2.8,world.y);
  vec3 painted87=texture(cliff_paint87,vec2(world.x/8.,-world.y/7.)).rgb*vec3(.83,.88,.80);
  col=mix(col,painted87,face87*.94);
 }
"""
		ground_shader87.code=code.replace(" ALBEDO=albedo_view ?",cover+" ALBEDO=albedo_view ?")
	for material in ground_materials:
		material.shader=ground_shader87;material.set_shader_parameter("grove87",meadow.landmarks.grove);material.set_shader_parameter("cliff_paint87",preload("res://assets/forest87/painted_rock_face87.png"))
		if is_instance_valid(porch49): porch49.shade_material(material,ground_shader87)

func _ready() -> void:
	super._ready()
	while not is_instance_valid(station81) or not is_instance_valid(scenery78): await get_tree().physics_frame
	_clear_legacy_rocks87()
	forest87=_forest_script87().new();forest87.world=self;add_child(forest87)
	await get_tree().physics_frame
	navigation.bake(get_world_3d().direct_space_state,meadow,meadow.landmarks.grove)
	time55.update_guide();_title35()

func _clear_legacy_rocks87() -> void:
	# The old angular forest stones and moss caps shared batches with lake rocks.
	# Remove only the forest triangles; leave the shoreline's batch and colliders.
	for node: MeshInstance3D in [scenery78.rock_mesh,scenery78.get_node("SmallMossCaps78")]:
		var arrays: Array=node.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
		var indices := PackedInt32Array()
		if arrays[Mesh.ARRAY_INDEX]!=null: indices=arrays[Mesh.ARRAY_INDEX]
		var count := vertices.size() if indices.is_empty() else indices.size()
		var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(0,count,3):
			var ids := PackedInt32Array()
			for j in 3: ids.append(i+j if indices.is_empty() else indices[i+j])
			var centre := (vertices[ids[0]]+vertices[ids[1]]+vertices[ids[2]])/3.
			if centre.x< -20. and centre.z< -20.: continue
			for index in ids:
				st.set_normal(normals[index])
				if arrays[Mesh.ARRAY_TEX_UV]!=null: st.set_uv(arrays[Mesh.ARRAY_TEX_UV][index])
				if arrays[Mesh.ARRAY_COLOR]!=null: st.set_color(arrays[Mesh.ARRAY_COLOR][index])
				st.add_vertex(vertices[index])
		node.mesh=st.commit()
	for body in scenery78.boulders70:
		if body.position.x< -20. and body.position.z< -20.:
			body.collision_layer=0;replaced_rocks87+=1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and is_instance_valid(forest87):
		if event.ctrl_pressed and not event.alt_pressed and event.physical_keycode==KEY_7:
			set_review72(false);_teleport15(meadow.landmarks.grove+Vector2(-18.,3.));return
		if event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_G:
			forest87.set_enabled87(not forest87.enabled87)
			for material in ground_materials: material.set_shader_parameter("forest_enabled87",forest87.enabled87)
			return
	super._unhandled_input(event)
