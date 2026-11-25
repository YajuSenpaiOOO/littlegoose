extends RefCounted
# Connected full-body poses; no third/follow-through image is sampled.
const RELEASE_HOLD := .32
const RECOVER_HOLD := .12
const ENTER_HZ := 4.0
const EXIT_HZ := 3.0
var phase := "idle"
var rapid := false
var since_shot := 100.0
var kick := 0.0
var velocity := 0.0
func advance(dt: float, trigger: bool, rate: float, beam: bool, shot: bool, preparing: bool) -> void:
 since_shot += dt
 if rapid:
  if rate < EXIT_HZ: rapid = false
 elif rate >= ENTER_HZ: rapid = true
 if shot:
  since_shot = 0.0
  velocity = minf(velocity + (.12 if rapid else .65), .8)
 # Spring follows the first kick and adds small impulses without restarting it.
 velocity += (-kick * 170.0 - velocity * 20.0) * dt
 kick += velocity * dt
 var held_release: bool = since_shot < RELEASE_HOLD or (rapid and trigger and since_shot < .4)
 if beam and trigger: phase = "ready"
 elif held_release: phase = "release"
 elif preparing or since_shot < RELEASE_HOLD + RECOVER_HOLD: phase = "ready"
 else: phase = "idle"
