extends "res://scripts/art/sister_battle220.gd"
var sheet222: Texture2D
var frames222: Array[AtlasTexture]=[]
var layout222: Dictionary
var original222: Texture2D
var original_offset222 := Vector2.ZERO
var original_anchor222 := Vector2.ZERO
var original_pixel222 := 0.
var frame222 := -2
var ready222 := false
func _ready() -> void:
 super._ready();name="SisterRepair222"
 original222=seated.texture;original_offset222=seated.offset
 original_anchor222=seated.get_meta("anchor205");original_pixel222=seated.pixel_size
 layout222=JSON.parse_string(FileAccess.get_file_as_string("res://assets/sister222/layout.json"))
 sheet222=load("res://assets/sister222/sewing_sheet.png")
 for data in layout222.frames:
  var atlas=AtlasTexture.new();atlas.atlas=sheet222;atlas.region=Rect2(data.region[0],data.region[1],data.region[2],data.region[3]);atlas.filter_clip=true;frames222.append(atlas)
 ready222=true;pose222(-1)
func select_frame222() -> int:
 if not world.active114:return -1
 var phase: String=world.battle_phase220;var t: float=world.phase_age220
 if phase=="lower" and t>=1.1:return 0
 if phase=="repair":
  if t<.4:return 1
  if t>=5.6:return 5
  return [2,3,4,3][int((t-.4)/.2)%4]
 if phase=="rise" and t<.2:return 5
 return -1
func pose222(index: int) -> void:
 if index==frame222:return
 frame222=index
 var ink: ShaderMaterial=seated.material_override
 if index<0:
  seated.texture=original222;seated.offset=original_offset222;seated.pixel_size=original_pixel222
  seated.set_meta("anchor205",original_anchor222);ink.set_shader_parameter("paint",original222)
 else:
  var data: Dictionary=layout222.frames[index];var anchor=Vector2(data.anchor[0],data.anchor[1])
  seated.texture=frames222[index];seated.pixel_size=original_pixel222*float(layout222.reference_alpha_height)/float(layout222.neutral_alpha_height)
  var size=seated.texture.get_size();seated.offset=Vector2(size.x*.5-anchor.x,anchor.y-size.y*.5)
  seated.set_meta("anchor205",anchor);ink.set_shader_parameter("paint",sheet222)
func _process(delta: float) -> void:
 if ready222:pose222(select_frame222())
 super._process(delta)
