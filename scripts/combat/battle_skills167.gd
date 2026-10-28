extends "res://scripts/combat/battle_skills166.gd"
const DELAY167 := .10
const GAP167 := .15
var marks167: Array[Dictionary]=[]
var pulses167 := 0
var stopped_dashes167 := {}
func reset110() -> void:
 super.reset110();marks167.clear();stopped_dashes167.clear()
func reserve_stop167(dash: int) -> bool:
 if stopped_dashes167.has(dash): return false
 stopped_dashes167[dash]=true
 if stopped_dashes167.size()>8: stopped_dashes167.erase(stopped_dashes167.keys()[0])
 return true
func step110(delta: float) -> void:
 # Disable only the old immediate exercise hit while retaining the other skills.
 var exercise: int=battle.buffs.level("exercise")
 battle.buffs.levels["exercise"]=0;super.step110(delta)
 if exercise>0: battle.buffs.levels["exercise"]=exercise
 else: battle.buffs.levels.erase("exercise")
 if not battle.active114 or battle.player_hp<=0. or battle.result_open:
  marks167.clear();return
 if battle.combat_paused or battle.wave_state!="fighting" or battle.result_open: return
 if exercise>0 and battle.hero.dash_left>0.:
  for enemy in battle.near_enemies110(Vector2(battle.hero.position.x,battle.hero.position.z),1.5):
   var id: int=enemy.get_instance_id()
   if enemy.dead or dash_hits110.has(id): continue
   dash_hits110[id]=true
   marks167.append({"target":weakref(enemy),"at":enemy.hit_area.global_position,"dash":battle.hero.dash_count,"age":0.,"released":false,"next":0,"damage":battle.projectile_damage()*.2})
   dance_events166+=1
 for i in range(marks167.size()-1,-1,-1):
  var mark: Dictionary=marks167[i];var target: Variant=mark.target.get_ref()
  if not is_instance_valid(target) or target.dead or exercise<=0: marks167.remove_at(i);continue
  mark.at=target.hit_area.global_position
  if not mark.released:
   if battle.hero.dash_count==mark.dash and battle.hero.dash_left>0.: continue
   mark.released=true;mark.age=0.
  mark.age+=delta
  while mark.next<3 and mark.age>=DELAY167+float(mark.next)*GAP167:
   var impulse: Vector2=target.impulse
   target.impact_contact=mark.at;target.receive_hit(float(mark.damage)/3.,Vector3.ZERO)
   if not target.dead: target.impulse=impulse
   mark.next+=1;pulses167+=1
   if reserve_stop167(mark.dash): battle.hitstop(.035,true)
   if target.dead: break
  if target.dead or mark.age>.80: marks167.remove_at(i)
func _draw() -> void:
 super._draw()
 for mark in marks167:
  var at: Vector3=mark.at
  if battle.camera.is_position_behind(at): continue
  var centre := screen110(at);var pixel := clampf(pixels110(at),.6,2.)
  var age: float=mark.age if mark.released else 0.
  var remain := 3-int(mark.next)
  for j in remain:
   var phase: float=age*2.+float(j)*TAU/3.
   burst166(centre+Vector2(sin(phase)*17.,-22.+cos(phase)*3.)*pixel,4.*pixel,Color(1.,.94,.68,.8))
  if not mark.released: continue
  for beat in 3:
   var t := (age-DELAY167-float(beat)*GAP167)/.28
   if t<0. or t>1.: continue
   var turn: float=[-.65,.70,1.8][beat]
   var points := PackedVector2Array()
   for j in 19:
    var angle := -2.3+float(j)/18.*3.7
    points.append(centre+Vector2(cos(angle)*30.,sin(angle)*14.).rotated(turn)*pixel*(.75+t*.4))
   var colors := [Color("9cdef0"),Color("ffe4a3"),Color("efb5d2")]
   var color: Color=colors[beat];color.a=sin(t*PI)*.95
   draw_polyline(points,Color(.35,.28,.40,color.a*.55),7.*pixel,false)
   draw_polyline(points,color,4.5*pixel,false)
   draw_polyline(points,Color(1.,.99,.91,color.a),1.6*pixel,false)
   draw_circle(points[-1],2.3*pixel,color)
   burst166(centre+Vector2(17.-float(beat)*16.,-16.+float(beat)*8.)*pixel,(6.+4.*sin(t*PI))*pixel,Color(1.,.95,.68,color.a))
