extends "res://scripts/combat/goose_follow373.gd"
func setup373() -> void:
 await super.setup373()
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/black_goose_walk374/frames.json"))
 for key in data:
  var row: Dictionary=data[key];var sheet: Texture2D=host.room.source356("res://assets/black_goose_walk374/"+row.file)
  var frames: Array[Texture2D]=[]
  for i in 4:
   var texture:=AtlasTexture.new();texture.atlas=sheet;texture.region=Rect2(i*row.cell[0],0,row.cell[0],row.cell[1]);texture.filter_clip=true;frames.append(texture)
  atlas373[key]={"frames":frames,"foot":Vector2(row.foot[0],row.foot[1]),"height":float(row.height)}

var preview374:=0
func frame_index373(walking: bool) -> int:
 if walking and direction373 in ["left","right"]:return [1,2,3,2][int(clock373*8.)%4]
 return super.frame_index373(walking)
func _physics_process(delta: float) -> void:
 if preview374>0 and ready373 and not host.sleeping362 and not host.leaving371:
  clock373+=delta;velocity=Vector3.ZERO
  direction373="left" if preview374==1 else "right"
  apply_frame373([1,2,3,2][int(clock373*4.)%4]);return
 super._physics_process(delta)
