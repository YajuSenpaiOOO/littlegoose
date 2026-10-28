extends SceneTree
## Read-only runtime inventory. Presence is not visual/physics acceptance.
var world: Node3D
func _initialize() -> void: run.call_deferred()
func script_path(node: Node) -> String:
 return node.get_script().resource_path if node.get_script()!=null else ""
func ancestors(node: Node) -> String:
 var result := "";var current := node
 while current!=null and current!=world:
  result+=" "+script_path(current);current=current.get_parent()
 return result
func group_for(node: Node) -> String:
 var scripts := ancestors(node)
 if node==world.hero.visual: return "hero"
 if "goose" in scripts and not "world" in script_path(node): return "goose_or_goose_effect"
 if "spider" in scripts: return "spider"
 if "tuantuan" in scripts or "paper" in scripts: return "enemy"
 if world.forest188.is_ancestor_of(node): return "scary_forest_art"
 if world.station81.is_ancestor_of(node): return "station"
 return "other_requires_classification"
func run() -> void:
 world=preload("res://scripts/world/woodland_world197.gd").new();world.memory_save116="user://display198_audit_tmp.cfg";root.add_child(world)
 while not is_instance_valid(world.lighting191): await physics_frame
 for i in 100: await process_frame
 world.hero.controls_enabled=false
 var sprites: Array=[];var colliders: Array=[];var shadows: Array=[];var counts := {};var groups := {}
 for node in world.find_children("*","Sprite3D",true,false):
  var material: Material=node.material_override
  var group := group_for(node);groups[group]=int(groups.get(group,0))+1
  var mode := "camera_facing" if node.billboard==BaseMaterial3D.BILLBOARD_ENABLED else ("upright_y_billboard" if node.billboard==BaseMaterial3D.BILLBOARD_FIXED_Y else "explicit_transform")
  counts[mode]=int(counts.get(mode,0))+1
  sprites.append({"path":str(world.get_path_to(node)),"group":group,"texture":node.texture.resource_path if node.texture!=null else "","billboard":node.billboard,"rotation":str(node.global_rotation_degrees),"position":str(node.global_position),"pixel_size":node.pixel_size,"visible":node.is_visible_in_tree(),"material":material.get_class() if material!=null else "Sprite3D built-in","shader":material.shader.resource_path if material is ShaderMaterial and material.shader!=null else "","native_cast_shadow":node.cast_shadow,"nearest_ancestor_script":ancestors(node)})
 for node in world.find_children("*","CollisionShape3D",true,false):
  colliders.append({"path":str(world.get_path_to(node)),"shape":node.shape.get_class() if node.shape!=null else "none","shape_description":str(node.shape),"position":str(node.global_position),"disabled":node.disabled,"owner_script":script_path(node.get_parent())})
 for node in world.find_children("*","GeometryInstance3D",true,false):
  if node.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY or "shadow" in script_path(node):
   shadows.append({"path":str(world.get_path_to(node)),"script":script_path(node),"cast_mode":node.cast_shadow,"mesh":node.mesh.get_class() if node is MeshInstance3D and node.mesh!=null else "","position":str(node.global_position),"visible":node.visible})
 var current_scripts := {"enemy_factory":world._enemy_script().resource_path,"hero_factory":world._hero_script().resource_path,"spider_inherits":"spider173 -> spider172 -> spider171 -> spider170 -> tuantuan121 -> ... -> tuantuan30 (upright)","goose_inherits":"goose168 -> goose110 -> goose29 -> goose24 -> goose23 (fixed-Y)"}
 var summary := {"sprite_count":sprites.size(),"collider_count":colliders.size(),"shadow_nodes":shadows.size(),"orientation_counts":counts,"groups":groups,"registered_world_trees":world.trees.size(),"forest_post_colliders":world.forest188.lamp_bodies182.size(),"forest_rack_colliders":world.forest188.rack_bodies182.size(),"hammock_trunk_colliders":world.forest188.trunk_bodies194.size(),"native_forest_proxy_casters":world.lighting191.casters.size(),"factory_scripts":current_scripts}
 var report := {"summary":summary,"coverage":"Initial runtime inventory, not all spawns/states and not a pass/fail acceptance test. Other group needs classification; collider proximity does not establish correct footprint.","sprites":sprites,"colliders":colliders,"shadow_sources":shadows}
 FileAccess.open("res://docs/display198-inventory.json",FileAccess.WRITE).store_string(JSON.stringify(report," "))
 print("DISPLAY198_INVENTORY ",JSON.stringify(summary));DirAccess.remove_absolute(ProjectSettings.globalize_path(world.memory_save116));quit()
