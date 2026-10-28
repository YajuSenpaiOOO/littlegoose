extends "res://scripts/combat/material_fx33.gd"
# Integration and hit feedback remain inherited. Write each instance only once,
# instead of the old base upload followed by an overwrite for the painted atlas.
func _sync() -> void:
 if not bool(battle.get("combat_budget105")): super._sync();return
 if art_regions.is_empty(): return
 airborne.multimesh.visible_instance_count=drops.size();shadows.multimesh.visible_instance_count=drops.size()
 for i in drops.size():
  var drop: Dictionary=drops[i];var variant: int=drop.get("variant",0)
  var region: Array=art_regions["jelly_sheet_v1.png"][variant];var size: float=drop.size*1.55
  var basis: Basis=battle.camera.global_basis;basis.x*=size;basis.y*=size*float(region[3])/float(region[2]);basis.z*=size
  airborne.multimesh.set_instance_transform(i,Transform3D(basis,drop.at));airborne.multimesh.set_instance_color(i,Color.WHITE);airborne.multimesh.set_instance_custom_data(i,Color(variant,0,0,0))
  var at: Vector3=drop.at;at.y=battle.floor_height(Vector2(at.x,at.z))+.026
  shadows.multimesh.set_instance_transform(i,_ground_transform(at,drop.size*1.5,0.));shadows.multimesh.set_instance_color(i,Color(.12,.24,.17,.22))
 ground.multimesh.visible_instance_count=marks.size()
 for i in marks.size():
  var mark: Dictionary=marks[i];var variant := int(absf(mark.at.x*1000.+mark.at.z*357.))%3+3
  if not mark.has("transform105"): mark.transform105=_ground_transform(mark.at,mark.size,mark.angle)
  var fade: float=1.-smoothstep(mark.life*.55,mark.life,mark.age)
  ground.multimesh.set_instance_transform(i,mark.transform105);ground.multimesh.set_instance_color(i,Color(1,1,1,.58*fade));ground.multimesh.set_instance_custom_data(i,Color(variant,0,0,0))
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
  sugar.multimesh.set_instance_transform(i,Transform3D(basis,bit.at));sugar.multimesh.set_instance_color(i,Color(1,1,1,fade));sugar.multimesh.set_instance_custom_data(i,Color(variant,0,0,0))
  var at: Vector3=bit.at;at.y=battle.floor_height(Vector2(at.x,at.z))+.025
  if not bit.settled or not bit.has("shadow105"): bit.shadow105=_ground_transform(at,bit.size*1.3,bit.angle)
  sugar_shadows.multimesh.set_instance_transform(i,bit.shadow105);sugar_shadows.multimesh.set_instance_color(i,Color(.16,.18,.12,.22*fade))
