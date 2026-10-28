extends Node2D
## Small pixel-snapped comic accents; damage and adhesive stacks never use this budget.
const MAX_EVENTS := 24
var battle: Node3D
var events158: Array[Dictionary]=[]
var gates158 := {}
var age158 := 0.
var frame158 := -1
var starts158 := 0
var played158 := 0
var voices158: Array[AudioStreamPlayer3D]=[]
var voice158 := 0
var rng158 := RandomNumberGenerator.new()
var gel_art158: Array[Texture2D]=[]
func _ready() -> void:
 name="BalloonPopAndGel158";mouse_filter158();rng158.seed=15801;process_priority=95
 var regions: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/combat_material33/regions.json"))
 for i in 3:
  var box: Array=regions["jelly_sheet_v1.png"][i];var texture := AtlasTexture.new()
  texture.atlas=load("res://assets/combat_material33/jelly_sheet_v1.png");texture.region=Rect2(box[0],box[1],box[2],box[3]);gel_art158.append(texture)
 var clip := AudioStreamWAV.new();clip.mix_rate=22050;clip.format=AudioStreamWAV.FORMAT_16_BITS
 var samples := PackedByteArray();samples.resize(1764*2);var phase := 0.
 for i in 1764:
  var t := float(i)/22050.;phase+=TAU*lerpf(880.,240.,minf(1.,t/.055))/22050.
  var wave := (sin(phase)+.15*sin(phase*2.))*sin(minf(1.,t/.005)*PI*.5)*exp(-t*65.)*.35
  samples.encode_s16(i*2,int(clampf(wave,-1.,1.)*32767.))
 clip.data=samples
 for i in 3:
  var voice := AudioStreamPlayer3D.new();voice.stream=clip;voice.volume_db=-11.;voice.max_distance=18.;voice.unit_size=5.
  battle.add_child(voice);voices158.append(voice)
func mouse_filter158() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func pop158(at: Vector3,direction: Vector3,key: int,gain := 1.) -> bool:
 if age158<float(gates158.get(key,-1.)): return false
 var frame := Engine.get_physics_frames()
 if frame!=frame158: frame158=frame;starts158=0
 if starts158>=3: return false
 gates158[key]=age158+.095;starts158+=1;played158+=1
 if gates158.size()>128:
  for id in gates158.keys():
   if float(gates158[id])<age158: gates158.erase(id)
 var dots: Array[Dictionary]=[]
 var right: Vector3=battle.camera.global_basis.x
 for i in 4:
  var side := -1. if i%2==0 else 1.
  dots.append({"at":at,"velocity":right*side*rng158.randf_range(.65,1.2)+Vector3.UP*rng158.randf_range(.15,.8)-direction*.22,"radius":rng158.randf_range(1.5,2.5),"variant":i%3})
 events158.append({"at":at,"age":0.,"gain":minf(gain,1.3),"dots":dots,"direction":direction})
 if events158.size()>MAX_EVENTS: events158.pop_front()
 var voice: AudioStreamPlayer3D=voices158[voice158%voices158.size()];voice158+=1
 voice.position=at;voice.pitch_scale=rng158.randf_range(.93,1.08);voice.play()
 queue_redraw();return true
func reset158() -> void:
 events158.clear();gates158.clear();frame158=-1;starts158=0
 for voice in voices158: if is_instance_valid(voice): voice.stop()
 queue_redraw()
func step158(delta: float) -> void:
 if battle.combat_paused: return
 age158+=delta
 for i in range(events158.size()-1,-1,-1):
  var event: Dictionary=events158[i];event.age+=delta
  for drop in event.dots:
   drop.velocity+=Vector3.DOWN*3.5*delta;drop.at+=Vector3(drop.velocity)*delta
  if event.age>.32: events158.remove_at(i)
 queue_redraw()
func point158(at: Vector3) -> Vector2:
 return (battle.camera.unproject_position(at)/2.).round()*2.
func arc158(center: Vector2,radius: float,start: float,end: float,color: Color) -> void:
 var points := PackedVector2Array()
 for i in 9:
  var angle := lerpf(start,end,float(i)/8.)
  var p := ((center+Vector2(cos(angle),sin(angle))*radius)/2.).round()*2.
  if points.is_empty() or points[-1]!=p: points.append(p)
 if points.size()>1: draw_polyline(points,color,2.,false)
func _draw() -> void:
 for event in events158:
  var at: Vector3=event.at
  if battle.camera.is_position_behind(at): continue
  var centre := point158(at)
  var pixel: float=battle.camera.unproject_position(at+battle.camera.global_basis.x*.13).distance_to(centre)
  var t := float(event.age);var fade := 1.-smoothstep(.10,.22,t)
  if t<.22:
   var radius: float=maxf(4.,pixel)*lerpf(.35,1.7,clampf(t/.15,0.,1.))*event.gain
   arc158(centre,radius,.10,PI*.8,Color(.92,1.,.91,fade))
   arc158(centre,radius,PI*1.05,TAU*.96,Color(.37,.84,.87,fade))
   if t<.10:
    var end: Vector2=centre+battle.screen_direction(at,-Vector3(event.direction))*maxf(4.,pixel)*.65
    draw_line(centre,(end/2.).round()*2.,Color(.43,.85,.84,1.-t/.1),2.,false)
  for drop in event.dots:
   if battle.camera.is_position_behind(drop.at): continue
   var p := point158(drop.at);var r: float=drop.radius*(1.-smoothstep(.16,.32,t))
   if r<.5: continue
   var texture: Texture2D=gel_art158[drop.variant]
   var size := Vector2(r*2.5,r*2.5*texture.get_height()/texture.get_width()).round()
   draw_texture_rect(texture,Rect2(p-size*.5,size),false)
