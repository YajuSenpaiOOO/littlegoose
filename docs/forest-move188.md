# 188: south-moved scary forest and source-pixel prop pass

- Forest center moved from `(-48, 0)` to `(-48, 24)`.
- The established map origin and north/east/west bounds are unchanged. Only
  the south edge grows by 30 m. The old forest site returns to the inherited
  `world_surface142` terrain.
- The invisible perimeter collider created before the derived surface swap is
  also moved south; otherwise the old z=18.383 boundary becomes an invisible
  wall through the new approach.
- Grass, inherited trees, plants and rocks are removed from local surfaces
  below the specified normal thresholds (`0.90` for grass/rocks, `0.92` for
  trees/plants). The authored cliff faces therefore stay bare.
- 187's runtime pseudo-pixel shader is removed. The yarn corner, supported
  nightlight and small lilac ground tuft are new transparent source images in
  `assets/forest188`, generated for chunky logical pixels and low detail.
- Branch lamps are anchored once after the final tree split instead of being
  repositioned every frame. Local OmniLight energy/range is capped.
- Hero Sprite3D is unshaded in this prototype so individual OmniLights cannot
  sweep across the face. The regional grade still integrates the actor at a
  reduced strength.

Validation: `scripts/world/forest188_capture.gd` passed 14/14 checks, including
old-site terrain equality, south-only bounds expansion, cliff vegetation
clearance, transparent prop corners, fixed lamp anchors, and a real-collision
walk through the relocated inner route. Captures are under
`docs/captures/world_restart/forest188_*.png`.

This remains an isolated prototype. `project.godot` and the normal `world169`
main scene are unchanged; the >=3 black-goose gate is still design-only.
