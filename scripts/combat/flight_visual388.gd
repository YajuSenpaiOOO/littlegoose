extends "res://scripts/combat/flight_visual387.gd"
var releases388: Array[Texture2D]=[]
var idle388: Array[Texture2D]=[]
var back_hair388: Array[Texture2D]=[]
var arm_front388: Sprite3D
const HANDS388=[Vector2(78,557),Vector2(425,546),Vector2(421,551)]
func _ready() -> void:
 super._ready()
 var source:=preload("res://assets/black_goose_attack388/releases.png")
 var original:=preload("res://assets/black_goose_flight381/bodies.png")
 for col in [0,2,1]:
  releases388.append(atlas381(source,Rect2(col*512,0,512,1024)))
  idle388.append(atlas381(original,Rect2(col*512,0,512,1024)))
 back_hair388=[atlas381(original,Rect2(1024,0,512,570)),atlas381(source,Rect2(1024,0,512,570))]
 # Display duplicate of the connected source sleeve/palm, never a movable limb.
 arm_front388=sprite379(atlas381(source,Rect2(1024+335,500,177,140)),Vector2(-79,430),1.44/830.)
 arm_front388.visible=false
func set_direction381(value: int) -> void:
 super.set_direction381(value);apply_pose386()
func apply_pose386() -> void:
 if is_instance_valid(arm_front388):arm_front388.visible=direction381==1 and pose386.phase=="release"
 if direction381==3:super.apply_pose386();return
 if releases388.is_empty():return
 var releasing: bool=pose386.phase=="release"
 body379.texture=releases388[direction381] if releasing else idle388[direction381]
 body379.pixel_size=1.44/830.;body379.offset=Vector2(0,418)
 body379.material_override.albedo_texture=body379.texture.atlas
 if direction381==1:
  # Foreground hair/collar uses the SAME current body source and registration.
  hair382.texture=back_hair388[1 if releasing else 0]
  hair382.material_override.albedo_texture=hair382.texture.atlas
 align_arm388()
func align_arm388() -> void:
 if not is_instance_valid(arm_front388) or not arm_front388.visible:return
 var local_camera: Vector3=to_local(camera.global_position)
 var ratio:=.045/maxf(.1,local_camera.z)
 arm_front388.position=local_camera*ratio;arm_front388.scale=Vector3.ONE*(1.-ratio)
 arm_front388.modulate=body379.modulate
func _process(dt: float) -> void:
 super._process(dt)
 if direction381!=3:
  position-=Vector3(heading383.x,0,heading383.y)*pose386.kick
  align_hair382();align_arm388();update_shadow380()
func muzzle383() -> Vector3:
 if direction381==3:return super.muzzle383()
 if emitting386 or pose386.phase=="release":
  var hand: Vector2=HANDS388[direction381]
  return to_global(Vector3((hand.x-256.)*1.44/830.,(930.-hand.y)*1.44/830.,.025))
 return super.muzzle383()
