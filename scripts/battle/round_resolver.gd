## Pure round resolution: compares moves and returns an outcome string.
## No UI; safe to unit-test or reuse from AI/tools later.
class_name RoundResolver
extends RefCounted

enum Move { ROCK, PAPER, SCISSORS }

const OUTCOME_PLAYER_WIN := "player_win"
const OUTCOME_ENEMY_WIN := "enemy_win"
const OUTCOME_DRAW := "draw"


static func move_to_string(move: Move) -> String:
	match move:
		Move.ROCK:
			return "Rock"
		Move.PAPER:
			return "Paper"
		Move.SCISSORS:
			return "Scissors"
	return "?"


static func resolve(player_move: Move, enemy_move: Move) -> String:
	if player_move == enemy_move:
		return OUTCOME_DRAW
	# Rock beats Scissors, Scissors beats Paper, Paper beats Rock
	match player_move:
		Move.ROCK:
			if enemy_move == Move.SCISSORS:
				return OUTCOME_PLAYER_WIN
		Move.SCISSORS:
			if enemy_move == Move.PAPER:
				return OUTCOME_PLAYER_WIN
		Move.PAPER:
			if enemy_move == Move.ROCK:
				return OUTCOME_PLAYER_WIN
	return OUTCOME_ENEMY_WIN
