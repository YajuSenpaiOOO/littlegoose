extends "res://scripts/world/woodland_world124.gd"
const INITIAL125 := 6
const MAX_ACTIVE125 := 8
const JOIN_GAP125 := 3.5
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 125 · 团团自由扑击 / 六位开场")
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan125.gd")
func reserve_attack(enemy: CharacterBody3D) -> bool:
 # Each actor keeps its own windup/lunge/recovery. No global queue, token,
 # attacker cap or shared cooldown. Pause/scene lifecycle still gate combat.
 return not combat_paused and active114 and wave_state=="fighting" and between_left<=0. and player_hp>0. and is_instance_valid(enemy) and enemy.active_ai and not enemy.dead
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F6 and not event.ctrl_pressed and not event.alt_pressed:
  encounter_hud.announce("团团现在自由扑击","已取消攻击排队；各自保留准备与收招动作。",2.)
  return
 super._unhandled_input(event)
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if active114: next_join120=JOIN_GAP125
func _spawn_wave110(index: int) -> void:
 super._spawn_wave110(index)
 var occupied: Array[Vector2]=[]
 for actor in enemies:
  if is_instance_valid(actor): occupied.append(Vector2(actor.position.x,actor.position.z))
 var offsets := [Vector2(-5.,1.),Vector2(4.5,.5),Vector2(1.,-7.)]
 for i in INITIAL125-3:
  var at := _pick_spawn114(meadow.landmarks.grove+offsets[i],occupied);occupied.append(at)
  var actor := make_actor119(created120,at);enemies.append(actor);actor.play119();created120+=1
 rebuild_cells110()
func _step_outing119(delta: float) -> void:
 var alive := 0
 for actor in enemies:
  if is_instance_valid(actor) and not actor.dead: alive+=1
 # Begin the next group while five are still present, instead of waiting for
 # the old group to fall to two. Three entrants can fill eight live slots.
 if created120<BALANCE120.TOTAL and group_left120==0 and elapsed114>=next_join120 and alive<=MAX_ACTIVE125-BALANCE120.GROUP:
  var occupied: Array[Vector2]=[]
  for actor in enemies:
   if is_instance_valid(actor): occupied.append(Vector2(actor.position.x,actor.position.z))
  var count := mini(BALANCE120.GROUP,BALANCE120.TOTAL-created120)
  for i in count:
   var at := _pick_spawn114(meadow.landmarks.grove+Vector2(-6. if i%2==0 else 6.,-4.),occupied);occupied.append(at)
   standby119.append(make_actor119(created120+i,at))
  group_left120=count;notice119=1.2;encounter_hud.announce("“我们也来！”","更多团团沿路加入。",1.8)
 if group_left120>0:
  notice119-=delta
  if notice119<=0. and alive<MAX_ACTIVE125:
   var actor: CharacterBody3D=standby119.pop_front();enemies.append(actor);created120+=1;joined119+=1;group_left120-=1
   actor.join119(meadow.landmarks.grove+Vector2(-2. if created120%2==0 else 2.,-.6));rebuild_cells110();notice119=.65
   if group_left120==0: notice119=-1.;next_join120=elapsed114+JOIN_GAP125
 if ending119>=0.:
  ending119=maxf(0.,ending119-delta)
  if ending119<=0. and drops120.items120.is_empty(): won119=true;finish114()
