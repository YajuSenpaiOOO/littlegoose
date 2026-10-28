extends "res://scripts/world/woodland_world166.gd"
var arc_shadows167: MultiMeshInstance3D
var arc_shadow_count167 := 0
func _init() -> void:
 buffs=preload("res://scripts/combat/buff_book167.gd").new();buffs.rng110.randomize()
 memory_kit116=preload("res://scripts/combat/memory_kit167.gd").new();memory_save116="user://delayed_dance167.cfg"
func _skills_script110() -> Script: return preload("res://scripts/combat/battle_skills167.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 167 · 闪后舞步 / 糖屑落影")
func announce152() -> void:
 if is_instance_valid(encounter_hud): encounter_hud.announce(BUILDS166[build166].name,"Shift掠过留下舞步 · 闪避结束后延迟三连 · 糖屑补地面投影",3.)
func _ready() -> void:
 super._ready()
 while not is_instance_valid(moment161): await get_tree().physics_frame
 arc_shadows167=MultiMeshInstance3D.new();arc_shadows167.name="BallisticCrumbGroundShadows167"
 var mesh := PlaneMesh.new();mesh.size=Vector2(.26,.18)
 var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D;multi.use_colors=true;multi.mesh=mesh;multi.instance_count=96;multi.visible_instance_count=0
 arc_shadows167.multimesh=multi;arc_shadows167.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/projectile_shadow110.gdshader");arc_shadows167.material_override=ink;add_child(arc_shadows167)
 if "--dance167" in OS.get_cmdline_user_args(): trial152=true;paper_trial129=false;start_combat()
func _draw_projectile_shadows105() -> void:
 super._draw_projectile_shadows105()
 if not is_instance_valid(arc_shadows167): return
 var count := 0
 for shot in shots:
  if not shot.get("arc166",false): continue
  if count>=96: break
  var at: Vector3=shot.node.get_global_transform_interpolated().origin
  if not camera.is_position_in_frustum(at): continue
  var p := Vector2(at.x,at.z);var ground := floor_height(p);var height := maxf(0.,at.y-ground)
  var sun_flat := Vector2(-sun.global_basis.z.x,-sun.global_basis.z.z).normalized()
  p+=sun_flat*minf(.35,height*.12);ground=floor_height(p)
  var normal := Vector3(-(floor_height(p+Vector2(.08,0.))-ground)/.08,1.,-(floor_height(p+Vector2(0.,.08))-ground)/.08).normalized()
  var right := Vector3.FORWARD.cross(normal).normalized();var forward := right.cross(normal)
  var size := lerpf(1.,.65,clampf(height/3.,0.,1.))
  arc_shadows167.multimesh.set_instance_transform(count,Transform3D(Basis(right,normal,forward).scaled(Vector3(size,1.,size)),Vector3(p.x,ground+.045,p.y)))
  arc_shadows167.multimesh.set_instance_color(count,Color(1.,1.,1.,clampf(.34-height*.045,.14,.34)));count+=1
 arc_shadows167.multimesh.visible_instance_count=count;arc_shadow_count167=count
func _clear_combat_shots() -> void:
 super._clear_combat_shots();arc_shadow_count167=0
 if is_instance_valid(skills110): skills110.marks167.clear()
 if is_instance_valid(arc_shadows167): arc_shadows167.multimesh.visible_instance_count=0
