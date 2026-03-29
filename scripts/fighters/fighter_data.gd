## Per-fighter state for a match: HP and streak.
class_name FighterData
extends RefCounted

var fighter_name: String = "Fighter"
var max_hp: int = 100
var current_hp: int = 100
var streak: int = 0


func reset_for_match() -> void:
	current_hp = max_hp
	streak = 0


func apply_damage(amount: int) -> void:
	current_hp = maxi(0, current_hp - amount)


func is_defeated() -> bool:
	return current_hp <= 0
