extends "res://scripts/combat/battle_skills146.gd"
var dance166: Array[Dictionary]=[]
var dance_events166 := 0
var stop_dash166 := -1
func reset110() -> void:
 super.reset110();dance166.clear();stop_dash166=-1
func step110(delta: float) -> void:
 var before: Dictionary=dash_hits110.duplicate() if battle.hero.dash_count==dash_id110 else {}
 super.step110(delta)
 if battle.combat_paused or battle.wave_state!="fighting" or battle.result_open: return
 for i in range(dance166.size()-1,-1,-1):
  dance166[i].age+=delta
  if dance166[i].age>.38: dance166.remove_at(i)
 if battle.buffs.level("exercise")<=0: return
 for enemy in battle.enemies:
  if not is_instance_valid(enemy): continue
  var id: int=enemy.get_instance_id()
  if before.has(id) or not dash_hits110.has(id): continue
  dance166.append({"target":weakref(enemy),"at":enemy.hit_area.global_position,"age":0.})
  dance_events166+=1
  while dance166.size()>12: dance166.pop_front()
  if stop_dash166!=battle.hero.dash_count:
   stop_dash166=battle.hero.dash_count;battle.hitstop(.035,true)
func burst166(at: Vector2,radius: float,color: Color) -> void:
 var points := PackedVector2Array()
 for i in 8:
  var a := TAU*float(i)/8.;points.append(at+Vector2(cos(a),sin(a))*radius*(1. if i%2==0 else .32))
 draw_colored_polygon(points,color)
func _draw() -> void:
 super._draw()
 for event in dance166:
  var target: Variant=event.target.get_ref()
  if is_instance_valid(target) and not target.dead: event.at=target.hit_area.global_position
  var at: Vector3=event.at
  if battle.camera.is_position_behind(at): continue
  var centre := screen110(at);var pixel := clampf(pixels110(at),.6,2.)
  var age: float=event.age
  if age<.055: burst166(centre,18.*pixel,Color(1.,.97,.79,(1.-age/.055)*.85))
  for beat in 3:
   var t := (age-.045-float(beat)*.075)/.14
   if t<0. or t>1.: continue
   var turn: float=[-.65,.70,1.8][beat]
   var points := PackedVector2Array()
   for j in 17:
    var u := float(j)/16.;var angle: float=-2.3+u*3.7
    var p := Vector2(cos(angle)*28.,sin(angle)*12.).rotated(turn)*pixel
    points.append(centre+p*(.75+t*.4))
   var colors := [Color("9cdef0"),Color("ffe4a3"),Color("efb5d2")]
   var color: Color=colors[beat];color.a=sin(t*PI)*.90
   draw_polyline(points,Color(.35,.28,.40,color.a*.55),7.*pixel,false)
   draw_polyline(points,color,4.5*pixel,false)
   draw_polyline(points,Color(1.,.99,.91,color.a),1.6*pixel,false)
   draw_circle(points[-1],2.3*pixel,color)
   burst166(centre+Vector2(17.-float(beat)*16.,-16.+float(beat)*8.)*pixel,(5.+3.*sin(t*PI))*pixel,Color(1.,.95,.68,color.a))
