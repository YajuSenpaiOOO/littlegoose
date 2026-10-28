extends Node3D
const LABELS := ["A 古橡之冠","B 垂枝银柳","C 盘根花树"]
const FILES := ["giant_oak","giant_willow","giant_flower"]
const TEXTURES := [preload("res://assets/landmark63/giant_oak.png"),preload("res://assets/landmark63/giant_willow.png"),preload("res://assets/landmark63/giant_flower.png")]
var world: Node3D
var variant := 0
var old_tree := false
var painted_sign := true
var profiles: Dictionary
var original: Dictionary
var tree: Dictionary
var root_piece: Dictionary
var sign_root: Node3D
var sign_sprite: Sprite3D
var review_view := false
var review_anchor := Vector3.ZERO
var tree_shadow63: MeshInstance3D
var sign_shadow63: MeshInstance3D

func start_review() -> void:
	review_view=true
	review_anchor=world.hero.global_position
	_process(0.)

func _process(_delta: float) -> void:
	if not review_view: return
	if world.hero.global_position.distance_to(review_anchor)>.25:
		review_view=false
		return
	# Asset review framing only; retain the approved pitch and FOV. Walking exits it.
	world.camera.global_position=tree.root.global_position+Vector3.UP*7.0+world.camera.global_basis.z*42.

func _refresh_root_piece() -> void:
	for piece in world.root_pieces:
		if piece.sprite==tree.visual:
			root_piece=piece
			return

func _ready() -> void:
	name="WorldTreeThreeStudies62"
	profiles=JSON.parse_string(FileAccess.get_file_as_string("res://assets/landmark63/profiles.json"))
	tree=world.landmark_tree
	for piece in world.root_pieces:
		if piece.sprite==tree.visual:
			root_piece=piece
			break
	var sprite: Sprite3D=tree.visual
	original={"texture":sprite.texture,"pixel_size":sprite.pixel_size,"offset":sprite.offset,"position":sprite.position,"mesh":root_piece.node.mesh,"cut":root_piece.cut,"drop":root_piece.drop}
	_build_sign()
	_build_tree_contact()
	set_tree(1)
	set_sign(true)
	tree_shadow63=_project_shadow(tree.visual)
	sign_shadow63=_project_shadow(sign_sprite)
	_sync_paint()

func _project_shadow(source: Sprite3D) -> MeshInstance3D:
	var shadow := preload("res://scripts/art/grounded_prop_shadow63.gd").new()
	shadow.world=world
	shadow.visual=source
	add_child(shadow)
	shadow.update_shadow()
	return shadow

func _root_fitter() -> RefCounted:
	return preload("res://scripts/art/landmark_roots63.gd").new()

func _apply_tree(texture: Texture2D,profile: Dictionary) -> void:
	_refresh_root_piece()
	var sprite: Sprite3D=tree.visual
	sprite.texture=texture
	sprite.pixel_size=tree.height/float(profile.height)
	sprite.offset=Vector2(texture.get_width()*.5-profile.foot[0],profile.foot[1]-texture.get_height()*.5)
	var fitter := _root_fitter()
	var result: Dictionary=fitter.root_skirt(texture,profile,tree.height,tree.root.position,world.meadow,world.terrain_enabled)
	root_piece.node.mesh=result.mesh
	root_piece.drop=result.drop
	root_piece.cut=result.cut
	sprite.position.y=-float(result.drop) if world.contact_enabled else 0.
	sprite.material_override.set_shader_parameter("root_cut_y",result.cut if world.contact_enabled else 1.)
	world.extra_profiles["worldtree62"]=profile
	tree.extra_id="worldtree62"
	_sync_paint()

func _sync_paint() -> void:
	var sprite: Sprite3D=tree.visual
	sprite.material_override.set_shader_parameter("paint",sprite.texture)
	root_piece.node.material_override.set_shader_parameter("paint",sprite.texture)
	root_piece.node.material_override.set_shader_parameter("root_cut_y",1.)
	if tree.has("shadow19"):
		var shadow: Sprite3D=tree.shadow19
		shadow.texture=sprite.texture
		shadow.pixel_size=sprite.pixel_size
		shadow.offset=sprite.offset
		shadow.position=Vector3.ZERO
		shadow.material_override.set_shader_parameter("paint",sprite.texture)
		shadow.material_override.set_shader_parameter("root_cut_y",1.)
		shadow.hide()
	if is_instance_valid(tree_shadow63): tree_shadow63.update_shadow()
	var left: float=tree.root.position.x+(sprite.offset.x-sprite.texture.get_width()*.5)*sprite.pixel_size
	var right: float=left+sprite.texture.get_width()*sprite.pixel_size
	var focus: ShaderMaterial=world.atmosphere41.focus_material
	focus.set_shader_parameter("landmark_bounds62",Vector4(left,right,sprite.global_position.z,0.))
	focus.set_shader_parameter("landmark_height62",Vector2(tree.root.position.y+.35,tree.root.position.y+tree.height+.1))
	focus.set_shader_parameter("landmark_root62",Vector4(tree.root.position.x,tree.root.position.z,tree.root.position.y,1.))
	world._title35()

func set_tree(index: int) -> void:
	variant=clampi(index,0,2)
	old_tree=false
	_apply_tree(TEXTURES[variant],profiles[FILES[variant]])

func set_old_tree(enabled: bool) -> void:
	if not enabled:
		set_tree(variant)
		return
	old_tree=true
	_refresh_root_piece()
	var sprite: Sprite3D=tree.visual
	sprite.texture=original.texture
	sprite.pixel_size=original.pixel_size
	sprite.offset=original.offset
	sprite.position=original.position
	root_piece.node.mesh=original.mesh
	root_piece.cut=original.cut
	root_piece.drop=original.drop
	tree.erase("extra_id")
	sprite.material_override.set_shader_parameter("root_cut_y",root_piece.cut if world.contact_enabled else 1.)
	_sync_paint()

func _build_sign() -> void:
	sign_root=Node3D.new()
	sign_root.name="PaintedWayfinding62"
	var at: Vector2=world._junction_sign_position()
	sign_root.position=Vector3(at.x,world.floor_height(at),at.y)
	add_child(sign_root)
	var profile: Dictionary=profiles.painted_sign
	var texture: Texture2D=preload("res://assets/landmark63/painted_sign.png")
	var foot := Vector2(profile.foot[0],profile.foot[1])
	var height := 2.15
	var scale_px: float=height/float(profile.height)
	sign_sprite=world._sprite(texture,foot,height,float(profile.height))
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/forest_cutout17.gdshader")
	material.set_shader_parameter("paint",texture)
	material.set_shader_parameter("fade",1.)
	material.set_shader_parameter("alpha_threshold",.55)
	sign_sprite.material_override=material
	sign_sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sign_root.add_child(sign_sprite)
	world.porch49.shade_material(material)
	# Text remains editable, localized game text over the empty painted boards.
	var centers := [Vector2(525,432),Vector2(520,741),Vector2(520,1072)]
	for i in 3:
		var label := Label3D.new()
		label.text=["↑ 出发站","← 林地","湖岸 →"][i]
		label.font_size=42
		label.pixel_size=.0035
		label.position=Vector3((centers[i].x-foot.x)*scale_px,(foot.y-centers[i].y)*scale_px,.035)
		label.rotation.z=-.10
		label.modulate=Color("543c25")
		label.outline_size=0
		sign_root.add_child(label)

func set_sign(enabled: bool) -> void:
	painted_sign=enabled
	sign_root.visible=enabled
	if is_instance_valid(sign_shadow63):
		sign_shadow63.enabled=enabled
		sign_shadow63.update_shadow()
	for child in world.old_sign62: child.visible=not enabled
	# The original post collision stays active in either visual mode.

func _build_tree_contact() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in 6:
		for column in 8:
			for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var uv: Vector2=(Vector2(column,row)+corner)/Vector2(8,6)
				var at: Vector2=Vector2(tree.root.position.x,tree.root.position.z)+(uv-Vector2(.5,.5))*Vector2(4.8,3.2)+Vector2(0,.2)
				st.set_normal(Vector3.UP)
				st.set_uv(uv)
				st.add_vertex(Vector3(at.x,world.floor_height(at)+.035,at.y))
	var node := MeshInstance3D.new()
	node.name="GreatTreeRootContact62"
	node.mesh=st.commit()
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := ShaderMaterial.new()
	material.shader=preload("res://scripts/art/garden_contact45.gdshader")
	material.set_shader_parameter("strength",.38)
	node.material_override=material
	add_child(node)

