## Owns match flow: choices → resolve → streaks → damage → UI → win/lose.
extends Control

@onready var ui: BattleUI = $UILayer

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
	_player.reset_for_match()
	_enemy.reset_for_match()
	ui.set_choice_buttons_enabled(true)
	ui.set_match_end(false, "")
	ui.show_restart(false)
	_refresh_full_ui()
	ui.set_round_result("Pick Rock, Paper, or Scissors.")
	ui.set_move_labels("—", "—")


func _refresh_full_ui() -> void:
	ui.set_hp_display(_player.current_hp, _enemy.current_hp)
	ui.set_streak_display(_player.streak, _enemy.streak)


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


func _on_move_chosen(player_move: RoundResolver.Move) -> void:
	var enemy_move: RoundResolver.Move = _enemy_ai.pick_move()
	var outcome: String = RoundResolver.resolve(player_move, enemy_move)

	ui.set_move_labels(
		RoundResolver.move_to_string(player_move),
		RoundResolver.move_to_string(enemy_move)
	)

	if outcome == RoundResolver.OUTCOME_DRAW:
		ui.set_round_result("Draw! No damage.")
		_refresh_full_ui()
		return

	var damage: int = 0
	if outcome == RoundResolver.OUTCOME_PLAYER_WIN:
		_player.streak += 1
		_enemy.streak = 0
		damage = _damage_for_streak(_player.streak)
		_enemy.apply_damage(damage)
		ui.set_round_result("You win! %d damage dealt." % damage)
	elif outcome == RoundResolver.OUTCOME_ENEMY_WIN:
		_enemy.streak += 1
		_player.streak = 0
		damage = _damage_for_streak(_enemy.streak)
		_player.apply_damage(damage)
		ui.set_round_result("Enemy wins! %d damage dealt." % damage)

	_refresh_full_ui()
	_check_match_end()


func _check_match_end() -> void:
	if _player.is_defeated():
		_end_match("Enemy Wins!")
	elif _enemy.is_defeated():
		_end_match("Player Wins!")


func _end_match(message: String) -> void:
	ui.set_choice_buttons_enabled(false)
	ui.set_match_end(true, message)
	ui.show_restart(true)


func _on_restart_requested() -> void:
	start_match()
