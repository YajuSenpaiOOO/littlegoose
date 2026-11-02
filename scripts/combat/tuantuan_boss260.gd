extends "res://scripts/combat/tuantuan_boss259.gd"
func enter247(next: String) -> void:
 var old=phase247;super.enter247(next)
 battle.boss_phase260(old,next)
func land247() -> void:
 if dead or phase247 not in ["flight","pounce"]:return
 battle.boss_landing260(Vector2(position.x,position.z),jump247)
 super.land247()
func deflect(contact: Vector3) -> void:
 var source=battle.parry_kind260;battle.parry_kind260="boss";super.deflect(contact);battle.parry_kind260=source
func crash256() -> void:
 var source=battle.damage_kind260;var before=wall_crashes256
 battle.damage_kind260="wall";super.crash256();battle.damage_kind260=source
 if wall_crashes256>before:battle.wall_crash260()
