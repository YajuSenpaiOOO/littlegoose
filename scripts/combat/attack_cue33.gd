extends MeshInstance3D
var enemy: CharacterBody3D

func _ready() -> void:
	top_level=true
	global_transform=Transform3D.IDENTITY
	var ink := StandardMaterial3D.new()
	ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	ink.vertex_color_use_as_albedo=true
	ink.cull_mode=BaseMaterial3D.CULL_DISABLED
	material_override=ink
	cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _process(_delta: float) -> void:
	visible=not enemy.dead and enemy.battle.tactical_combat and enemy.attack_phase=="windup"
	if not visible or enemy.battle.combat_paused: return
	var at := Vector2(enemy.global_position.x,enemy.global_position.z)
	var forward: Vector2=enemy.attack_direction
	var side := forward.orthogonal()
	var progress: float=clampf(enemy.phase_clock/enemy.WINDUP,0.,1.)
	var color := Color(.96,.80,.48).lerp(Color(.98,.58,.31),progress)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 20:
		var a := -1.6+3.2*float(i)/20.
		var b := -1.6+3.2*float(i+1)/20.
		_segment(st,at+forward.rotated(a)*1.05,at+forward.rotated(b)*1.05,.06,color)
	var tip := at+forward*1.50
	_segment(st,at+forward*.88,tip,.04,color)
	_segment(st,tip,at+forward*1.25+side*.16,.04,color)
	_segment(st,tip,at+forward*1.25-side*.16,.04,color)
	mesh=st.commit()

func _segment(st: SurfaceTool,a: Vector2,b: Vector2,width: float,color: Color) -> void:
	var side := (b-a).normalized().orthogonal()*width*.5
	for point: Vector2 in [a-side,a+side,b+side,a-side,b+side,b-side]:
		st.set_color(color)
		st.add_vertex(Vector3(point.x,enemy.battle.floor_height(point)+.065,point.y))
