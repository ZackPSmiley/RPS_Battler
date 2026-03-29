## All battle HUD updates and player input signals live here.
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
	_connect_buttons()


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


func show_end_screen(player_won: bool) -> void:
	match_end_label.visible = true
	match_end_label.text = "Player Wins!" if player_won else "Enemy Wins!"
	restart_button.visible = true
	toggle_input(false)


func hide_end_screen() -> void:
	match_end_label.visible = false
	match_end_label.text = ""
	restart_button.visible = false


func toggle_input(enabled: bool) -> void:
	rock_button.disabled = not enabled
	paper_button.disabled = not enabled
	scissors_button.disabled = not enabled


## Full UI reset at match start: labels, end-of-match chrome, input on.
func reset_match_ui() -> void:
	hide_end_screen()
	show_moves("—", "—")
	show_result("Pick Rock, Paper, or Scissors.")
	toggle_input(true)
