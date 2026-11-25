extends "res://scripts/combat/flight_visual388.gd"
var charge_poses389: Array[Texture2D]=[]
var charge_emitting389:=false
var charge_left389:=0.0
var charge_age_released389:=0.0
var charged_events389:=0
var kick389:=0.0
var velocity389:=0.0
const DENSITY389:=1.44/1013.
func _ready() -> void:
 super._ready()
 for col in 2:charge_poses389.append(atlas381(preload("res://assets/black_goose_charge389/charge-release.png"),Rect2(col*627,0,627,1254)))
func charge_phase389() -> String:
 if not charge_direction389() or charge_poses389.is_empty() or battle.buffs.level("slingshot")==0:return ""
 if battle.wave_state!="fighting" or battle.result_open or battle.player_hp<=0.:return ""
 # A new press can immediately replace the visual release; no input lockout.
 if battle.charge_active and not charge_emitting389 and (charge_left389<=0. or battle.charge_age<charge_age_released389):return "charge"
 if charge_left389>0. or charge_emitting389:return "release"
 return ""
func apply_pose386() -> void:
 var phase:=charge_phase389()
 if phase=="":super.apply_pose386();return
 var index: int=0 if phase=="charge" else 1
 body379.texture=charge_poses389[index];body379.offset=Vector2(313.5-320.,1146.-627.)
 body379.pixel_size=DENSITY389;body379.material_override.albedo_texture=body379.texture.atlas
 if is_instance_valid(arm_front388):arm_front388.visible=false
func fired386(beam: bool) -> void:
 super.fired386(beam)
 if charge_emitting389 and not beam:charged_fired389()
func charged_fired389() -> void:
 charged_events389+=1;charge_left389=.42;charge_age_released389=battle.charge_age;velocity389=.95
 apply_pose386();update_shadow380()
func _process(dt: float) -> void:
 if not battle.combat_paused:
  charge_left389=maxf(0.,charge_left389-dt)
  if battle.buffs.level("slingshot")==0 or battle.wave_state!="fighting" or battle.result_open or battle.player_hp<=0.:
   charge_left389=0.;kick389=0.;velocity389=0.
  var remaining:=dt
  while remaining>0.:
   var step:=minf(remaining,1./120.)
   velocity389+=(-kick389*115.-velocity389*14.)*step;kick389+=velocity389*step;remaining-=step
 super._process(dt)
 charge_feedback389(dt)
func charge_direction389() -> bool:return direction381==3
func charge_feedback389(_dt: float) -> void:
 if direction381==3:
  if charge_phase389()=="charge":
   var ratio: float=battle.charge_ratio()
   position.z+=.02*ratio;position.y-=.018*ratio;position.x+=sin(clock380*TAU*7.)*.002*ratio
  position.z-=kick389*1.8
  update_shadow380()
func muzzle383() -> Vector3:
 if direction381==3 and (charge_emitting389 or charge_phase389()!=""):return to_global(Vector3(0,.77,.025))
 return super.muzzle383()
