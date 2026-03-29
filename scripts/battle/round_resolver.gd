## Pure round resolution — no nodes, no side effects.
class_name RoundResolver
extends RefCounted

enum Move { ROCK, PAPER, SCISSORS }

enum Outcome { PLAYER_WIN, ENEMY_WIN, DRAW }


static func move_to_string(move: Move) -> String:
	match move:
		Move.ROCK:
			return "Rock"
		Move.PAPER:
			return "Paper"
		Move.SCISSORS:
			return "Scissors"
	return "?"


static func resolve(player_move: Move, enemy_move: Move) -> Outcome:
	if player_move == enemy_move:
		return Outcome.DRAW
	match player_move:
		Move.ROCK:
			if enemy_move == Move.SCISSORS:
				return Outcome.PLAYER_WIN
		Move.SCISSORS:
			if enemy_move == Move.PAPER:
				return Outcome.PLAYER_WIN
		Move.PAPER:
			if enemy_move == Move.ROCK:
				return Outcome.PLAYER_WIN
	return Outcome.ENEMY_WIN
