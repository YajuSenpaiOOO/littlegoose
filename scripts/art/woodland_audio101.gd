extends Node3D
## Two reusable spatial voices. Synthetic short cues, never a whole-map loop.
var world: Node3D
var enabled := true
var bird: AudioStreamPlayer3D
var rope: AudioStreamPlayer3D
var bird_wait := 4.
var rope_wait := 0.
var last_speed := 0.
var last_bump := 0
var bird_events := 0
var rope_events := 0
var scan_left := 0.
var rng := RandomNumberGenerator.new()
func _voice(at: Vector3,reach: float,unit: float,volume: float,stream: AudioStreamWAV) -> AudioStreamPlayer3D:
 var player := AudioStreamPlayer3D.new();player.position=at;player.max_distance=reach;player.unit_size=unit;player.volume_db=volume;player.stream=stream;add_child(player);return player
func _ready() -> void:
 name="LocalWoodlandAudio101";rng.seed=10191
 var listener := AudioListener3D.new();listener.position.y=.8;world.hero.add_child(listener);listener.make_current()
 var g: Vector2=world.meadow.landmarks.grove+Vector2(4,-7.5)
 bird=_voice(Vector3(g.x,world.floor_height(g)+4.5,g.y),22.,7.,-17.,_chirps())
 rope=_voice(world.park99.swing_origin97,14.,4.,-20.,_creak())
func set_enabled(value: bool) -> void:
 enabled=value
 if not enabled: bird.stop();rope.stop()
 print("WOODLAND101_AMBIENCE ","on" if enabled else "off")
func _process(delta: float) -> void:
 bird_wait-=delta;rope_wait=maxf(0.,rope_wait-delta);scan_left-=delta
 if scan_left>0.: return
 scan_left=.1
 var park: Node3D=world.park99
 var speed: float=park.angular_speed100
 var turn: bool=speed*last_speed<0. and absf(park.angle100)>.035
 var bump: bool=park.bump_count100!=last_bump
 last_speed=speed;last_bump=park.bump_count100
 if not enabled: return
 var hero: Vector3=world.hero.global_position
 if (turn or bump) and rope_wait<=0. and hero.distance_to(rope.position)<12.:
  rope.play();rope_wait=1.;rope_events+=1
 if bird_wait<=0.:
  bird_wait=rng.randf_range(9.,16.)
  if world.time55.visual_hour>7. and world.time55.visual_hour<19. and hero.distance_to(bird.position)<22.:
   bird.pitch_scale=rng.randf_range(.94,1.06);bird.play();bird_events+=1
func _chirps() -> AudioStreamWAV:
 var data := PackedFloat32Array();data.resize(int(.95*44100))
 for start in [0.,.29,.58]:
  var phase := 0.
  for j in int(.18*44100):
   var t := float(j)/44100.;phase+=TAU*(2400.+750.*sin(t*16.)+80.*sin(t*115.))/44100.
   data[int(start*44100)+j]+=.16*pow(sin(PI*t/.18),2.)*(sin(phase)+.16*sin(phase*2.))
 return CombatSfx22._to_wav(data)
func _creak() -> AudioStreamWAV:
 var data := PackedFloat32Array();data.resize(int(.36*44100));var smooth := 0.
 for j in data.size():
  var t := float(j)/44100.;smooth=lerpf(smooth,rng.randf_range(-1.,1.),.11)
  var env := pow(sin(PI*t/.36),2.)
  data[j]=env*(smooth*.17+.035*sin(TAU*(210.*t+7.*t*t))*sin(TAU*23.*t))
 return CombatSfx22._to_wav(data)
