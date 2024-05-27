extends Node

var player_current_attack = false
var current_scene = "world"
var transition_scene = false

var player_exit_cliffside_posx = 15
var player_exit_cliffside_posy = 219
var player_start_posx = 14
var player_start_posy = 77

var game_first_loadin = true
var game_over = false

var ingame_time = 0.0

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key by default
		Pausemanager.toggle_pause()

func finish_change_scene():
	if transition_scene == true:
		transition_scene = false
		if current_scene == "world":
			current_scene = "cliff_side"
		else:
			current_scene = "world"
			
func reset_game_state():
	game_over = false
	player_current_attack = false
	current_scene = "world"
	transition_scene = false
	player_exit_cliffside_posx = 15
	player_exit_cliffside_posy = 219
	player_start_posx = 14
	player_start_posy = 77
	game_first_loadin = true
	ingame_time = 0.0
