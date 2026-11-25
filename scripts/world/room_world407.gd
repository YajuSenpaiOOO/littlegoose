extends "res://scripts/world/room_world406.gd"
func refresh367() -> void:
 if is_instance_valid(label367):label367.text=help367
func _ready() -> void:
 await super._ready()
 yard403.hide()
 yard403.door404.collision_layer=0
 room.box(room,Vector3(0,-.045,2.81),Vector3(2.05,.08,.22),"a69d85")
 var plane:=PlaneMesh.new();plane.size=Vector2(40,20)
 var ink:=StandardMaterial3D.new();ink.albedo_color=Color("292522");ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 var ground: MeshInstance3D=room.shape(room,plane,Vector3(0,-.06,12.93),ink);ground.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 help367="407 · 室内原尺寸 / 门槛切面\nWASD走动 · E查看/睡起 · F3出门\nF2昼夜 · F12跟随"
 refresh367()
