extends Node2D
var battle: Node3D
var impacts: Array=[]
func hit275(at: Vector3) -> void:
 if impacts.size()<64:impacts.append({"at":at,"age":0.})
func _process(delta: float) -> void:
 if not battle.combat_paused:
  for impact in impacts:impact.age+=delta
  impacts=impacts.filter(func(i):return i.age<.24)
 queue_redraw()
func _draw() -> void:
 var count=0
 for shot in battle.shots:
  if not shot.get("elastic275",false) or shot.get("stream110",false):continue
  if count>=256:break
  count+=1
  var at: Vector3=shot.node.get_global_transform_interpolated().origin
  if battle.camera.is_position_behind(at):continue
  var p=battle.camera.unproject_position(at);var r=4.*battle.skills110.pixels110(at)
  var color=Color("ffbc74") if shot.get("bounces275",0)>0 else Color("8cdded")
  draw_circle(p,r+1.,Color("563a64"));draw_circle(p,r,color)
  draw_arc(p,r*.68,.2,2.8,9,Color("f5c6dd"),maxf(1.,r*.22))
  draw_circle(p+Vector2(-.28,-.35)*r,maxf(1.,r*.20),Color("fff7df"))
 for impact in impacts:
  if battle.camera.is_position_behind(impact.at):continue
  var p=battle.camera.unproject_position(impact.at);var t=impact.age/.24
  draw_arc(p,(3.+t*9.)*battle.skills110.pixels110(impact.at),0,TAU,16,Color(1.,.8,.55,1.-t),2.)
