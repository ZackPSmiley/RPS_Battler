## Picks a random R/P/S move. Swap implementation later for patterns or difficulty.
class_name EnemyAI
extends RefCounted


func pick_move() -> RoundResolver.Move:
	var roll := randi_range(0, 2)
	match roll:
		0:
			return RoundResolver.Move.ROCK
		1:
			return RoundResolver.Move.PAPER
		_:
			return RoundResolver.Move.SCISSORS
