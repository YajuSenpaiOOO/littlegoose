# 189 — reactive lilac tufts, hammock cat, long purple approach

Preview: `res://scenes/world/world189.tscn`; launcher
`preview_forest_mood189.cmd`. F11 moves to the middle of the actual yard-to-
forest navigation path, F6 entrance, F7 cottage, F8 clearing, F10 grade toggle.

All eleven `lilac_ground_clump_pixel.png` instances now use a camera-facing
deformation shader with the same contact/recovery timing as woodland plants:
12/s approach, 5/s release, up to 0.30 m displacement. UV weighting holds the
base and right-side stone while moving the taller foliage.

The new transparent `assets/forest189/hammock_ghost_cat.png` sits at the central
tree's authored cloth coordinates and gently sways. It is decorative and adds
no collision in the walking lanes. Asset generated with built-in imagegen;
the complete prompt is saved in that asset folder's README.

The regional grade uses the actual `connection188` navigation polyline,
progressively increasing from the yard exterior to 82% at the upper entrance,
then full forest strength on the short descending flights. A 4.5–10 m home
exclusion protects the original courtyard. A view-wide canopy contribution
avoids ungraded billboard crowns when the hero is already under the canopy.

Purple/gray shadows replace the old green-heavy fill, with lower exposure.
Warm highlight protection now also requires red above green; yellow-green
leaves previously escaped darkening because they were mistaken for lanterns.
Amber light pools and windows retain more original warmth.

Verification: `forest189_capture.gd` checks all eleven reactive props, actual
hero-triggered displacement, recovery, cat presence, route progression and
home isolation; screenshots cover core, path middle, entrance, cottage, home.
Normal main scene remains `world169`; terrain layout remains the south-moved
188 surface, including its cliff vegetation exclusions.
