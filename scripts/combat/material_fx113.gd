extends "res://scripts/combat/material_fx105.gd"
# Same integration, capacities, textures and slope-fitting; upload each batch once.
class Packet113:
 extends RefCounted
 var data := PackedFloat32Array()
 var stride := 0
 func put(index: int,pose: Transform3D,color: Color,variant: float) -> void:
  var p := index*stride;var b := pose.basis;var o := pose.origin
  data[p]=b.x.x;data[p+1]=b.y.x;data[p+2]=b.z.x;data[p+3]=o.x
  data[p+4]=b.x.y;data[p+5]=b.y.y;data[p+6]=b.z.y;data[p+7]=o.y
  data[p+8]=b.x.z;data[p+9]=b.y.z;data[p+10]=b.z.z;data[p+11]=o.z
  data[p+12]=color.r;data[p+13]=color.g;data[p+14]=color.b;data[p+15]=color.a
  if stride==20: data[p+16]=variant;data[p+17]=0.;data[p+18]=0.;data[p+19]=0.
var packets113 := {}
func _ready() -> void:
 super._ready()
 for batch in [airborne,ground,shadows,sugar,sugar_shadows]:
  var multi: MultiMesh=batch.multimesh;var packet := Packet113.new()
  packet.stride=12+(4 if multi.use_colors else 0)+(4 if multi.use_custom_data else 0)
  packet.data.resize(multi.instance_count*packet.stride);packets113[batch.get_instance_id()]=packet
func put113(batch: MultiMeshInstance3D,index: int,pose: Transform3D,color: Color,variant := 0.) -> void:
 var packet: Packet113=packets113[batch.get_instance_id()];packet.put(index,pose,color,variant)
func upload113(batch: MultiMeshInstance3D) -> void:
 if batch.multimesh.visible_instance_count>0: batch.multimesh.buffer=packets113[batch.get_instance_id()].data
func _sync() -> void:
 if not bool(battle.get("combat_budget105")): super._sync();return
 if art_regions.is_empty(): return
 airborne.multimesh.visible_instance_count=drops.size();shadows.multimesh.visible_instance_count=drops.size()
 for i in drops.size():
  var drop: Dictionary=drops[i];var variant: int=drop.get("variant",0)
  var region: Array=art_regions["jelly_sheet_v1.png"][variant];var size: float=drop.size*1.55
  var basis: Basis=battle.camera.global_basis;basis.x*=size;basis.y*=size*float(region[3])/float(region[2]);basis.z*=size
  put113(airborne,i,Transform3D(basis,drop.at),Color.WHITE,float(variant))
  var at: Vector3=drop.at;at.y=battle.floor_height(Vector2(at.x,at.z))+.026
  put113(shadows,i,_ground_transform(at,drop.size*1.5,0.),Color(.12,.24,.17,.22))
 ground.multimesh.visible_instance_count=marks.size()
 for i in marks.size():
  var mark: Dictionary=marks[i];var variant := int(absf(mark.at.x*1000.+mark.at.z*357.))%3+3
  if not mark.has("transform105"): mark.transform105=_ground_transform(mark.at,mark.size,mark.angle)
  var fade: float=1.-smoothstep(mark.life*.55,mark.life,mark.age)
  put113(ground,i,mark.transform105,Color(1,1,1,.58*fade),float(variant))
 upload113(airborne);upload113(shadows);upload113(ground)
func _sync_sugar() -> void:
 if not bool(battle.get("combat_budget105")): super._sync_sugar();return
 if not is_instance_valid(sugar) or art_regions.is_empty(): return
 sugar.multimesh.visible_instance_count=bits.size();sugar_shadows.multimesh.visible_instance_count=bits.size()
 for i in bits.size():
  var bit: Dictionary=bits[i];var variant: int=bit.get("variant",0)
  var region: Array=art_regions["sugar_sheet_v1.png"][variant]
  var basis: Basis=battle.camera.global_basis*Basis(Vector3.BACK,bit.angle)
  if bit.settled:
   if not bit.has("basis105"):
    var normal: Vector3=battle.floor_normal(Vector2(bit.at.x,bit.at.z));var right := Vector3.RIGHT.slide(normal).normalized()
    bit.basis105=Basis(right,normal.cross(right),normal).rotated(normal,bit.angle)
   basis=bit.basis105
  var fade: float=1.-smoothstep(bit.life*.5,bit.life,bit.rest) if bit.settled else 1.
  basis=basis.scaled(Vector3(bit.size,bit.size,bit.size));basis.y*=float(region[3])/float(region[2])
  put113(sugar,i,Transform3D(basis,bit.at),Color(1,1,1,fade),float(variant))
  var at: Vector3=bit.at;at.y=battle.floor_height(Vector2(at.x,at.z))+.025
  if not bit.settled or not bit.has("shadow105"): bit.shadow105=_ground_transform(at,bit.size*1.3,bit.angle)
  put113(sugar_shadows,i,bit.shadow105,Color(.16,.18,.12,.22*fade))
 upload113(sugar);upload113(sugar_shadows)
