## All battle HUD updates, feedback, and input signals.
class_name BattleUI
extends Control

signal move_chosen(move: RoundResolver.Move)
signal restart_requested

@onready var player_hp_label: Label = $Margin/VBox/HPLabels/PlayerHPLabel
@onready var enemy_hp_label: Label = $Margin/VBox/HPLabels/EnemyHPLabel
@onready var player_streak_label: Label = $Margin/VBox/StreakLabels/PlayerStreakLabel
@onready var enemy_streak_label: Label = $Margin/VBox/StreakLabels/EnemyStreakLabel
@onready var player_move_label: Label = $Margin/VBox/PlayerMoveLabel
@onready var enemy_move_label: Label = $Margin/VBox/EnemyMoveLabel
@onready var round_result_label: Label = $Margin/VBox/RoundResultLabel
@onready var match_end_label: Label = $Margin/VBox/MatchEndLabel
@onready var rock_button: Button = $Margin/VBox/ChoiceRow/RockButton
@onready var paper_button: Button = $Margin/VBox/ChoiceRow/PaperButton
@onready var scissors_button: Button = $Margin/VBox/ChoiceRow/ScissorsButton
@onready var restart_button: Button = $Margin/VBox/RestartButton

@onready var player_fighter_root: Control = $Margin/VBox/FighterRow/PlayerSide/PlayerFighterRoot
@onready var enemy_fighter_root: Control = $Margin/VBox/FighterRow/EnemySide/EnemyFighterRoot
@onready var player_body: ColorRect = $Margin/VBox/FighterRow/PlayerSide/PlayerFighterRoot/PlayerBody
@onready var enemy_body: ColorRect = $Margin/VBox/FighterRow/EnemySide/EnemyFighterRoot/EnemyBody

var _player_base_color: Color
var _enemy_base_color: Color
var _fighter_feedback_tween: Tween = null
var _streak_pulse_tween: Tween = null


func _ready() -> void:
	_player_base_color = player_body.color
	_enemy_base_color = enemy_body.color
	player_fighter_root.pivot_offset = player_fighter_root.size / 2.0
	enemy_fighter_root.pivot_offset = enemy_fighter_root.size / 2.0
	player_fighter_root.resized.connect(_on_player_fighter_resized)
	enemy_fighter_root.resized.connect(_on_enemy_fighter_resized)
	_connect_buttons()


func _on_player_fighter_resized() -> void:
	player_fighter_root.pivot_offset = player_fighter_root.size / 2.0


func _on_enemy_fighter_resized() -> void:
	enemy_fighter_root.pivot_offset = enemy_fighter_root.size / 2.0


func _connect_buttons() -> void:
	rock_button.pressed.connect(_on_rock_pressed)
	paper_button.pressed.connect(_on_paper_pressed)
	scissors_button.pressed.connect(_on_scissors_pressed)
	restart_button.pressed.connect(_on_restart_pressed)


func _on_rock_pressed() -> void:
	move_chosen.emit(RoundResolver.Move.ROCK)


func _on_paper_pressed() -> void:
	move_chosen.emit(RoundResolver.Move.PAPER)


func _on_scissors_pressed() -> void:
	move_chosen.emit(RoundResolver.Move.SCISSORS)


func _on_restart_pressed() -> void:
	restart_requested.emit()


func update_hp(player_hp: int, enemy_hp: int) -> void:
	player_hp_label.text = "Player HP: %d" % player_hp
	enemy_hp_label.text = "Enemy HP: %d" % enemy_hp


func update_streaks(player_streak: int, enemy_streak: int) -> void:
	player_streak_label.text = "Player streak: %d" % player_streak
	enemy_streak_label.text = "Enemy streak: %d" % enemy_streak


func show_moves(player_move: String, enemy_move: String) -> void:
	player_move_label.text = "Your move: %s" % player_move
	enemy_move_label.text = "Enemy move: %s" % enemy_move


func show_result(text: String) -> void:
	round_result_label.text = text


## Single place to refresh move lines + round copy after a resolve.
func show_round_resolution(player_move: String, enemy_move: String, result_text: String) -> void:
	show_moves(player_move, enemy_move)
	show_result(result_text)


func show_end_screen(player_won: bool) -> void:
	match_end_label.visible = true
	match_end_label.text = "Player Wins!" if player_won else "Enemy Wins!"
	restart_button.visible = true
	set_controls_locked(true)


func hide_end_screen() -> void:
	match_end_label.visible = false
	match_end_label.text = ""
	restart_button.visible = false


func set_controls_locked(locked: bool) -> void:
	rock_button.disabled = locked
	paper_button.disabled = locked
	scissors_button.disabled = locked


func reset_visual_state() -> void:
	_kill_fighter_tween()
	_kill_streak_tween()
	player_fighter_root.scale = Vector2.ONE
	enemy_fighter_root.scale = Vector2.ONE
	player_fighter_root.rotation_degrees = 0.0
	enemy_fighter_root.rotation_degrees = 0.0
	player_body.color = _player_base_color
	enemy_body.color = _enemy_base_color
	player_streak_label.modulate = Color.WHITE
	enemy_streak_label.modulate = Color.WHITE
	player_streak_label.scale = Vector2.ONE
	enemy_streak_label.scale = Vector2.ONE


## Full UI reset at match start: visuals, labels, end chrome, input unlocked.
func reset_match_ui() -> void:
	reset_visual_state()
	hide_end_screen()
	show_round_resolution("—", "—", "Pick Rock, Paper, or Scissors.")
	set_controls_locked(false)


func flash_player_hit(damage: int) -> void:
	_play_hit_feedback(player_body, player_fighter_root, _player_base_color, damage, 1.0)


func flash_enemy_hit(damage: int) -> void:
	_play_hit_feedback(enemy_body, enemy_fighter_root, _enemy_base_color, damage, -1.0)


func _feedback_strength(damage: int) -> float:
	return clampf(float(damage) / 22.0, 0.35, 1.0)


func _play_hit_feedback(body: ColorRect, root: Control, base_color: Color, damage: int, nudge_dir: float) -> void:
	_kill_fighter_tween()
	var strength := _feedback_strength(damage)
	var flash_color := base_color.lerp(Color(1.0, 0.45, 0.35), 0.65 + 0.2 * strength)
	var punch := 1.0 + 0.04 + 0.06 * strength
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(body, "color", flash_color, 0.04 * strength)
	tw.tween_property(root, "scale", Vector2(punch, punch), 0.05)
	tw.tween_property(root, "rotation_degrees", 5.0 * nudge_dir * strength, 0.05)
	tw.chain()
	tw.set_parallel(true)
	tw.tween_property(body, "color", base_color, 0.11 + 0.05 * strength)
	tw.tween_property(root, "scale", Vector2.ONE, 0.1)
	tw.tween_property(root, "rotation_degrees", 0.0, 0.1)
	_fighter_feedback_tween = tw


func _kill_fighter_tween() -> void:
	if _fighter_feedback_tween != null and is_instance_valid(_fighter_feedback_tween):
		_fighter_feedback_tween.kill()
	_fighter_feedback_tween = null


func pulse_streak_label(is_player: bool) -> void:
	_kill_streak_tween()
	var lbl: Label = player_streak_label if is_player else enemy_streak_label
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "modulate", Color(1.2, 1.15, 0.75), 0.07)
	tw.tween_property(lbl, "scale", Vector2(1.08, 1.08), 0.08)
	tw.chain()
	tw.set_parallel(true)
	tw.tween_property(lbl, "modulate", Color.WHITE, 0.18)
	tw.tween_property(lbl, "scale", Vector2.ONE, 0.14)
	_streak_pulse_tween = tw


func _kill_streak_tween() -> void:
	if _streak_pulse_tween != null and is_instance_valid(_streak_pulse_tween):
		_streak_pulse_tween.kill()
	_streak_pulse_tween = null
