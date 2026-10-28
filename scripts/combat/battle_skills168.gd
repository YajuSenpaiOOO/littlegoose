extends "res://scripts/combat/battle_skills167.gd"
const SPACING168 := .72
var pool168: Array[Node3D]=[]
var path168: Array[Vector3]=[]
var cluster168 := false
func sync_geese110() -> void:
 var levels: Dictionary=battle.buffs.levels
 var count := int(levels.get("forest_fireboy",0))+2*int(levels.get("three_player",0))+3*int(levels.get("boarding_school",0))
 cluster168=int(levels.get("boarding_school",0))>0
 while pool168.size()<count:
  var goose: Node3D=preload("res://scripts/combat/goose168.gd").new();goose.battle=battle;goose.index168=pool168.size()
  battle.add_child(goose);battle._add_actor_shadow(goose,goose.visual);pool168.append(goose)
 geese110.clear()
 for i in pool168.size():
  pool168[i].visible=i<count
  if i<count:
   pool168[i].cup_phone=int(levels.get("cup_phone",0))>0;geese110.append(pool168[i])
 reset_path168()
func reset_path168() -> void:
 path168.clear()
 if not is_instance_valid(battle.goose): return
 var at: Vector3=battle.goose.position
 var direction := Vector3(battle.hero.velocity.x,0.,battle.hero.velocity.z).normalized()
 if direction.length_squared()<.01: direction=Vector3.FORWARD
 for i in 25: path168.append(at-direction*float(i)*.32)
 for goose in geese110: goose.follow168.reset();goose.update_follow(0.,at+Vector3.RIGHT,true)
func sample_path168(distance: float) -> Vector3:
 if path168.is_empty(): return battle.goose.position
 for i in path168.size()-1:
  var length := path168[i].distance_to(path168[i+1])
  if distance<=length: return path168[i].lerp(path168[i+1],distance/maxf(.0001,length))
  distance-=length
 return path168[-1]
func position_for168(index: int) -> Vector3:
 var p: Vector3
 if cluster168:
  var angle := TAU*float(index)/maxi(4,geese110.size())+.4
  var radius := .39+float(index%2)*.10
  p=battle.goose.position+Vector3(cos(angle)*radius,0.,sin(angle)*radius)
 else: p=sample_path168(SPACING168*float(index+1))
 p.y=battle.floor_height(Vector2(p.x,p.z))+.43;return p
func record_path168() -> void:
 var at: Vector3=battle.goose.position
 if path168.is_empty() or at.distance_to(path168[0])>5.: reset_path168();return
 if at.distance_to(path168[0])<.035: return
 path168.push_front(at)
 var distance := 0.
 for i in path168.size()-1:
  distance+=path168[i].distance_to(path168[i+1])
  if distance>8. or i>=254: path168.resize(i+2);break
func reset110() -> void:
 super.reset110();reset_path168()
func step110(delta: float) -> void:
 if not battle.combat_paused: record_path168()
 # The legacy beam cadence also read the old three-player penalty directly.
 battle.buffs.math_scope168+=1;super.step110(delta);battle.buffs.math_scope168-=1
