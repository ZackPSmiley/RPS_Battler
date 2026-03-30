## Match flow only — all display and feedback go through BattleUI.
extends Control

enum BattleState {
	INPUT_OPEN,
	ROUND_RESOLVING,
	MATCH_OVER,
}

@onready var ui: BattleUI = $UILayer

var _state: BattleState = BattleState.INPUT_OPEN
var _player: FighterData
var _enemy: FighterData
var _enemy_ai: EnemyAI


func _ready() -> void:
	randomize()
	_player = FighterData.new()
	_player.fighter_name = "Player"
	_enemy = FighterData.new()
	_enemy.fighter_name = "Enemy"
	_enemy_ai = EnemyAI.new()
	ui.move_chosen.connect(_on_move_chosen)
	ui.restart_requested.connect(_on_restart_requested)
	start_match()


func start_match() -> void:
	_state = BattleState.INPUT_OPEN
	_player.reset_for_match()
	_enemy.reset_for_match()
	ui.reset_match_ui()
	_sync_ui_to_state()


func _sync_ui_to_state() -> void:
	ui.update_hp(_player.current_hp, _enemy.current_hp)
	ui.update_streaks(_player.streak, _enemy.streak)


static func _damage_for_streak(streak: int) -> int:
	match streak:
		1:
			return 6
		2:
			return 10
		3:
			return 15
		_:
			return 22 if streak >= 4 else 0


static func _hit_feedback_strength(damage: int) -> float:
	return clampf(float(damage) / 22.0, 0.35, 1.0)


static func _win_flavor_suffix(winner_streak: int, player_won: bool) -> String:
	if winner_streak <= 1:
		return ""
	if winner_streak == 2:
		return " Building momentum."
	if winner_streak == 3:
		return " Momentum rising!"
	if winner_streak >= 4:
		return " Finisher pressure!" if player_won else " Brutal streak!"
	return ""


static func _build_win_result_text(player_won: bool, damage: int, winner_streak: int) -> String:
	var line: String = (
		"You win! %d damage dealt." % damage
		if player_won
		else "Enemy wins! %d damage dealt." % damage
	)
	return line + _win_flavor_suffix(winner_streak, player_won)


func _on_move_chosen(player_move: RoundResolver.Move) -> void:
	if _state != BattleState.INPUT_OPEN:
		return
	_state = BattleState.ROUND_RESOLVING

	var enemy_move: RoundResolver.Move = _enemy_ai.pick_move()
	var outcome: RoundResolver.Outcome = RoundResolver.resolve(player_move, enemy_move)

	var p_str: String = RoundResolver.move_to_string(player_move)
	var e_str: String = RoundResolver.move_to_string(enemy_move)

	if outcome == RoundResolver.Outcome.DRAW:
		ui.show_round_resolution(p_str, e_str, "Draw! No damage.")
		_sync_ui_to_state()
		_state = BattleState.INPUT_OPEN
		return

	if outcome == RoundResolver.Outcome.PLAYER_WIN:
		_player.streak += 1
		_enemy.streak = 0
		var damage: int = _damage_for_streak(_player.streak)
		_enemy.apply_damage(damage)
		ui.show_round_resolution(p_str, e_str, _build_win_result_text(true, damage, _player.streak))
		ui.flash_enemy_hit(_hit_feedback_strength(damage))
		ui.pulse_player_streak(_player.streak)
	elif outcome == RoundResolver.Outcome.ENEMY_WIN:
		_enemy.streak += 1
		_player.streak = 0
		var damage: int = _damage_for_streak(_enemy.streak)
		_player.apply_damage(damage)
		ui.show_round_resolution(p_str, e_str, _build_win_result_text(false, damage, _enemy.streak))
		ui.flash_player_hit(_hit_feedback_strength(damage))
		ui.pulse_enemy_streak(_enemy.streak)

	_sync_ui_to_state()

	if _player.is_defeated():
		_finish_match(false)
	elif _enemy.is_defeated():
		_finish_match(true)
	else:
		_state = BattleState.INPUT_OPEN


func _finish_match(player_won: bool) -> void:
	_state = BattleState.MATCH_OVER
	ui.show_end_screen(player_won)


func _on_restart_requested() -> void:
	start_match()
