extends "res://scripts/art/prop_relations200.gd"

var shadow_pairs_by_visual: Dictionary={}
var shadow_root_revision: int=-1

func sync_tree_shadows199(delta: float) -> void:
 if not is_instance_valid(world.whole67) or not world.whole67.improved:
  shadow_root_revision=-1
  super.sync_tree_shadows199(delta)
  return
 if delta==0. or shadow_root_revision!=world.root_revision67:
  shadow_root_revision=world.root_revision67
  shadow_pairs_by_visual.clear()
  for pair in shadow_pairs:
   if is_instance_valid(pair.visual):
    shadow_pairs_by_visual[pair.visual.get_instance_id()]=pair
  super.sync_tree_shadows199(delta)
  return
 # The foliage manager records fades and resets before this rendering pass.
 for visual_id in world.whole67.changed67:
  if shadow_pairs_by_visual.has(visual_id):
   sync_tree_shadow199(shadow_pairs_by_visual[visual_id])
