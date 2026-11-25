extends "res://scripts/combat/flight_visual389.gd"
var textures390: Array=[]
var poses390: Array=[]
var mouths390: Array[Vector3]=[]
var back_hair390: Array[Texture2D]=[]
var sleeves390: Array[Texture2D]=[]
var sleeve_anchors390: Array[Vector2]=[]
var sleeve_left390: Sprite3D
var basic_sleeve390: Texture2D
var basic_offset390:=Vector2.ZERO
var recoil_dir390:=Vector2(0,1)
func _ready() -> void:
 super._ready()
 var sheet:=preload("res://assets/black_goose_charge390/poses-five-fingers.png")
 var layout: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/black_goose_charge390/layout.json"))
 poses390=layout.poses_by_direction
 for dir in 3:
  var pair: Array[Texture2D]=[]
  for pose in poses390[dir]:
   var r: Array=pose.region;pair.append(atlas381(sheet,Rect2(r[0],r[1],r[2],r[3])))
  textures390.append(pair)
  var m: Array=layout.mouths[dir];mouths390.append(Vector3(m[0],m[1],m[2]))
 for pose in poses390[1]:
  var r: Array=pose.region;back_hair390.append(atlas381(sheet,Rect2(r[0],r[1],r[2],pose.hair_height)))
 var back: Dictionary=poses390[1][1]
 for crop in layout.back_release_sleeves:
  sleeves390.append(atlas381(sheet,Rect2(back.region[0]+crop[0],back.region[1]+crop[1],crop[2],crop[3])))
  sleeve_anchors390.append(Vector2(back.anchor[0]-crop[0],back.anchor[1]-crop[1]))
 basic_sleeve390=arm_front388.texture;basic_offset390=arm_front388.offset
 sleeve_left390=sprite379(sleeves390[0],sleeve_anchors390[0],back.density);sleeve_left390.visible=false
func charge_direction389() -> bool:return true
func apply_pose386() -> void:
 if is_instance_valid(sleeve_left390):sleeve_left390.visible=false
 var phase:=charge_phase389()
 if direction381==3 or phase=="" or textures390.is_empty():
  if basic_sleeve390!=null:
   arm_front388.texture=basic_sleeve390;arm_front388.offset=basic_offset390;arm_front388.pixel_size=1.44/830.
   arm_front388.material_override.albedo_texture=basic_sleeve390.atlas
  if direction381==1:
   hair382.pixel_size=1.44/830.;hair382.offset=Vector2(0,645.)
  super.apply_pose386();return
 var index: int=0 if phase=="charge" else 1
 var p: Dictionary=poses390[direction381][index];var tex: Texture2D=textures390[direction381][index]
 body379.texture=tex;body379.pixel_size=p.density
 body379.offset=Vector2(tex.get_width()*.5-float(p.anchor[0]),float(p.anchor[1])-tex.get_height()*.5)
 body379.material_override.albedo_texture=tex.atlas;arm_front388.visible=false
 if direction381==1:
  var upper: Texture2D=back_hair390[index]
  hair382.texture=upper;hair382.pixel_size=p.density
  hair382.offset=Vector2(upper.get_width()*.5-float(p.anchor[0]),float(p.anchor[1])-upper.get_height()*.5)
  hair382.material_override.albedo_texture=upper.atlas
  if index==1:
   sleeve_left390.visible=true;arm_front388.visible=true
   arm_front388.texture=sleeves390[1];arm_front388.pixel_size=p.density
   arm_front388.offset=Vector2(sleeves390[1].get_width()*.5-sleeve_anchors390[1].x,sleeve_anchors390[1].y-sleeves390[1].get_height()*.5)
   arm_front388.material_override.albedo_texture=sleeves390[1].atlas
 align_hair382();align_arm388();align_left390()
func align_left390() -> void:
 if not is_instance_valid(sleeve_left390) or not sleeve_left390.visible:return
 var local_camera: Vector3=to_local(camera.global_position)
 var ratio:=.045/maxf(.1,local_camera.z)
 sleeve_left390.position=local_camera*ratio;sleeve_left390.scale=Vector3.ONE*(1.-ratio)
 sleeve_left390.modulate=body379.modulate
func charged_fired389() -> void:
 recoil_dir390=heading383.normalized()
 super.charged_fired389()
func charge_feedback389(_dt: float) -> void:
 if charge_phase389()=="charge":
  var q: float=battle.charge_ratio();var amplitude:=lerpf(.001,.009,q*q)
  var side:=Vector3(heading383.y,0,-heading383.x)
  position+=side*sin(clock380*TAU*(4.+q*3.))*amplitude
  position+=Vector3(heading383.x,0,heading383.y)*sin(clock380*TAU*5.1)*amplitude*.35
  position.y+=sin(clock380*TAU*6.7)*amplitude*.35-.012*q
  rotation.z+=sin(clock380*TAU*(3.+q*3.))*.012*q
 position-=Vector3(recoil_dir390.x,0,recoil_dir390.y)*kick389*2.4
 align_hair382();align_arm388();align_left390();update_shadow380()
func muzzle383() -> Vector3:
 if direction381!=3 and mouths390.size()==3 and (charge_emitting389 or charge_phase389()!=""):return to_global(mouths390[direction381])
 return super.muzzle383()
