extends "res://scripts/combat/paper348.gd"
var parried349:=false
var start349:=Vector3.ZERO
var destination349:=Vector3.ZERO
var duration349:=1.7
var layer349:=0
var mask349:=0
func _ready() -> void:
 super._ready()
 destination349=global_position
 var camera: Camera3D=battle.camera
 var screen:=camera.unproject_position(destination349)
 var depth: float=(destination349-camera.global_position).dot(-camera.global_basis.z)
 start349=camera.project_position(Vector2(clampf(screen.x,80.,get_viewport().get_visible_rect().size.x-80.),-320.),maxf(.1,depth))
 duration349=1.7+float(role110%3)*.12
 entry347=duration349
 layer349=collision_layer;mask349=collision_mask
 collision_layer=0;collision_mask=0;hit_area.collision_layer=0
 global_position=start349
 reset_physics_interpolation()
 _render_legacy(.55)
func play119() -> void:
 super.play119()
 gust_wait130=.55+float(role110%3)*.18
func deflect(contact: Vector3) -> void:
 super.deflect(contact)
 parried349=true
func _wind_motion130(at: Vector2,player: Vector2) -> Vector2:
 var drift:=super._wind_motion130(at,player)
 if paper_state129=="drift" and at.distance_to(player)>2.2:drift+=(player-at).normalized()*.9
 return drift.limit_length(2.8)
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if not dead and entry347>0.:
  entry347=maxf(0.,entry347-delta)
  var t:=1.-entry347/duration349
  age+=delta
  global_position=start349.lerp(destination349,smoothstep(0.,1.,t))+Vector3(sin(t*PI)*.35,0.,0.)
  velocity=Vector3.ZERO
  _render_legacy(.55)
  if entry347==0.:
   global_position=destination349
   collision_layer=layer349;collision_mask=mask349
   play119()
  return
 var before:=paper_state129
 parried349=false
 super._physics_process(delta)
 if before=="gust" and paper_state129=="coast" and not parried349:gust_wait130=1.6+float(role110%3)*.22
