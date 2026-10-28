extends "res://scripts/combat/world_reticle23.gd"
var guide_mesh: MeshInstance3D
var guide_geometry := ImmediateMesh.new()
var guide_ink: StandardMaterial3D
var endpoint: MeshInstance3D
var line_origin := Vector3.ZERO
var line_end := Vector3.ZERO
var path_hit: Dictionary = {}
var reached_target := false

func _ready() -> void:
	super._ready()
	guide_mesh = MeshInstance3D.new()
	guide_mesh.name = "ActualMuzzleTrajectory"
	guide_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	guide_mesh.mesh = guide_geometry
	guide_ink = material(Color(1.,.9,.65,.62))
	guide_mesh.material_override = guide_ink
	add_child(guide_mesh)
	endpoint = MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = .045
	mesh.height = .09
	mesh.radial_segments = 8
	mesh.rings = 3
	endpoint.mesh = mesh
	endpoint.material_override = guide_ink
	endpoint.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(endpoint)

func trajectory_target(at: Vector3,_origin: Vector3) -> Vector3:
	return at

func update_target(at: Vector3) -> void:
	# Retain the exact cursor brackets. Only replace the positional aid below it.
	super.update_target(at)
	if not is_instance_valid(guide_mesh): return
	var enabled: bool = battle.aim_guide_mode==0 and visible
	guide_mesh.visible = enabled
	endpoint.visible = enabled
	ground_ring.visible = battle.aim_guide_mode==1
	stem.visible = ground_ring.visible
	if not enabled: return
	line_origin = battle.preview_projectile_origin()
	var travel := trajectory_target(at,line_origin)-line_origin
	if travel.length()<.05:
		guide_mesh.hide(); endpoint.hide(); return
	var direction := travel.normalized()
	var reach: float = battle.projectile_speed()*battle.Profile.BULLET_LIFE+5./battle.Profile.PPM
	var wanted := line_origin+direction*minf(travel.length()+.06,reach)
	path_hit = battle.legacy_trace(line_origin,wanted)
	line_end = path_hit.position if not path_hit.is_empty() else wanted
	reached_target = not path_hit.is_empty() and path_hit.collider.has_meta("enemy")
	var blocked := not path_hit.is_empty() and not reached_target
	guide_ink.albedo_color = Color(1.,.47,.25,.75) if blocked else Color(.75,1.,.72,.72) if reached_target else Color(1.,.9,.65,.56)
	endpoint.position = line_end
	guide_geometry.clear_surfaces()
	guide_geometry.surface_begin(Mesh.PRIMITIVE_LINES)
	var length := line_origin.distance_to(line_end)
	var count := maxi(1,ceili(length/.32))
	for i in count:
		var a := float(i)/count
		var b := minf((float(i)+.64)/count,1.)
		guide_geometry.surface_add_vertex(line_origin.lerp(line_end,a))
		guide_geometry.surface_add_vertex(line_origin.lerp(line_end,b))
	# Original spread remains an explicit, faint envelope in the comparison mode.
	var spread: float = battle.weapon_spread_radians()
	if spread>0.:
		for side in [-1.,1.]:
			guide_geometry.surface_add_vertex(line_origin)
			guide_geometry.surface_add_vertex(line_origin+direction.rotated(Vector3.UP,spread*side)*length)
	guide_geometry.surface_end()
