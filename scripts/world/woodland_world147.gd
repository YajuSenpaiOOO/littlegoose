extends "res://scripts/world/woodland_world146.gd"
const MAX_SHOTS147 := 256
var random_planes147 := true
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_patrol147.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud147.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 147 · 随机巡航 / 失速降落")
func _ready() -> void:
 super._ready()
 while not hill_ready146: await get_tree().physics_frame
 if "--patrol147" in OS.get_cmdline_user_args(): paper_trial129=true;start_combat()
func attack_cooldown() -> float:
 if random_planes147 and buffs.level("paper_plane")>0: return 1.1
 return super.attack_cooldown()
func capture146(target: Vector3,charged: bool,ratio: float) -> void:
 if not random_planes147 or buffs.level("paper_plane")==0: super.capture146(target,charged,ratio);return
 if paper_memories146.patrol147.size()>=3 or not paper_memories146.pending146.is_empty(): return
 var packet := snapshot_packet146(target,charged,ratio,true,false)
 if packet.is_empty(): return
 packet.charged147=charged;packet.ratio147=ratio
 paper_memories146.record146(packet);paper_memories146.launch146(packet,projectile_origin(),target)
func patrol_interval147(charged: bool) -> float:
 var interval: float=.04/(buffs.rate()*(1.+.6*(1.-player_hp/100.))) if buffs.level("flashlight")>0 else START_INTERVAL113/buffs.rate()
 if charged: interval=maxf(interval,1.1)
 if buffs.level("three_player")>0: interval*=2.
 return maxf(.05,interval)
func drop_patrol147(origin: Vector3,ground: Vector3,gain: float,charged: bool,ratio: float) -> void:
 var quiet := fragment_emitting110;fragment_emitting110=true
 var recoil: Vector2=goose.spring_velocity
 var packet := snapshot_packet146(ground,false,0.,true,false)
 fragment_emitting110=quiet;goose.spring_velocity=recoil
 if packet.is_empty(): return
 if charged and not packet.stream:
  var power := (1.+(11.+2.*float(buffs.level("slingshot")-1))*ratio)*(Profile.FIRE_CD/START_INTERVAL113 if slow_start113 else 1.)
  for spec in packet.specs:
   spec.damage=float(spec.damage)*power;spec.charged=true;spec.piercing110=true;spec.speed=(320.+430.*ratio)/Profile.PPM;spec.gain=lerpf(1.2,2.2,ratio)
 stream_generation110+=1
 # Tilt multi-lanes on a downward cone; yaw alone cannot fan a vertical vector.
 for i in packet.specs.size():
  if shots.size()>=MAX_SHOTS147: break
  var spec: Dictionary=packet.specs[i];var one := packet.duplicate(true);one.specs=[spec]
  var spread := Vector3(cos(float(i)*2.4),0,sin(float(i)*2.4))*(absf(float(spec.angle))*.9)
  spec.angle=0.;spec.life=minf(float(spec.life),.9)
  emit_packet146(one,origin,ground+spread,gain,stream_generation110)
func _flush_splits113() -> void:
 if random_planes147:
  var room := maxi(0,(MAX_SHOTS147-shots.size())/6)
  if pending_splits110.size()>room: pending_splits110.resize(room)
 super._flush_splits113()
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F8 and hill_ready146 and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  _cancel_charge();_clear_combat_shots();random_planes147=not random_planes147;cooldown=0.;fire_needs_release=true
  if is_instance_valid(encounter_hud): encounter_hud.announce("随机巡航" if random_planes147 else "瞄准后投递","F8切换对照 · 1—6换组合 · Q翻阅笔记",2.5)
  get_viewport().set_input_as_handled();return
 super._input(event)
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if hill_ready146 and paper_trial129: encounter_hud.announce("随机巡航试验" if random_planes147 else "瞄准投递对照","左键放飞 · 最多3架 · F8切换模式 · 1—6换组合 · Q用笔记",3.)
