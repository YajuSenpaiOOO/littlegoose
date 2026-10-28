extends MeshInstance3D
## Cheap authored-silhouette projection, independent of the aim/collision body.
var battle: Node3D
var visual: Sprite3D
var ink: ShaderMaterial
var last_texture: Texture2D
var light_direction := Vector3(.4,-1.,.4).normalized()
var enabled := true
var opacity_scale := 1.
func _ready() -> void:
	name = "GroundedActorSilhouette"
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ink = ShaderMaterial.new()
	ink.shader = preload("res://scripts/art/actor_shadow25.gdshader")
	material_override = ink
	light_direction = -battle.sun.global_basis.z.normalized()
func _physics_process(_delta: float) -> void:
	visible = enabled and is_instance_valid(visual) and visual.is_visible_in_tree() and battle.contact_enabled
	if not visible: return
	var source: Texture2D = visual.texture
	if source==null: return
	if source!=last_texture:
		last_texture = source
		var region := Vector4(0,0,1,1)
		var texture: Texture2D = source
		if source is AtlasTexture:
			texture = source.atlas
			var size := texture.get_size()
			region = Vector4(source.region.position.x/size.x,source.region.position.y/size.y,source.region.size.x/size.x,source.region.size.y/size.y)
		ink.set_shader_parameter("silhouette",texture)
		ink.set_shader_parameter("region",region)
	ink.set_shader_parameter("flipped",visual.flip_h)
	ink.set_shader_parameter("opacity",.27*visual.modulate.a*opacity_scale)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points: Array[Vector3] = []
	var size := source.get_size()
	var origin: Vector3 = get_parent().global_position
	var base: float = battle.floor_height(Vector2(origin.x,origin.z))
	# Nine shared points suffice for the gentle authored slopes. No physics rays,
	# extra lights or per-actor shadow maps are needed.
	for y in 3:
		for x in 3:
			var uv := Vector2(x,y)*.5
			var pixel := uv*size
			var local := Vector3((pixel.x-size.x*.5+visual.offset.x)*visual.pixel_size,(size.y*.5-pixel.y+visual.offset.y)*visual.pixel_size,0)
			var point := visual.to_global(local)
			var projected := point+light_direction*((base-point.y)/light_direction.y)
			for i in 2:
				var h: float = battle.floor_height(Vector2(projected.x,projected.z))
				projected = point+light_direction*((h-point.y)/light_direction.y)
			projected.y = battle.floor_height(Vector2(projected.x,projected.z))+.022
			points.append(to_local(projected))
	for y in 2:
		for x in 2:
			for offset in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
				var index: Vector2i = Vector2i(x,y)+offset
				st.set_uv(Vector2(index)*.5)
				st.add_vertex(points[index.y*3+index.x])
	mesh = st.commit()
