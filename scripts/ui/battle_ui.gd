## Central place for battle HUD updates and player input signals.
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


func _ready() -> void:
	restart_button.visible = false
	rock_button.pressed.connect(func() -> void: move_chosen.emit(RoundResolver.Move.ROCK))
	paper_button.pressed.connect(func() -> void: move_chosen.emit(RoundResolver.Move.PAPER))
	scissors_button.pressed.connect(func() -> void: move_chosen.emit(RoundResolver.Move.SCISSORS))
	restart_button.pressed.connect(func() -> void: restart_requested.emit())


func set_hp_display(player_hp: int, enemy_hp: int) -> void:
	player_hp_label.text = "Player HP: %d" % player_hp
	enemy_hp_label.text = "Enemy HP: %d" % enemy_hp


func set_streak_display(player_streak: int, enemy_streak: int) -> void:
	player_streak_label.text = "Player streak: %d" % player_streak
	enemy_streak_label.text = "Enemy streak: %d" % enemy_streak


func set_move_labels(player_move: String, enemy_move: String) -> void:
	player_move_label.text = "Your move: %s" % player_move
	enemy_move_label.text = "Enemy move: %s" % enemy_move


func set_round_result(text: String) -> void:
	round_result_label.text = text


func set_match_end(visible: bool, message: String = "") -> void:
	match_end_label.visible = visible
	if visible:
		match_end_label.text = message


func set_choice_buttons_enabled(enabled: bool) -> void:
	rock_button.disabled = not enabled
	paper_button.disabled = not enabled
	scissors_button.disabled = not enabled


func show_restart(visible: bool) -> void:
	restart_button.visible = visible
