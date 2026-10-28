extends "res://scripts/combat/paper_coverage151.gd"
func delivery_count150() -> int: return 9 if battle.scatter152 else 6
func spacing150() -> float: return 0. if battle.scatter152 else super.spacing150()
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 super.launch146(packet,origin,target,gain,replay)
 if not battle.scatter152: return
 var f: Dictionary=planes149[-1];f.coverage151=[];f.packet.scatter152=true
 for spec in f.packet.specs: spec.tracking=0
 for i in 9:
  var a := flight_rng146.randf_range(0.,TAU);var radius := sqrt(flight_rng146.randf())*COVERAGE151
  var aim: Vector3=f.mark+Vector3(cos(a),0,sin(a))*radius
  aim.y=battle.floor_height(Vector2(aim.x,aim.z))+.05;f.coverage151.append(aim)
func drop150(f: Dictionary,index: int) -> void:
 if not battle.scatter152: super.drop150(f,index);return
 var when := drop_time150(f,index);var origin := point150(f,when);var aim: Vector3=f.coverage151[index]
 send146(f.packet,origin,aim,float(f.gain)/9.)
 if f.packet.stream and not bursts146.is_empty(): bursts146[-1].flight150=f
 drops149+=1;deliveries146+=1;last_origin146=origin
 history149.append({"origin":origin,"mark":f.mark,"aim":aim,"sample":aim,"index":index,"age":when,"packet":f.packet,"target_id":0})
 if history149.size()>96: history149.pop_front()
func _process(delta: float) -> void:
 super._process(delta)
 if battle.buffs.level("paper_plane")>0:
  var mode := "随机九发齐射 · 不追踪" if battle.scatter152 else "辅助六连投 · 圈内分配"
  hud146.text=mode+" · 在空%d架\n"%planes149.size()+hud146.text.get_slice("\n",1)+"\n"+hud146.text.get_slice("\n",2)
 if hud146.visible and battle.trial152:
  hud146.text+="\n本段伤害 %.1f · 命中%d · 击倒%d"%[battle.damage152,battle.hits152,battle.kills152]
  hud146.position.y-=28.
