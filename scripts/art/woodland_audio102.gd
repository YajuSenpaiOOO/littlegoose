extends "res://scripts/art/woodland_audio101.gd"
var rustle_voice102: AudioStreamPlayer3D
var rustle_wait102 := 0.
var rustle_events102 := 0
var grass_scan102 := 0.
var grass_sound_enabled102 := false # Disabled by user feedback: repeated grass pulse sounded mechanical.
func _ready() -> void:
 super._ready()
 rustle_voice102=_voice(Vector3.ZERO,9.,3.,-17.,_rustle102())
func set_enabled(value: bool) -> void:
 super.set_enabled(value)
 if not value and is_instance_valid(rustle_voice102): rustle_voice102.stop()
func rustle102(at: Vector3,leaf := true) -> void:
 if not enabled or rustle_wait102>0. or (not leaf and not grass_sound_enabled102): return
 rustle_wait102=.23;rustle_voice102.position=at;rustle_voice102.pitch_scale=rng.randf_range(.85,1.03) if leaf else rng.randf_range(1.1,1.3)
 rustle_voice102.play();rustle_events102+=1
func _process(delta: float) -> void:
 super._process(delta);rustle_wait102=maxf(0.,rustle_wait102-delta);grass_scan102-=delta
 if not enabled or not grass_sound_enabled102 or grass_scan102>0.: return
 grass_scan102=.16
 if Vector2(world.hero.velocity.x,world.hero.velocity.z).length()<.65: return
 var at: Vector3=world.hero.position
 for plant in world.forest87.plants87:
  if plant.position.distance_squared_to(at)<.65*.65: rustle102(at,false);break
func _rustle102() -> AudioStreamWAV:
 var data := PackedFloat32Array();data.resize(int(.21*44100));var low := 0.;var high := 0.
 for i in data.size():
  var t := float(i)/44100.;var noise := rng.randf_range(-1.,1.);low=lerpf(low,noise,.035);high=lerpf(high,noise,.5)
  var pulse := pow(sin(PI*t/.21),1.5)*(.7+.3*sin(TAU*37.*t))
  data[i]=(high-low)*pulse*.25
 return CombatSfx22._to_wav(data)
