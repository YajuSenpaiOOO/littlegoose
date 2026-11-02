extends Node3D
var battle: Node3D
var core263: MeshInstance3D
func _ready() -> void:
 core263=MeshInstance3D.new();var plane=PlaneMesh.new();plane.size=Vector2.ONE*.26;plane.orientation=PlaneMesh.FACE_Z;core263.mesh=plane
 var ink=ShaderMaterial.new();ink.shader=preload("res://scripts/combat/red_beacon263.gdshader");core263.material_override=ink
 core263.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(core263);hide()
func _process(_delta: float) -> void:
 visible=battle.active114 and battle.flashlight_red229()
 if not visible:return
 var hero=battle.hero;var pulse: float=battle.red_pulse263()
 core263.global_position=hero.visual.to_global(Vector3(0,.72,.035));core263.global_basis=battle.camera.global_basis
 core263.material_override.set_shader_parameter("pulse263",pulse)
