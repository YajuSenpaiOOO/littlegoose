@tool
extends Node3D
## Edit and save the Marker3D transforms in station_layout83.tscn.
## Previews are editor-only; runtime uses the same markers for art/collision/light.
func _ready() -> void:
	if not Engine.is_editor_hint(): return
	var material := StandardMaterial3D.new();material.albedo_color=Color(.38,.45,.34,.45)
	material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	for marker in get_children():
		if not marker is Marker3D: continue
		var size: Vector3=marker.get_meta("preview_size",Vector3(1,.5,1))
		var box := BoxMesh.new();box.size=size
		var node := MeshInstance3D.new();node.mesh=box;node.material_override=material;node.position.y=size.y*.5;marker.add_child(node)
		var label := Label3D.new();label.text=marker.name;label.pixel_size=.008;label.position.y=size.y+.35;marker.add_child(label)
		if marker.name=="Hall":
			node.position.z=-2.65
			var visual := Sprite3D.new();visual.texture=preload("res://assets/station81/hall.png")
			visual.pixel_size=14./1613.;visual.offset=Vector2(0,795.-887.*.5)
			visual.rotation_degrees.x=-25.;visual.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;marker.add_child(visual)
	var floor_node := MeshInstance3D.new();var plane := PlaneMesh.new();plane.size=Vector2(40,27)
	floor_node.mesh=plane;floor_node.position=Vector3(0,-.025,-6.5);floor_node.material_override=material;add_child(floor_node)
	var platform := MeshInstance3D.new();var deck := BoxMesh.new();deck.size=Vector3(40,.39,5.2)
	platform.mesh=deck;platform.position=Vector3(0,.195,-16.3);platform.material_override=material;add_child(platform)
	print("STATION_LAYOUT83_EDITOR_PREVIEW_READY")
	if "--check-station-layout83" in OS.get_cmdline_user_args(): get_tree().quit.call_deferred()
