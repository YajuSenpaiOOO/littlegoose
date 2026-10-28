extends RefCounted
## Kinetic conversion preserves old projectile/player and knock/player ratios.
const PPM := 78.3/4.1
const FIRE_CD := .14
const DAMAGE := 1.
const BULLET_SPEED := 213./PPM
const BULLET_LIFE := 1.4
const RECOIL := 23.3/PPM
const KNOCK := 110./PPM
const KNOCK_MAX := 165./PPM
const KNOCK_DECAY := 8.
const HIT_POSE := .12
const HIT_REARM := .055
const FLASH := .075
const CORPSE_LIFE := 6.
const CORPSE_FADE := .3
const DEFEAT_TIME := .28
const HOP_TIME := .5
const HOP_SPEED := 90.*1.5/PPM
const HOP_LIFT := 12./PPM
