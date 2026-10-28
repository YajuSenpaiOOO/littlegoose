extends SceneTree
# Read-only mathematical surface survey; no scene instantiated or data saved.
func _initialize() -> void:
 var surface := preload("res://scripts/world/world_surface142.gd").new()
 var points := {}
 for at in [Vector2(-15.,-3.),Vector2(-24.,2.),Vector2(-33.,-2.),Vector2(-48.,0.),Vector2(-62.,-8.),Vector2(-62.,12.),Vector2(-35.,12.),Vector2(-48.,-16.)]:
  points[str(at)]={"height":surface.walk_height(at,true),"normal_y":surface.normal_at(at.x,at.y,true).y,"in_bounds":surface.world_bounds.has_point(at),"water":surface.is_water(at)}
 print("FOREST_SITE175 ",JSON.stringify({"bounds_position":str(surface.world_bounds.position),"bounds_size":str(surface.world_bounds.size),"home":str(surface.landmarks.home),"old_grove":str(surface.landmarks.grove),"candidate_body":"x -62..-34, z -12..12 (28x24m)","samples":points}));quit()
