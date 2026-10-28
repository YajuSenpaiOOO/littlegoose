# 189 lighting diagnosis — 2026-10-27

User reported apparent hero outline / plush dark-part emission, unusual face
lighting in the forest and at night, and a straight horizontal ground seam.
This audit makes diagnostic captures only; production rendering is unchanged.

## Confirmed runtime state at 22:00

`forest189-light-diagnostic.json` records fill_enabled=false,
fill_light_visible=false, hero_shaded=false, actor_stage57=0.7,
cone_strength58=1.0, night_mix56=1.0. The old body-following OmniLight exists
but is disabled by the default spotlight-only rig.

The hero card is unshaded since hero188. It cannot respond directly to the
native spotlight or local OmniLights. Apparent light on it therefore comes
from source art, vertex color/modulation and screen-space grading. The night
shader restores source color inside a screen ellipse (actor_stage57), and
the forest shader reduces darkening inside the same ellipse (actor186).
Disabling cone integration and then both actor exemptions produces successively
less halo and a substantially darker hero. The ellipse is not an actual
per-pixel actor silhouette and its depth test varies across the upright card.

Both night and forest grades infer warm light from RGB instead of an explicit
emitter mask. This can preserve skin / pink outlines / plush colors that should
be shaded. Forest dark-fill and lamp-pool additive terms can further lift dark
paint. This is not evidence of emissive material on the plush.

## Confirmed horizontal seam

The old route-light atlas bounds are (-64.825,-68.28333,130,86.66666), ending at
world z=18.38333. The forest moved to center z=24 and extends beyond this atlas.
`route_light89.gdshaderinc` samples inside the bounds, then switches instantly
to vec4(.8,.8,.8,0) outside; no border feathering. At diagnostic camera position
(-55,17), the old atlas edge projects to y=625.20 in a 1000px-high capture,
matching the visible horizontal seam. Disabling route_strength50 on the
registered materials removes the seam in the morning A/B captures.

## Repair direction

1. Feather atlas boundaries / extend the lighting field across the new south
   region, using consistent sampling for hero and scenery.
2. Replace overlapping actor ellipse exemptions with one actor-lighting path;
   preserve the source art's relative shading and remove screen cone tint from
   the character where it creates a veiling glow.
3. Protect only actual lamp cores/windows via explicit emitter masks; do not
   classify pink skin / outlines as lights from their color alone.
4. Validate morning, dusk and night with the same fixed framing, including
   the old atlas border and both lit / unlit sides of hero and plush props.

Diagnostic runner: `scripts/world/forest189_light_diagnostic.gd`.
Captures: `docs/captures/world_restart/forest189_lightdiag_*.png`.
