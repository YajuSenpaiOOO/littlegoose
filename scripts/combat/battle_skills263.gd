extends "res://scripts/combat/battle_skills168.gd"
var build_us263 := 0
var submitted263 := 0
var vertices263 := 0
var beam_clock263 := 0.
var glows263: Node2D
func _ready() -> void:
 super._ready()
 var ink=ShaderMaterial.new();ink.shader=preload("res://scripts/combat/beam263.gdshader");ribbon110.material=ink
 glows263=Node2D.new();add_child(glows263)
 var glow=ShaderMaterial.new();glow.shader=preload("res://scripts/combat/beam_glow263.gdshader");glows263.material=glow;glows263.draw.connect(draw_glows263)
func _process(delta: float) -> void:
 if not battle.combat_paused:beam_clock263+=delta
 super._process(delta)
 ribbon110.material.set_shader_parameter("flow",fmod(beam_clock263*1.8,1.))
 ribbon110.material.set_shader_parameter("red263",1. if battle.flashlight_red229() else 0.)
 glows263.material.set_shader_parameter("red263",1. if battle.flashlight_red229() else 0.);glows263.queue_redraw()
func build_chains110() -> void:
 var started=Time.get_ticks_usec();chains110.clear();var groups={}
 var pixel=pixels110(battle.hero.position+Vector3.UP*.8)
 for shot in battle.shots:
  if not shot.get("stream110",false):continue
  var key=Vector2i(shot.stream_lane110,shot.stream_generation110)
  if not groups.has(key):groups[key]=[]
  groups[key].append(shot)
 var origins=origins110()
 for key in groups:
  var samples: Array=groups[key];samples.reverse()
  var points=PackedVector2Array();var stride=maxi(1,ceili(float(samples.size())/24.))
  var previous: Dictionary={};var front: Dictionary=samples[-1]
  if battle.beam_left110>0. and key.y==battle.stream_generation110:
   var source=int(key.x/3)
   if source<origins.size() and origins[source].distance_to(samples[0].node.position)<1.45:points.append(screen110(origins[source]))
  for i in samples.size():
   if i%stride!=0 and i!=samples.size()-1:continue
   var shot: Dictionary=samples[i];var point=screen110(shot.node.get_global_transform_interpolated().origin)
   if not previous.is_empty() and (int(previous.stream_sequence110)-int(shot.stream_sequence110)>stride+1 or points[-1].distance_to(point)>48.*pixel):
    if points.size()>1:chains110.append({"points":points,"heavy":front.stream_heavy110,"pixel":pixel})
    points=PackedVector2Array()
   if points.is_empty() or points[-1].distance_squared_to(point)>.01:points.append(point)
   previous=shot
  if front.has("stream_joint275") and not points.is_empty():points.insert(0,screen110(front.stream_joint275))
  if points.size()==1:points.insert(0,points[0]-battle.screen_direction(front.node.position,front.velocity.normalized())*10.*pixel)
  if points.size()>1:chains110.append({"points":points,"heavy":front.stream_heavy110,"pixel":pixel})
 build_us263=Time.get_ticks_usec()-started
func draw_ribbons110() -> void:
 submitted263=0;vertices263=0
 for chain in chains110:
  var points: PackedVector2Array=chain.points
  var width=(5.2 if chain.heavy else 4.)*chain.pixel
  var vertices=PackedVector2Array();var uvs=PackedVector2Array();var indices=PackedInt32Array();var distance=0.
  for i in points.size():
   var before=(points[i]-points[maxi(0,i-1)]).normalized()
   var after=(points[mini(points.size()-1,i+1)]-points[i]).normalized()
   if i==0:before=after
   if i==points.size()-1:after=before
   var normal=(before+after).normalized().orthogonal()
   if normal.length_squared()<.01:normal=after.orthogonal()
   var miter=minf(1.15,1./maxf(.2,absf(normal.dot(after.orthogonal()))))
   if i>0:distance+=points[i].distance_to(points[i-1])
   vertices.append(points[i]-normal*width*miter);vertices.append(points[i]+normal*width*miter)
   var u=distance/maxf(1.,32.*chain.pixel);uvs.append(Vector2(u,0));uvs.append(Vector2(u,1))
   if i>0:
    var at=i*2;indices.append_array(PackedInt32Array([at-2,at,at+1,at-2,at+1,at-1]))
  RenderingServer.canvas_item_add_triangle_array(ribbon110.get_canvas_item(),indices,vertices,PackedColorArray([Color.WHITE]),uvs)
  submitted263+=1;vertices263+=vertices.size()
func draw_stream_heads110() -> void:pass
func draw_stream_muzzles110() -> void:pass
func reset110() -> void:
 super.reset110()
 if is_instance_valid(glows263):glows263.queue_redraw()
func draw_glows263() -> void:
 var entries=[]
 for chain in chains110:entries.append({"at":chain.points[-1],"radius":5.2*chain.pixel})
 if battle.beam_left110>0.:
  for origin in origins110():entries.append({"at":screen110(origin),"radius":6.*pixels110(origin)})
 if entries.is_empty():return
 var vertices=PackedVector2Array();var uvs=PackedVector2Array();var indices=PackedInt32Array()
 for entry in entries:
  var at=vertices.size();var point: Vector2=entry.at;var radius: float=entry.radius
  vertices.append_array(PackedVector2Array([point+Vector2(-radius,-radius),point+Vector2(radius,-radius),point+Vector2(radius,radius),point+Vector2(-radius,radius)]))
  uvs.append_array(PackedVector2Array([Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN]));indices.append_array(PackedInt32Array([at,at+1,at+2,at,at+2,at+3]))
 RenderingServer.canvas_item_add_triangle_array(glows263.get_canvas_item(),indices,vertices,PackedColorArray([Color.WHITE]),uvs)
