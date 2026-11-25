extends "res://scripts/combat/spider351.gd"
var actions352:=0
var second352:=false
var follow352:=false
var closeup352:=false
var reverse352:=false
func _ready() -> void:
 super._ready()
 if closeup352:
  physics_interpolation_mode=Node.PHYSICS_INTERPOLATION_MODE_OFF
  shadow.hide()
func prepare170(player: Vector2) -> void:
 # Three attacks per web; alternate single and visibly rewound double throws.
 var weave:=actions352%4==3
 second352=not weave and actions352%2==0
 follow352=false
 actions172=0 if weave else 1
 actions352+=1
 super.prepare170(player)
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if closeup352:
  clock351+=delta
  closeup_pose352(clampf(clock351/3.2,0.,1.))
  if clock351>=3.2:queue_free()
  return
 if not ambient351 and travel351=="" and not dead and active_ai and battle.active114 and battle.wave_state=="fighting":
  if state170=="winding":clock170+=delta*(WIND171/(.55 if follow352 else .85)-1.)
  elif state170=="sit":
   if second352 and clock170>=.22 and battle.reserve_spider170(self):
    second352=false;follow352=true
    var player:=Vector2(battle.hero.position.x,battle.hero.position.z)
    var at:=Vector2(position.x,position.z)
    target170=player;attack_direction=(player-at).normalized()
    if attack_direction.length_squared()<.01:attack_direction=Vector2.DOWN
    face_motion171(attack_direction);pushed171=false;enter170("winding")
   elif second352 and clock170>=.22:clock170=.22-delta
   elif not second352:clock170+=delta*(SIT171/.65-1.)
 super._physics_process(delta)
func closeup_pose352(t: float) -> void:
 var size:=get_viewport().get_visible_rect().size
 var depth: float=maxf(8.,(battle.hero.global_position-battle.camera.global_position).dot(-battle.camera.global_basis.z)*.7)
 var angle: float=lerpf(1.3,-1.3,smoothstep(0.,1.,t))*(-1. if reverse352 else 1.)
 var pivot:=Vector2(size.x*.5,size.y*.43-size.x*.72)
 var point:=pivot+Vector2(sin(angle),cos(angle))*size.x*.72
 global_position=battle.camera.project_position(point,depth)
 pivot351=battle.camera.project_position(pivot,depth)
 _pose("airborne",0.)
 # Perspective closeups need a screen-size budget, not an arbitrary giant scale near the lens.
 var pixels: float=battle.camera.unproject_position(global_position+Vector3.UP).distance_to(battle.camera.unproject_position(global_position))
 var height: float=float(poses["airborne"].visible_height)/24.
 visual.scale=Vector3.ONE*(size.y*.30/maxf(1.,pixels)/height)
 visual.rotation.z=-angle*.28
 rope351();health_fill.hide()
