extends "res://scripts/art/pig_spray219.gd"
func advance219(delta: float) -> void:
 if not running219:return
 age219+=delta
 if phase219=="idle" and age219>=1.1:
  phase219="spray";age219=0.;emission219=0.
 elif phase219=="spray":
  emission219+=delta
  while emission219>=.3:
   emission219-=.3
   update_pose219();_process(0.)
   for i in 2:stream.emit219(nose219(i),direction219.rotated(-.1 if i==0 else .1),i)
  if age219>=2.2:phase219="idle";age219=-.7
 update_pose219()
