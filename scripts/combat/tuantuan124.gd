extends "res://scripts/combat/tuantuan123.gd"
const ANGRY124 := "res://assets/tuantuan_v2/shove_angry124.png"
const FADE_START124 := 2.8
const FADE_TIME124 := 1.25
func _ready() -> void:
 poses=poses.duplicate();textures=textures.duplicate()
 var texture: Texture2D=load(ANGRY124)
 poses["shove124"]=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tuantuan_v2/shove_angry124.json"))
 textures["shove124"]=texture
 super._ready()

func _pose(key: String,lift: float) -> void:
 if play_state123=="shove" and not dead and hit_left<=0.: key="shove124"
 super._pose(key,lift)

func peer_contact123(before: Vector3) -> bool:
 if peer_cooldown123>0.: return false
 for other in battle.enemies:
  if other==self or not is_instance_valid(other) or not other.has_method("available123"): continue
  if not other.available123() or other.peer_cooldown123>0.: continue
  if other.play_state123 not in ["","cheer","shove"]: continue
  if absf(position.y-other.position.y)>.65: continue
  var t: float=battle.aim_model.sweep_circle(Vector2(before.x,before.z),Vector2(position.x,position.z),Vector2(other.position.x,other.position.z),.78)
  if t<INF:
   begin_quarrel123(other)
   if other.play_state123=="": other.begin_quarrel123(self)
   return true
 return false

func _target_valid124(other: CharacterBody3D) -> bool:
 return is_instance_valid(other) and other!=self and other.available123() and other.peer_cooldown123<=0. and other.play_state123 in ["cheer","shove"] and position.distance_to(other.position)<3.5

func _retarget124() -> bool:
 if _target_valid124(peer123): return true
 peer123=null
 var best := 3.5*3.5
 for other in battle.enemies:
  if not _target_valid124(other): continue
  var distance := position.distance_squared_to(other.position)
  if distance<best: best=distance;peer123=other
 return is_instance_valid(peer123)

func _step_play123(delta: float) -> void:
 if play_state123=="roll": super._step_play123(delta);return
 _step_response121(delta);play_clock123+=delta
 if not _retarget124(): clear_play123();_render_legacy(0.);return
 var offset := Vector2(peer123.position.x-position.x,peer123.position.z-position.z)
 var motion := Vector2.ZERO
 var lift := 0.
 if play_state123=="cheer":
  lift=absf(sin(play_clock123/CHEER_TIME*TAU))*.19;hopping=true;hop_clock=.1
  if play_clock123>=CHEER_TIME: play_state123="shove";play_clock123=0.;hopping=false
 else:
  var push := sin(play_clock123/.62*TAU)
  # Separate from all neighbours, so a shared target does not become a stack.
  motion=offset.normalized()*push*.65 if offset.length()<1.1 else offset.normalized()*1.1
  for other in battle.enemies:
   if other==self or not is_instance_valid(other) or other.dead: continue
   var away := Vector2(position.x-other.position.x,position.z-other.position.z)
   if away.length()>.01 and away.length()<.7: motion+=away.normalized()*(.7-away.length())*2.
  var tick := int(play_clock123/.62)
  if tick>shove_tick123:
   shove_tick123=tick
   if offset.length()<1.3:
    peer123.hp=maxf(minf(peer123.hp,1.),peer123.hp-PEER_DAMAGE)
    peer123.health_time=.7;peer123.squeeze=minf(.16,peer123.squeeze+.06)
  if play_clock123>=SHOVE_TIME: clear_play123();_render_legacy(0.);return
 _move_play123(motion,delta);_render_legacy(lift)

func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if dead or play_state123!="shove": return
 var entry: Dictionary=poses.shove124
 var size := visual.texture.get_size()
 soft_ink.set_shader_parameter("art",visual.texture)
 soft_ink.set_shader_parameter("body_span",Vector2(float(entry.visible_width),float(entry.visible_height))/24./(size*visual.pixel_size))
 soft_ink.set_shader_parameter("foot_y",float(entry.foot[1])/size.y)
 if is_instance_valid(peer123):
  visual.flip_h=battle.camera.global_basis.x.dot(peer123.position-position)<0.
  if visual.flip_h: visual.offset.x=-visual.offset.x

func _process(delta: float) -> void:
 if not dead or battle.combat_paused: return
 corpse_time+=delta
 if corpse_time<FADE_START124: return
 var fade := smoothstep(0.,1.,clampf((corpse_time-FADE_START124)/FADE_TIME124,0.,1.))
 if soft_ink.shader!=preload("res://scripts/combat/soft_fade124.gdshader"):
  soft_ink.shader=preload("res://scripts/combat/soft_fade124.gdshader")
 soft_ink.set_shader_parameter("art",visual.texture)
 soft_ink.set_shader_parameter("tint",Color(1.,1.,1.,1.-fade))
 visual.modulate.a=1.-fade
 if fade>=1.:
  battle.enemies.erase(self);battle.rebuild_cells110();hide();queue_free()

