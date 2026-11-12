extends "res://scripts/art/elastic_visual275.gd"
var ball276: Texture2D=preload("res://assets/bouncy_ball276/ball.png")
var source276: Rect2
func _ready() -> void:
 var data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/bouncy_ball276/layout.json"))
 var b=data.visible_bbox;source276=Rect2(b[0],b[1],b[2]-b[0],b[3]-b[1])
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
func palette276(_shot: Dictionary) -> Color:return Color.WHITE
func _draw() -> void:
 if source276.size.x<=0.:return
 var count=0
 for shot in battle.shots:
  if not shot.get("elastic275",false) or shot.get("stream110",false):continue
  if count>=256:break
  count+=1
  var at: Vector3=shot.node.get_global_transform_interpolated().origin
  if battle.camera.is_position_behind(at):continue
  var p=battle.camera.unproject_position(at);var diameter=8.*battle.skills110.pixels110(at)
  var size=source276.size/source276.size.x*diameter
  draw_texture_rect_region(ball276,Rect2(p-size*.5,size),source276,palette276(shot))
 for impact in impacts:
  if battle.camera.is_position_behind(impact.at):continue
  var p=battle.camera.unproject_position(impact.at);var t=impact.age/.24
  draw_arc(p,(3.+t*9.)*battle.skills110.pixels110(impact.at),0,TAU,16,Color(.65,.95,.9,1.-t),2.)
