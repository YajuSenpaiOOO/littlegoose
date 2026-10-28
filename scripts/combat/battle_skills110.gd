extends Node2D
const Candy=preload("res://scripts/combat/legacy/candy_bullet_art.gd")
const Stream=preload("res://scripts/combat/stream_art110_reference.gd")
const School=preload("res://scripts/combat/school_art110.gd")
var battle: Node3D
var geese110: Array[Node3D]=[]
var waves110: Array[Dictionary]=[]
var beams110: Array[Dictionary]=[]
var sweat110: Array[Dictionary]=[]
var dust110: Array[Dictionary]=[]
var tick110 := 0.
var beam_tick110 := 0.
var dash_hits110 := {}
var dash_id110 := -1
var wave_hits110 := 0
var beam_hits110 := 0
var chains110: Array[Dictionary]=[]
var ribbon110: Node2D
var stream_sound110 := 0.
var aura_hits110 := 0
var dash_damage_hits110 := 0
func _ready() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;process_priority=111;Candy._load_art();School._load();Stream._load_art()
 ribbon110=Node2D.new();add_child(ribbon110);var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/combat/stream_flow110.gdshader");var region: Array=Stream.art.tile_region;ink.set_shader_parameter("tile_region",Vector4(region[0],region[1],region[2],region[3]));ribbon110.material=ink;ribbon110.draw.connect(draw_ribbons110)
func sync_geese110() -> void:
 var count: int=battle.buffs.level("forest_fireboy")+2*battle.buffs.level("three_player")
 while geese110.size()>count: geese110.pop_back().queue_free()
 while geese110.size()<count:
  var goose: Node3D=preload("res://scripts/combat/goose110.gd").new();goose.battle=battle
  goose.formation110=Vector3((-1. if geese110.size()%2==0 else 1.)*(.8+float(geese110.size()/2)*.5),0,.35)
  battle.add_child(goose);geese110.append(goose);battle._add_actor_shadow(goose,goose.visual)
 for goose in geese110: goose.cup_phone=battle.buffs.level("cup_phone")>0
func origins110() -> Array[Vector3]:
 var origins: Array[Vector3]=[battle.goose.muzzle()]
 for goose in geese110:
  if is_instance_valid(goose): origins.append(goose.muzzle())
 return origins
func reset110() -> void:
 waves110.clear();beams110.clear();sweat110.clear();dust110.clear();dash_hits110.clear();chains110.clear();queue_redraw()
 if is_instance_valid(ribbon110): ribbon110.queue_redraw()
func wave110(enemy: CharacterBody3D) -> void:
 waves110.append({"at":Vector2(enemy.position.x,enemy.position.z),"age":0.,"previous":0.,"hit":false,"damage":enemy.touch110*2.5,"source":weakref(enemy)})
func step110(delta: float) -> void:
 var target: Vector3=battle.aim_at_screen(get_viewport().get_mouse_position())
 for goose in geese110:
  if is_instance_valid(goose): goose.update_follow(delta,target)
 if battle.combat_paused or battle.wave_state!="fighting" or battle.result_open: beams110.clear();return
 for i in range(waves110.size()-1,-1,-1):
  var wave: Dictionary=waves110[i];wave.age+=delta
  var radius: float=8.9*clampf(wave.age/.55,0.,1.)
  var player := Vector2(battle.hero.position.x,battle.hero.position.z);var distance: float=player.distance_to(wave.at)
  if not wave.hit and distance<=radius+.5 and distance>=float(wave.previous)-.5:
   wave.hit=true
   if battle.hero.can_parry():
    battle.parry_success(battle.hero.position+Vector3.UP*.65,Vector3(player.x-wave.at.x,0,player.y-wave.at.y).normalized())
   elif battle.hero.dodge_invulnerability>0.:
    if battle.hero.dash_eligible: battle.hero.dash_eligible=false;battle.perfect_dodge()
   else: battle.hurt_player(wave.damage,wave.at);wave_hits110+=1
  wave.previous=radius
  if wave.age>.65: waves110.remove_at(i)
 battle.beam_left110=maxf(0.,battle.beam_left110-delta)
 beam_tick110-=delta;stream_sound110-=delta
 if battle.beam_left110>0.:
  var empower: float=1.+.6*(1.-battle.player_hp/100.)
  var interval: float=.04/maxf(.01,battle.buffs.rate()*empower*(.5 if battle.buffs.level("three_player")>0 else 1.))
  var emitted := 0
  while beam_tick110<=0. and emitted<8:
   battle.emit_stream110(battle.aim_at_screen(get_viewport().get_mouse_position()));beam_tick110+=interval;emitted+=1
  if stream_sound110<=0.: stream_sound110=.12;battle.Audio.play("shoot",.8)
 else: beam_tick110=0.;beams110.clear()

 tick110-=delta
 if battle.hero.dash_count!=dash_id110: dash_id110=battle.hero.dash_count;dash_hits110.clear()
 if battle.buffs.level("exercise")>0 and battle.hero.dash_left>0.:
  for enemy in battle.near_enemies110(Vector2(battle.hero.position.x,battle.hero.position.z),1.5):
   if dash_hits110.has(enemy.get_instance_id()): continue
   dash_hits110[enemy.get_instance_id()]=true;enemy.receive_hit(.2*battle.projectile_damage(),Vector3(battle.hero.dash_direction.x,0,battle.hero.dash_direction.y));dash_damage_hits110+=1
 if tick110<=0.:
  tick110=.14
  if battle.buffs.level("homework")>0 and sweat110.size()<24:
   var a: float=battle.weapon_rng.randf()*TAU;sweat110.append({"at":battle.hero.position+Vector3.UP*.6,"velocity":Vector3(cos(a),-.15,sin(a))*2.,"age":0.})
  if battle.buffs.level("paper_racer")>0 and Vector2(battle.hero.velocity.x,battle.hero.velocity.z).length()>2. and dust110.size()<12: dust110.append({"at":battle.hero.position,"age":0.})
 for i in range(sweat110.size()-1,-1,-1):
  var drop: Dictionary=sweat110[i];drop.age+=delta;drop.at+=drop.velocity*delta
  var nearby: Array=battle.near_enemies110(Vector2(drop.at.x,drop.at.z),.85)
  if not nearby.is_empty():
   nearby[0].receive_hit(.4*battle.projectile_damage(),drop.velocity);aura_hits110+=1;sweat110.remove_at(i)
  elif drop.age>.8: sweat110.remove_at(i)
 for i in range(dust110.size()-1,-1,-1):
  dust110[i].age+=delta
  if dust110[i].age>.35: dust110.remove_at(i)
func _process(delta: float) -> void:
 if not battle.combat_paused:
  for shot in battle.shots:
   if shot.has("art"): shot.art.age+=delta
 build_chains110();ribbon110.material.set_shader_parameter("flow",fmod(battle.clock*9.,1.));ribbon110.queue_redraw();queue_redraw()
func screen110(at: Vector3) -> Vector2: return battle.camera.unproject_position(at)
func pixels110(at: Vector3) -> float: return (screen110(at+battle.camera.global_basis.x)-screen110(at)).length()/battle.Profile.PPM
func _draw() -> void:
 var fragment_count := 0
 var entry: Dictionary=Candy.art.pearl_core if Candy.particle_trail_enabled else Candy.art.pearl
 for shot in battle.shots:
  if not shot.has("art") or not is_instance_valid(shot.art) or shot.get("stream110",false): continue
  if int(shot.get("split_depth110",0))>0:
   if fragment_count>=128: continue
   fragment_count+=1
  var at: Vector3=shot.node.get_global_transform_interpolated().origin
  if battle.camera.is_position_behind(at): continue
  var screen := screen110(at);var pixel := pixels110(at)
  if shot.get("note110",false):
   var note: Dictionary=School.entries.notes;var index := int(shot.art.get_instance_id())%3;var tex: Texture2D=note.textures[index];var anchor: Array=note.anchors[index]
   var gain: float=6.4/float(note.core_pixels[index])*pixel*shot.art.scale_gain
   draw_set_transform(screen,.08*sin(shot.art.age*9.));draw_texture_rect(tex,Rect2(-Vector2(anchor[0],anchor[1])*gain,tex.get_size()*gain),false,shot.art.modulate)
  else:
   var gain: float=float(entry.core_world)/float(entry.core_pixels)*shot.art.scale_gain*(1.+.035*sin(shot.art.age*15.))
   var anchor: Array=entry.anchor;var tex: Texture2D=entry.textures[0]
   draw_set_transform(screen,battle.screen_direction(at,shot.velocity.normalized()).angle(),Vector2.ONE*pixel)
   draw_texture_rect(tex,Rect2(-Vector2(anchor[0],anchor[1])*gain,tex.get_size()*gain),false,shot.art.modulate)
 draw_set_transform(Vector2.ZERO,0.,Vector2.ONE)
 for chain in chains110:
  var points: PackedVector2Array=chain.points
  if points.size()<2: continue
  var tangent := (points[-1]-points[-2]).normalized();var size: Vector2=Vector2(14,8)*chain.pixel*(1.2 if chain.heavy else 1.)
  draw_set_transform(points[-1],tangent.angle());draw_texture_rect(Stream.art.head[0],Rect2(-size*.5,size),false)
 draw_set_transform(Vector2.ZERO,0.,Vector2.ONE)
 if battle.beam_left110>0.:
  for origin in origins110():
   var facing: Vector2=battle.screen_direction(origin,battle.aim_at_screen(get_viewport().get_mouse_position())-origin)
   var size: float=12.*pixels110(origin)*(1.2 if battle.buffs.level("slingshot")>0 else 1.)
   draw_set_transform(screen110(origin),facing.angle());draw_texture_rect(Stream.art.muzzle[int(battle.clock/.045)%3],Rect2(-Vector2.ONE*size*.5,Vector2.ONE*size),false)
 draw_set_transform(Vector2.ZERO,0.,Vector2.ONE)
 for wave in waves110:
  var points := PackedVector2Array();var r: float=8.9*clampf(wave.age/.55,0.,1.)
  for i in 65:
   var angle := TAU*float(i)/64.;var at: Vector2=wave.at+Vector2(cos(angle),sin(angle))*r
   points.append(screen110(Vector3(at.x,battle.floor_height(at)+.05,at.y)))
  draw_polyline(points,Color(.92,.72,.45,.75),3.,true)
 for drop in sweat110:
  var ink: Dictionary=School.entries.sweat;var tex: Texture2D=ink.textures[0];var anchor: Array=ink.anchor
  var gain: float=4.5/float(ink.core_pixels)*pixels110(drop.at)
  draw_texture_rect(tex,Rect2(screen110(drop.at)-Vector2(anchor[0],anchor[1])*gain,tex.get_size()*gain),false,Color(1,1,1,1.-drop.age/.8))
 for dust in dust110: draw_circle(screen110(dust.at),3.+dust.age*14.,Color(.72,.65,.43,(1.-dust.age/.35)*.3))

func build_chains110() -> void:
 chains110.clear();var groups := {}
 for shot in battle.shots:
  if not shot.get("stream110",false): continue
  var key := Vector2i(shot.stream_lane110,shot.stream_generation110)
  if not groups.has(key): groups[key]=[]
  groups[key].append(shot)
 for key in groups:
  var samples: Array=groups[key];samples.reverse();var points := PackedVector2Array();var stride := maxi(1,ceili(float(samples.size())/20.))
  var previous: Dictionary={};var front: Dictionary=samples[-1]
  if battle.beam_left110>0. and key.y==battle.stream_generation110:
   var origins := origins110();var source: int=key.x/3
   if source<origins.size() and origins[source].distance_to(samples[0].node.position)<1.45: points.append(screen110(origins[source]))
  for i in samples.size():
   if i%stride!=0 and i!=samples.size()-1: continue
   var shot: Dictionary=samples[i];var point := screen110(shot.node.get_global_transform_interpolated().origin)
   if not previous.is_empty() and (int(previous.stream_sequence110)-int(shot.stream_sequence110)>stride+1 or points[-1].distance_to(point)>48.*pixels110(shot.node.position)):
    if points.size()>1: chains110.append({"points":points,"heavy":front.stream_heavy110,"pixel":pixels110(front.node.position)})
    points=PackedVector2Array()
   points.append(point);previous=shot
  if points.size()==1: points.insert(0,points[0]-battle.screen_direction(front.node.position,front.velocity.normalized())*10.*pixels110(front.node.position))
  if not points.is_empty(): chains110.append({"points":points,"heavy":front.stream_heavy110,"pixel":pixels110(front.node.position)})
func draw_ribbons110() -> void:
 for chain in chains110:
  var points: PackedVector2Array=chain.points;var width: float=(4.4 if chain.heavy else 3.2)*chain.pixel;var distance := 0.
  for i in points.size()-1:
   var a := points[i];var b := points[i+1];var normal := (b-a).normalized().orthogonal()*width
   var length := a.distance_to(b);var u0: float=distance/(24.*chain.pixel);var u1: float=(distance+length)/(24.*chain.pixel)
   var vertices := PackedVector2Array([a-normal,b-normal,b+normal,a+normal]);var uvs := PackedVector2Array([Vector2(u0,0),Vector2(u1,0),Vector2(u1,1),Vector2(u0,1)])
   for tri in [[0,1,2],[0,2,3]]:
    var positions := PackedVector2Array();var uv := PackedVector2Array()
    for index in tri: positions.append(vertices[index]);uv.append(uvs[index])
    ribbon110.draw_primitive(positions,PackedColorArray([Color.WHITE,Color.WHITE,Color.WHITE]),uv,Stream.art.flow)
   distance+=length
