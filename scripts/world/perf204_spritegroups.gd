extends "res://scripts/world/perf_world_probe.gd"
# Which sprite groups share texture+shader (batchable without texture
# arrays) vs unique ones? Census over the whole tree at the forest view.
func world_script_perf() -> Script: return preload("res://scripts/world/woodland_world204.gd"
)
func out_path_perf() -> String: return "res://docs/perf204-spritegroups-report.json"
func prefix_perf() -> String: return "perf204groups"
func spots_perf() -> void:
 sample._teleport15(Vector2(-48.,24.));await hour(12.);await settle(150)
 var forest: Node=sample.get("forest188")
 var groups := {}
 var stack: Array=[forest]
 var total := 0
 while not stack.is_empty():
  var node: Node=stack.pop_back()
  for child in node.get_children(): stack.push_back(child)
  if node is Sprite3D and node.is_visible_in_tree():
   total+=1
   var material: Material=node.material_override
   var key := "noscript"
   if material is ShaderMaterial and material.shader!=null: key=str(hash(material.shader.code))
   var texture: Texture2D=node.texture
   var atlas: Texture2D=texture.atlas if texture is AtlasTexture else texture
   var gkey := str(atlas.get_instance_id())+"/"+key
   if not groups.has(gkey): groups[gkey]={"count":0,"texture":"","shader":"","animated":false}
   groups[gkey].count+=1
   groups[gkey].texture=atlas.resource_path
   # wind/clock uniforms mark animated materials
   if material is ShaderMaterial and material.shader!=null:
    var code: String=material.shader.code
    groups[gkey].animated=groups[gkey].animated or code.contains("wind_clock") or code.contains("phase") or code.contains("TIME")
 var rows: Array=[]
 for gkey in groups: rows.append(groups[gkey])
 rows.sort_custom(func(a,b): return a.count>b.count)
 var batchable := 0
 for row in rows:
  if row.count>1 and not row.animated: batchable+=row.count
 print("SPRITEGROUPS total=",total," distinct=",rows.size()," static-shared=",batchable)
 report.total=total;report.distinct=rows.size();report.batchable_static_shared=batchable
 report.groups=rows.slice(0,14)
 for row in rows.slice(0,14): print("SPRITEGROUP ",JSON.stringify(row))
