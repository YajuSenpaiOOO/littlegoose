extends MeshInstance3D
var enemy: CharacterBody3D
const LEAD := .16

func _ready() -> void:
	top_level=true
	visible=false
	var ink := StandardMaterial3D.new()
	ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	ink.albedo_color=Color(1.,.91,.64)
	ink.cull_mode=BaseMaterial3D.CULL_DISABLED
	material_override=ink
	cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Small four-point glint, with real depth testing so trees can hide it.
	var points: Array[Vector3]=[Vector3(0,1,0),Vector3(.18,.18,0),Vector3(.7,0,0),Vector3(.18,-.18,0),Vector3(0,-1,0),Vector3(-.18,-.18,0),Vector3(-.7,0,0),Vector3(-.18,.18,0)]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in points.size():
		st.add_vertex(Vector3.ZERO)
		st.add_vertex(points[i])
		st.add_vertex(points[(i+1)%points.size()])
	mesh=st.commit()

func _process(_delta: float) -> void:
	visible=enemy.battle.small_attack_cue and enemy.battle.tactical_combat and not enemy.dead and enemy.attack_phase=="windup" and enemy.phase_clock>=enemy.WINDUP-LEAD
	if not visible: return
	var progress: float=clampf((enemy.phase_clock-(enemy.WINDUP-LEAD))/LEAD,0.,1.)
	var height: float=float(enemy.poses.anticipation.visible_height)/24.*enemy.visual.scale.y
	global_position=enemy.global_position+Vector3(0,enemy.visual.position.y+height+.15,0)
	global_basis=enemy.battle.camera.global_basis.scaled(Vector3.ONE*lerpf(.065,.10,smoothstep(0.,.5,progress)))
