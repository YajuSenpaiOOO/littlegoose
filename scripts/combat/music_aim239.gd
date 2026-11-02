extends "res://scripts/combat/music_aim238.gd"
var ghosts239: Array[Dictionary]=[]
var ghost_count239 := 0
func result237(kind: String,offset: float) -> void:
 super.result237(kind,offset)
 if kind in ["early","late"]:text237="GREAT ×1.2 · "+("偏早" if offset<0. else "偏晚");color237=Color("a2dedc")
 if kind=="miss_shot":text237="MISS · 空弹";color237=Color("b9a7b6")
func ghost239(target: Vector3) -> void:
 var start=battle.camera.unproject_position(battle.projectile_origin())
 var toward=battle.camera.unproject_position(target)-start
 if toward.length_squared()<1.:toward=Vector2.RIGHT
 ghosts239.append({"start":start,"dir":toward.normalized(),"age":clock237})
 ghost_count239+=1
 while ghosts239.size()>96:ghosts239.pop_front()
func _process(delta: float) -> void:
 super._process(delta)
 for i in range(ghosts239.size()-1,-1,-1):
  if clock237-float(ghosts239[i].age)>.28:ghosts239.remove_at(i)
func _draw() -> void:
 super._draw()
 if not active117 or not battle.music_running236():return
 for ghost in ghosts239:
  var u=clampf((clock237-float(ghost.age))/.28,0.,1.)
  var at: Vector2=ghost.start+ghost.dir*u*160.
  draw_line(at-Vector2(ghost.dir)*11.,at,Color(.78,.69,.78,(1.-u)*.45),3.,true)
  draw_circle(at,3.,Color(.88,.80,.88,(1.-u)*.6))
