extends "res://scripts/combat/flight_visual383.gd"
var charge_state:=preload("res://scripts/art/front_charge_state_20261116.gd").new()
var charge_poses: Array[Texture2D]=[]
const REGIONS=[Rect2(0,0,610,1254),Rect2(610,0,644,1254)]
const ANCHORS=[Vector2(320,1146),Vector2(337,1146)]
const DENSITY:=1.44/1013.
func _ready() -> void:
 super._ready()
 var sheet:=ImageTexture.create_from_image(Image.load_from_file("res://art/concepts/black_goose_charge_front_20261116/charge-release.png"))
 for region in REGIONS:charge_poses.append(atlas381(sheet,region))
func advance_charge(dt: float,held: bool) -> void:
 charge_state.advance(dt,held,battle.combat_paused)
 super._process(dt)
 var charging: bool=charge_state.phase=="charge"
 var active: bool=charge_state.phase!="idle"
 var index: int=0 if charging else 1
 body379.texture=charge_poses[index] if active else front_body381
 body379.offset=Vector2(REGIONS[index].size.x*.5-ANCHORS[index].x,ANCHORS[index].y-627.) if active else Vector2(-25,423)
 body379.pixel_size=DENSITY if active else 1.44/860.
 body379.material_override.albedo_texture=body379.texture.atlas
 if charging:
  position.z+=.02*charge_state.ratio
  position.y-=.008*charge_state.ratio
  position.x+=sin(clock380*TAU*7.)*.002*charge_state.ratio
 position.z-=charge_state.kick*1.5
 update_shadow380()
func stored_cast_point() -> Vector3:
 # Magic leaves the charged fist position, then the open hand recoils away.
 return to_global(Vector3((260.-320.)*DENSITY,(1146.-690.)*DENSITY,.025))
