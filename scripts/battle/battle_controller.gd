## Match flow only — all display goes through BattleUI.
extends Control

@onready var ui: BattleUI = $UILayer

var _player: FighterData
var _enemy: FighterData
var _enemy_ai: EnemyAI
## When false, ignore move_chosen (match over or resolving).
var _accepting_round_input: bool = true


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
	_accepting_round_input = true
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


func _on_move_chosen(player_move: RoundResolver.Move) -> void:
	if not _accepting_round_input:
		return
	# Block re-entry until this round is fully resolved (stops double-click races).
	_accepting_round_input = false

	var enemy_move: RoundResolver.Move = _enemy_ai.pick_move()
	var outcome: RoundResolver.Outcome = RoundResolver.resolve(player_move, enemy_move)

	ui.show_moves(
		RoundResolver.move_to_string(player_move),
		RoundResolver.move_to_string(enemy_move)
	)

	if outcome == RoundResolver.Outcome.DRAW:
		ui.show_result("Draw! No damage.")
		_sync_ui_to_state()
		_accepting_round_input = true
		return

	if outcome == RoundResolver.Outcome.PLAYER_WIN:
		_player.streak += 1
		_enemy.streak = 0
		var damage: int = _damage_for_streak(_player.streak)
		_enemy.apply_damage(damage)
		ui.show_result("You win! %d damage dealt." % damage)
	elif outcome == RoundResolver.Outcome.ENEMY_WIN:
		_enemy.streak += 1
		_player.streak = 0
		var damage: int = _damage_for_streak(_enemy.streak)
		_player.apply_damage(damage)
		ui.show_result("Enemy wins! %d damage dealt." % damage)

	_sync_ui_to_state()

	if _player.is_defeated():
		_finish_match(false)
	elif _enemy.is_defeated():
		_finish_match(true)
	else:
		_accepting_round_input = true


func _finish_match(player_won: bool) -> void:
	_accepting_round_input = false
	ui.show_end_screen(player_won)


func _on_restart_requested() -> void:
	start_match()
