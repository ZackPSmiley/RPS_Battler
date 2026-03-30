## Presentation + input: controller calls these methods only.
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

@onready var button_sfx: AudioStreamPlayer = $ButtonSfx
@onready var hit_sfx: AudioStreamPlayer = $HitSfx
@onready var big_hit_sfx: AudioStreamPlayer = $BigHitSfx
@onready var win_sfx: AudioStreamPlayer = $WinSfx

var _player_base_color: Color
var _enemy_base_color: Color
var _player_root_rest: Vector2 = Vector2.ZERO
var _enemy_root_rest: Vector2 = Vector2.ZERO
var _result_label_rest_scale: Vector2
var _result_label_rest_modulate: Color = Color.WHITE

## Single tween for one strike: both roots + defender body move together (one exchange = one timeline).
## Separate _player/_enemy streak tweens stay independent; strike is atomic so we do not split half-motion.
var _strike_pair_tween: Tween = null
var _result_line_tween: Tween = null
var _player_streak_tween: Tween = null
var _enemy_streak_tween: Tween = null


func _ready() -> void:
	_player_base_color = player_body.color
	_enemy_base_color = enemy_body.color
	_result_label_rest_scale = round_result_label.scale
	_result_label_rest_modulate = round_result_label.modulate
	_refresh_body_pivots()
	player_body.resized.connect(_refresh_body_pivots)
	enemy_body.resized.connect(_refresh_body_pivots)
	round_result_label.resized.connect(_on_result_label_resized)
	_on_result_label_resized()
	_connect_buttons()
	await get_tree().process_frame
	_snapshot_fighter_roots()
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _on_viewport_size_changed() -> void:
	# Layout may shift root offsets after resize; refresh rest so tweens and reset stay aligned.
	call_deferred("_snapshot_fighter_roots")


func _snapshot_fighter_roots() -> void:
	_player_root_rest = player_fighter_root.position
	_enemy_root_rest = enemy_fighter_root.position


func _on_result_label_resized() -> void:
	round_result_label.pivot_offset = round_result_label.size / 2.0


func _refresh_body_pivots() -> void:
	player_body.pivot_offset = player_body.size / 2.0
	enemy_body.pivot_offset = enemy_body.size / 2.0


func _connect_buttons() -> void:
	rock_button.pressed.connect(_on_rock_pressed)
	paper_button.pressed.connect(_on_paper_pressed)
	scissors_button.pressed.connect(_on_scissors_pressed)
	restart_button.pressed.connect(_on_restart_pressed)


func _on_rock_pressed() -> void:
	play_button_sfx()
	move_chosen.emit(RoundResolver.Move.ROCK)


func _on_paper_pressed() -> void:
	play_button_sfx()
	move_chosen.emit(RoundResolver.Move.PAPER)


func _on_scissors_pressed() -> void:
	play_button_sfx()
	move_chosen.emit(RoundResolver.Move.SCISSORS)


func _on_restart_pressed() -> void:
	restart_requested.emit()


func play_button_sfx() -> void:
	if button_sfx.stream != null:
		button_sfx.play()


func play_hit_sfx(is_big_hit: bool) -> void:
	if is_big_hit:
		if big_hit_sfx.stream != null:
			big_hit_sfx.play()
	elif hit_sfx.stream != null:
		hit_sfx.play()


func play_win_sfx() -> void:
	if win_sfx.stream != null:
		win_sfx.play()


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
	_pulse_round_result_line()


func show_end_screen(player_won: bool) -> void:
	match_end_label.visible = true
	match_end_label.text = "Player Wins!" if player_won else "Enemy Wins!"
	restart_button.visible = true
	set_controls_locked(true)
	play_win_sfx()


func hide_end_screen() -> void:
	match_end_label.visible = false
	match_end_label.text = ""
	restart_button.visible = false


func set_controls_locked(locked: bool) -> void:
	rock_button.disabled = locked
	paper_button.disabled = locked
	scissors_button.disabled = locked


func reset_visual_state() -> void:
	Engine.time_scale = 1.0
	_kill_strike_pair_tween()
	_kill_result_line_tween()
	_kill_player_streak_tween()
	_kill_enemy_streak_tween()
	player_fighter_root.position = _player_root_rest
	enemy_fighter_root.position = _enemy_root_rest
	player_fighter_root.scale = Vector2.ONE
	enemy_fighter_root.scale = Vector2.ONE
	player_fighter_root.rotation_degrees = 0.0
	enemy_fighter_root.rotation_degrees = 0.0
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
	round_result_label.modulate = _result_label_rest_modulate
	round_result_label.scale = _result_label_rest_scale
	if button_sfx.playing:
		button_sfx.stop()
	if hit_sfx.playing:
		hit_sfx.stop()
	if big_hit_sfx.playing:
		big_hit_sfx.stop()
	if win_sfx.playing:
		win_sfx.stop()


func reset_match_ui() -> void:
	reset_visual_state()
	hide_end_screen()
	show_moves("—", "—")
	round_result_label.text = "Pick Rock, Paper, or Scissors."
	set_controls_locked(false)


func brief_hit_pause() -> void:
	var prev: float = Engine.time_scale
	Engine.time_scale = 0.0
	# With time_scale == 0, SceneTreeTimer must use ignore_time_scale or it never advances (await hangs).
	# Godot 4.4+: create_timer(sec, process_always, process_in_physics, ignore_time_scale)
	await get_tree().create_timer(0.038, true, false, true).timeout
	Engine.time_scale = prev


func flash_player_hit(strength: float = 1.0, damage: int = 0) -> void:
	# Enemy attacked; player is defender (recoils left, enemy lunges right-from-enemy-side = toward center).
	_play_strike_exchange(false, strength, damage)


func flash_enemy_hit(strength: float = 1.0, damage: int = 0) -> void:
	# Player attacked; enemy is defender (recoils right, player lunges toward center).
	_play_strike_exchange(true, strength, damage)


func _play_strike_exchange(player_is_attacker: bool, strength: float, damage: int) -> void:
	_kill_strike_pair_tween()
	var s: float = clampf(strength, 0.2, 1.5)
	# Defender moves more than attacker; keeps motion in a small pixel band.
	var lunge_px: float = 4.0 * s
	var recoil_px: float = 6.8 * s
	var tw := create_tween()
	if player_is_attacker:
		var flash := _enemy_base_color.lerp(Color(1.0, 1.0, 1.0), 0.45 + 0.35 * s)
		var squash := Vector2(1.0 + 0.05 * s, 1.0 - 0.04 * s)
		tw.set_parallel(true)
		tw.tween_property(player_fighter_root, "position", _player_root_rest + Vector2(lunge_px, 0.0), 0.05)
		tw.tween_property(enemy_fighter_root, "position", _enemy_root_rest + Vector2(recoil_px, 0.0), 0.05)
		tw.tween_property(enemy_body, "color", flash, 0.04 * s)
		tw.tween_property(enemy_body, "scale", squash, 0.05)
		tw.tween_property(enemy_body, "rotation_degrees", 3.5 * s, 0.05)
		tw.chain()
		tw.set_parallel(true)
		tw.tween_property(player_fighter_root, "position", _player_root_rest, 0.1)
		tw.tween_property(enemy_fighter_root, "position", _enemy_root_rest, 0.1)
		tw.tween_property(enemy_body, "color", _enemy_base_color, 0.1 + 0.05 * s)
		tw.tween_property(enemy_body, "scale", Vector2.ONE, 0.1)
		tw.tween_property(enemy_body, "rotation_degrees", 0.0, 0.1)
	else:
		var flash := _player_base_color.lerp(Color(1.0, 1.0, 1.0), 0.45 + 0.35 * s)
		var squash := Vector2(1.0 + 0.05 * s, 1.0 - 0.04 * s)
		tw.set_parallel(true)
		tw.tween_property(enemy_fighter_root, "position", _enemy_root_rest + Vector2(-lunge_px, 0.0), 0.05)
		tw.tween_property(player_fighter_root, "position", _player_root_rest + Vector2(-recoil_px, 0.0), 0.05)
		tw.tween_property(player_body, "color", flash, 0.04 * s)
		tw.tween_property(player_body, "scale", squash, 0.05)
		tw.tween_property(player_body, "rotation_degrees", -3.5 * s, 0.05)
		tw.chain()
		tw.set_parallel(true)
		tw.tween_property(enemy_fighter_root, "position", _enemy_root_rest, 0.1)
		tw.tween_property(player_fighter_root, "position", _player_root_rest, 0.1)
		tw.tween_property(player_body, "color", _player_base_color, 0.1 + 0.05 * s)
		tw.tween_property(player_body, "scale", Vector2.ONE, 0.1)
		tw.tween_property(player_body, "rotation_degrees", 0.0, 0.1)
	_strike_pair_tween = tw
	play_hit_sfx(damage >= 15)


func _kill_strike_pair_tween() -> void:
	if _strike_pair_tween != null and is_instance_valid(_strike_pair_tween):
		_strike_pair_tween.kill()
	_strike_pair_tween = null


func _pulse_round_result_line() -> void:
	_kill_result_line_tween()
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(round_result_label, "scale", Vector2(1.06, 1.06), 0.06)
	tw.tween_property(round_result_label, "modulate", Color(1.12, 1.12, 1.08), 0.06)
	tw.chain()
	tw.set_parallel(true)
	tw.tween_property(round_result_label, "scale", _result_label_rest_scale, 0.12)
	tw.tween_property(round_result_label, "modulate", _result_label_rest_modulate, 0.12)
	_result_line_tween = tw


func _kill_result_line_tween() -> void:
	if _result_line_tween != null and is_instance_valid(_result_line_tween):
		_result_line_tween.kill()
	_result_line_tween = null


func pulse_player_streak(streak_value: int = 1) -> void:
	_kill_player_streak_tween()
	_player_streak_tween = _build_streak_pulse_tween(player_streak_label, streak_value)


func pulse_enemy_streak(streak_value: int = 1) -> void:
	_kill_enemy_streak_tween()
	_enemy_streak_tween = _build_streak_pulse_tween(enemy_streak_label, streak_value)


func _build_streak_pulse_tween(lbl: Label, streak_value: int) -> Tween:
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
	return tw


func _kill_player_streak_tween() -> void:
	if _player_streak_tween != null and is_instance_valid(_player_streak_tween):
		_player_streak_tween.kill()
	_player_streak_tween = null


func _kill_enemy_streak_tween() -> void:
	if _enemy_streak_tween != null and is_instance_valid(_enemy_streak_tween):
		_enemy_streak_tween.kill()
	_enemy_streak_tween = null
