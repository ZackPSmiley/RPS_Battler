## Random R/P/S for now. Structure supports future weighted or biased picks.
class_name EnemyAI
extends RefCounted

## Placeholder for later difficulty tuning (does not change behavior yet).
enum Personality { BALANCED, AGGRESSIVE, CAUTIOUS }

var personality: Personality = Personality.BALANCED
var difficulty: int = 1


func pick_move() -> RoundResolver.Move:
	return _pick_random_uniform()


func _pick_random_uniform() -> RoundResolver.Move:
	var roll := randi_range(0, 2)
	match roll:
		0:
			return RoundResolver.Move.ROCK
		1:
			return RoundResolver.Move.PAPER
		_:
			return RoundResolver.Move.SCISSORS
