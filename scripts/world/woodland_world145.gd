extends "res://scripts/world/woodland_world144.gd"
var hill_ready145 := false
var prop_shadows145: Node
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 145 · 拨开草叶 / 摆件投影 / 纸张素材")
func _hill_plants_script142() -> Script: return preload("res://scripts/art/hill_plants145.gd")
func _picnic_script144() -> Script: return preload("res://scripts/art/picnic_hill145.gd")
func painted_shadow_height145(at: Vector2) -> float:
 var height: float=floor_height(at)
 if is_instance_valid(picnic144) and picnic144.in_cloth144(Vector3(at.x,height,at.y),0.):
  height+=.045 # Above the 35 mm cloth and its small animated free corner.
 return height
func _ready() -> void:
 super._ready()
 while not hill_ready144: await get_tree().physics_frame
 prop_shadows145=preload("res://scripts/art/painted_prop_shadows145.gd").new();prop_shadows145.world=self;add_child(prop_shadows145)
 hill_ready145=true;_title35()
 if "--hill145" in OS.get_cmdline_user_args(): _teleport15(Vector2(meadow.landmarks.grove)+Vector2(-19.3,-26.5))
 print("PAPER_HILL145_READY projected_props=",prop_shadows145.registered145.size())
