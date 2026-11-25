extends Node2D

const LIFE:=.42
var bursts:Array[Dictionary]=[]
var sound:AudioStreamPlayer

func _ready() -> void:
 sound=AudioStreamPlayer.new()
 sound.stream=preload("res://assets/music235/67_perfect.wav")
 sound.volume_db=-20.
 add_child(sound)
 set_process(false)

func burst(at:Vector3,tint:Color) -> void:
 bursts.append({"at":at,"tint":tint,"age":0.})
 if not sound.playing:sound.play()
 set_process(true)

func _process(delta:float) -> void:
 for effect in bursts:effect.age+=delta
 bursts=bursts.filter(func(effect:Dictionary):return effect.age<LIFE)
 queue_redraw()
 if bursts.is_empty():set_process(false)

func _draw() -> void:
 var camera:=get_viewport().get_camera_3d()
 if camera==null:return
 for effect in bursts:
  if camera.is_position_behind(effect.at):continue
  var phase:float=effect.age/LIFE
  var center:=camera.unproject_position(effect.at)
  for i in 6:
   var angle:=TAU*i/6.+.31
   var at:=center+Vector2.from_angle(angle)*lerpf(3.,27.+float(i%3)*4.,ease(phase,.53))+Vector2.UP*13.*phase
   var size:=lerpf(3.5,1.,phase)
   draw_colored_polygon(PackedVector2Array([at-Vector2(0,size*1.4),at+Vector2(size,0),at+Vector2(0,size*1.4),at-Vector2(size,0)]),
    Color(effect.tint,(1.-phase)*.83))
