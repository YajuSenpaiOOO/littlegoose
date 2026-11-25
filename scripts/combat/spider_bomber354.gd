extends "res://scripts/combat/spider_bomber353.gd"
var motion354:=Vector3.ZERO
var length354:=3.4
var ready354:=false
var anchor_age354:=0.
var casting354:=-1.
var next354:=Vector3.ZERO
var transfers354:=0
var cast354: MeshInstance3D
var line354: ImmediateMesh
func _ready() -> void:
 super._ready()
 line354=ImmediateMesh.new();cast354=MeshInstance3D.new();cast354.mesh=line354;cast354.top_level=true
 cast354.material_override=silk351.material_override;cast354.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(cast354);cast354.hide()
func receive_hit(damage: float,direction: Vector3) -> void:
 super.receive_hit(damage,direction)
 if dead and is_instance_valid(cast354):cast354.hide()
func choose_anchor354() -> void:
 var player:=Vector2(battle.hero.global_position.x,battle.hero.global_position.z)
 var at:=Vector2(global_position.x,global_position.z)
 var forward: Vector2=(player-at).normalized()
 if forward.length_squared()<.01:forward=Vector2.DOWN
 var wish:=player+forward.orthogonal()*(1.6 if transfers354%2==0 else -1.6)
 wish=at+(wish-at).limit_length(4.)
 var cell: Vector2i=battle.navigation.nearest(wish)
 var ground: Vector2=battle.navigation.origin+Vector2(cell)*battle.navigation.CELL
 next354=Vector3(ground.x,battle.floor_height(ground)+5.8,ground.y)
 if next354.distance_to(anchor353)<1.:next354+=battle.camera.global_basis.x*(2. if transfers354%2==0 else -2.)
 casting354=0.;cast354.show()
func draw_cast354() -> void:
 var head:=global_position+Vector3.UP*1.15
 line354.clear_surfaces();line354.surface_begin(Mesh.PRIMITIVE_LINES)
 line354.surface_add_vertex(head);line354.surface_add_vertex(head.lerp(next354,clampf(casting354/.25,0.,1.)));line354.surface_end()
func _physics_process(delta: float) -> void:
 if battle.combat_paused:return
 if dead or travel351!="":super._physics_process(delta);return
 if not battle.active114:return
 if not ready354:
  ready354=true;motion354=battle.camera.global_basis.x*2.5
 _step_response121(delta);swing353+=delta;phase_age353+=delta;anchor_age354+=delta
 if casting354>=0.:
  casting354+=delta;draw_cast354()
  if casting354>=.25:
   anchor353=next354;length354=maxf(3.4,(global_position+Vector3.UP*1.15-anchor353).length())
   casting354=-1.;anchor_age354=0.;transfers354+=1;cast354.hide()
   battle.log347("silk_transfer",{"count":transfers354})
 elif phase353=="swing" and anchor_age354>=2.1:choose_anchor354()
 length354=move_toward(length354,3.4,delta*1.5)
 var before:=global_position
 var count:=maxi(1,ceili(delta*120.));var dt:=delta/float(count)
 for i in count:
  var player: Vector3=battle.hero.global_position
  var toward:=Vector3(player.x-global_position.x,0.,player.z-global_position.z)
  var pursuit:=toward.limit_length(3.)*2.2 if phase353!="rest" else Vector3.ZERO
  if phase353=="windup":pursuit*=.35
  motion354+=(pursuit+Vector3.DOWN*9.-motion354*(2.6 if phase353=="rest" else .5))*dt
  motion354=motion354.limit_length(5.2)
  var head:=global_position+Vector3.UP*1.15+motion354*dt
  var rope:=head-anchor353
  if rope.length()>length354:
   var normal:=rope.normalized();head=anchor353+normal*length354
   motion354-=normal*maxf(0.,motion354.dot(normal))
  var target:=head-Vector3.UP*1.15
  var floor: float=battle.floor_height(Vector2(target.x,target.z))
  if target.y<floor+1.1:target.y=floor+1.1;motion354.y=maxf(0.,motion354.y)
  var ray:=PhysicsRayQueryParameters3D.create(global_position+Vector3.UP*.55,target+Vector3.UP*.55,1|2)
  if get_world_3d().direct_space_state.intersect_ray(ray).is_empty():global_position=target
  else:motion354=-motion354*.3;anchor_age354=2.2
 velocity=(global_position-before)/maxf(.001,delta)
 var rope: Vector3=global_position+Vector3.UP*1.15-anchor353
 angle353=clampf(atan2(rope.dot(battle.camera.global_basis.x),maxf(.1,-rope.y)),-.9,.9)
 match phase353:
  "swing":
   if phase_age353>=1.6 and casting354<0.:phase353="windup";phase_age353=0.
  "windup":
   if phase_age353>=.85:
    battle.drop_bomb353(self,held353.global_position);thrown353+=1;volley353+=1;phase353="push";phase_age353=0.
  "push":
   if phase_age353>=.28:phase353="rest" if volley353>=2 else "swing";phase_age353=0.
  "rest":
   if phase_age353>=2.4:phase353="swing";phase_age353=0.;volley353=0
 pose353()
