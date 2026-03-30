## Presentation + input: controller calls these methods only (no direct node grabs elsewhere).
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

## Placeholder fighter ColorRects (hit feedback runs on these nodes).
@onready var player_body: ColorRect = $Margin/VBox/FighterRow/PlayerSide/PlayerFighterRoot/PlayerBody
@onready var enemy_body: ColorRect = $Margin/VBox/FighterRow/EnemySide/EnemyFighterRoot/EnemyBody

var _player_base_color: Color
var _enemy_base_color: Color
var _fighter_feedback_tween: Tween = null
var _streak_pulse_tween: Tween = null


func _ready() -> void:
	_player_base_color = player_body.color
	_enemy_base_color = enemy_body.color
	_refresh_body_pivots()
	player_body.resized.connect(_refresh_body_pivots)
	enemy_body.resized.connect(_refresh_body_pivots)
	_connect_buttons()


func _refresh_body_pivots() -> void:
	player_body.pivot_offset = player_body.size / 2.0
	enemy_body.pivot_offset = enemy_body.size / 2.0


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
	player_body.scale = Vector2.ONE
	enemy_body.scale = Vector2.ONE
	player_body.position = Vector2.ZERO
	enemy_body.position = Vector2.ZERO
	player_body.rotation_degrees = 0.0
	enemy_body.rotation_degrees = 0.0
	player_body.color = _player_base_color
	enemy_body.color = _enemy_base_color
	player_body.modulate = Color.WHITE
	enemy_body.modulate = Color.WHITE
	player_streak_label.modulate = Color.WHITE
	enemy_streak_label.modulate = Color.WHITE
	player_streak_label.scale = Vector2.ONE
	enemy_streak_label.scale = Vector2.ONE


func reset_match_ui() -> void:
	reset_visual_state()
	hide_end_screen()
	show_round_resolution("—", "—", "Pick Rock, Paper, or Scissors.")
	set_controls_locked(false)


## strength 0.35–1.0 typical; controller derives from damage.
func flash_player_hit(strength: float = 1.0) -> void:
	_play_body_hit_feedback(player_body, _player_base_color, strength, 1.0)


func flash_enemy_hit(strength: float = 1.0) -> void:
	_play_body_hit_feedback(enemy_body, _enemy_base_color, strength, -1.0)


func _play_body_hit_feedback(body: ColorRect, base_color: Color, strength: float, recoil_dir: float) -> void:
	_kill_fighter_tween()
	var s: float = clampf(strength, 0.2, 1.5)
	var flash := base_color.lerp(Color(1.0, 1.0, 1.0), 0.45 + 0.35 * s)
	var squash := Vector2(1.0 + 0.05 * s, 1.0 - 0.04 * s)
	var recoil_px: float = 10.0 * recoil_dir * s
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(body, "color", flash, 0.04 * s)
	tw.tween_property(body, "scale", squash, 0.05)
	tw.tween_property(body, "position", Vector2(recoil_px, 0.0), 0.05)
	tw.chain()
	tw.set_parallel(true)
	tw.tween_property(body, "color", base_color, 0.1 + 0.05 * s)
	tw.tween_property(body, "scale", Vector2.ONE, 0.1)
	tw.tween_property(body, "position", Vector2.ZERO, 0.1)
	_fighter_feedback_tween = tw


func _kill_fighter_tween() -> void:
	if _fighter_feedback_tween != null and is_instance_valid(_fighter_feedback_tween):
		_fighter_feedback_tween.kill()
	_fighter_feedback_tween = null


## Pass current winner streak so 3+ can pulse harder.
func pulse_player_streak(streak_value: int = 1) -> void:
	_pulse_streak_label(player_streak_label, streak_value)


func pulse_enemy_streak(streak_value: int = 1) -> void:
	_pulse_streak_label(enemy_streak_label, streak_value)


func _pulse_streak_label(lbl: Label, streak_value: int) -> void:
	_kill_streak_tween()
	var dramatic: bool = streak_value >= 3
	var peak_mod := Color(1.25, 1.2, 0.7) if dramatic else Color(1.2, 1.15, 0.75)
	var peak_scale := Vector2(1.12, 1.12) if dramatic else Vector2(1.08, 1.08)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "modulate", peak_mod, 0.07)
	tw.tween_property(lbl, "scale", peak_scale, 0.08)
	tw.chain()
	tw.set_parallel(true)
	tw.tween_property(lbl, "modulate", Color.WHITE, 0.2 if dramatic else 0.18)
	tw.tween_property(lbl, "scale", Vector2.ONE, 0.16 if dramatic else 0.14)
	_streak_pulse_tween = tw


func _kill_streak_tween() -> void:
	if _streak_pulse_tween != null and is_instance_valid(_streak_pulse_tween):
		_streak_pulse_tween.kill()
	_streak_pulse_tween = null
