extends Node

var player_current_attack = false
var current_scene = "world"
var transition_scene = false

var player_exit_cliffside_posx = 15
var player_exit_cliffside_posy = 219
var player_start_posx = 14
var player_start_posy = 77
var player_exit_grass_to_snow_posx = 459
var player_exit_grass_to_snow_posy = 164
var player_exit_snowmap_posx = 16
var player_exit_snowmap_posy = 178
var player_exit_snow_to_desert_posx = 440
var player_exit_snow_to_desert_posy = 150
var player_exit_desertmap_posx = 440
var player_exit_desertmap_posy = 100

var target_scene = ""
var previous_scene = ""

var game_first_loadin = true
var game_over = false

var ingame_time = 0.0

var player_level = 1

func _ready():
	PlayerStats.player_leveled_up.connect(_on_player_level_changed)

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		Pausemanager.toggle_pause()

func finish_change_scene():
	if transition_scene:
		transition_scene = false
		previous_scene = current_scene
		current_scene = target_scene
		print("Transition complete. New current_scene: ", current_scene)

func _on_player_level_changed(new_level):
	player_level = new_level

func reset_game_state(player_inventory: Inv):
	game_over = false
	player_current_attack = false
	current_scene = "world"
	transition_scene = false
	player_exit_grass_to_snow_posx = 459
	player_exit_grass_to_snow_posy = 164
	player_exit_cliffside_posx = 15
	player_exit_cliffside_posy = 219
	player_start_posx = 14
	player_start_posy = 77
	game_first_loadin = true
	ingame_time = 0.0
	PlayerStats.level = 1
	PlayerStats.current_xp = 0
	clear_player_inventory(player_inventory)

func set_player_level(level):
	PlayerStats.level = level

func clear_player_inventory(inventory: Inv):
	for slot in inventory.slots:
		slot.item = null
		slot.amount = 0
	inventory.update.emit()





