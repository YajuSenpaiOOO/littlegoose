extends "res://scripts/world/frame_overlay67.gd"
func refresh(now: float) -> void:
 super.refresh(now)
 var alive := 0;var bits := 0;var drops := 0
 for enemy in world.enemies:
  if is_instance_valid(enemy) and not enemy.dead: alive+=1
 if is_instance_valid(world.jelly_fx):
  bits=world.jelly_fx.bits.size();drops=world.jelly_fx.drops.size()
 readout.text+="\n弹丸 %d · 碎片 %d · 果冻 %d · 敌人 %d"%[world.shots.size(),bits,drops,alive]
