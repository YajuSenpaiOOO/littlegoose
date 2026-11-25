extends "res://scripts/combat/flight_visual383.gd"
var charge_state:=preload("res://scripts/art/front_charge_state_20261116.gd").new()
var charge_poses: Array[Texture2D]=[]
var regions: Array[Rect2]=[]
var anchors: Array[Vector2]=[]
var density:=1.44/1013.
var mouth:=Vector3(0,.77,.025)
func _ready() -> void:
 super._ready()
 var layout: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://art/concepts/black_goose_charge_two_hands_20261116/layout.json"))
 density=layout.density
 for r in layout.regions:regions.append(Rect2(r[0],r[1],r[2],r[3]))
 for a in layout.anchors:anchors.append(Vector2(a[0],a[1]))
 var sheet:=ImageTexture.create_from_image(Image.load_from_file("res://art/concepts/black_goose_charge_two_hands_20261116/charge-release.png"))
 for region in regions:charge_poses.append(atlas381(sheet,region))
func advance_charge(dt: float,held: bool) -> void:
 charge_state.advance(dt,held,battle.combat_paused)
 super._process(dt)
 var charging: bool=charge_state.phase=="charge"
 var active: bool=charge_state.phase!="idle"
 var index: int=0 if charging else 1
 body379.texture=charge_poses[index] if active else front_body381
 body379.offset=Vector2(regions[index].size.x*.5-anchors[index].x,anchors[index].y-regions[index].size.y*.5) if active else Vector2(-25,423)
 body379.pixel_size=density if active else 1.44/860.
 body379.material_override.albedo_texture=body379.texture.atlas
 if charging:
  position.z+=.02*charge_state.ratio
  position.y-=.018*charge_state.ratio
  position.x+=sin(clock380*TAU*7.)*.002*charge_state.ratio
 position.z-=charge_state.kick*1.8
 update_shadow380()
func stored_cast_point() -> Vector3:
 # Preview only: the two-handed exhalation releases from in front of the mouth.
 return to_global(mouth)
