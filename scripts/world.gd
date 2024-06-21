extends Node2D

@onready var pause_menu_scene: PackedScene = preload("res://UI/pause_menu.tscn")
@onready var canvas_layer = $CanvasLayer
@onready var daynight_ui = $CanvasLayer/DayNightCycleUI
var night_music_playing = false
var enemy = preload("res://scenes/enemy.tscn")
const world_width = 450
const world_height = 200
const min_enemies = 1
const max_enemies = 3


const PLAYER_START_POS = Vector2(14, 77)
const PLAYER_EXIT_CLIFFSIDE_POS = Vector2(15, 219)
const PLAYER_EXIT_GRASS_TO_SNOW_POS = Vector2(459, 164)

func _ready():
	randomize()
	var num_enemies = randi_range(min_enemies, max_enemies)
	for i in range(num_enemies):
		inst(Vector2(randf_range(30, world_width), randf_range(90, world_height)))
	BgmGlobal.play_music_level()
	
	set_player_position_based_on_previous_scene()
	
	canvas_layer.visible = true
	var canvas_modulate = $CanvasModulate
	canvas_modulate.time_tick.connect(daynight_ui.set_daytime)
	canvas_modulate.connect("time_tick", Callable(self, "_on_time_tick"))

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key by default
		Pausemanager.toggle_pause()

func _process(delta):
	change_scene()

func _on_cliffside_portal_body_entered(body):
	if body.has_method("player"):
		Global.previous_scene = "world"
		Global.transition_scene = true
		Global.target_scene = "cliff_side"

func _on_grass_to_snow_portal_body_entered(body):
	if body.has_method("player"):
		Global.previous_scene = "world"
		Global.transition_scene = true
		Global.target_scene = "grass_to_snow"

func change_scene():
	if Global.transition_scene:
		get_tree().change_scene_to_file("res://scenes/" + Global.target_scene + ".tscn")
		Global.game_first_loadin = false
		Global.finish_change_scene()

func _on_time_tick(day, hour, minute):
	if (hour >= 18 or hour < 6) and not night_music_playing:
		BgmGlobal.play_music_night()
		night_music_playing = true
	elif (hour < 18 and hour >= 6) and night_music_playing:
		BgmGlobal.play_music_level()
		night_music_playing = false

func inst(pos):
	var instance = enemy.instantiate()
	instance.position = pos
	add_child(instance)

func set_player_position(pos: Vector2):
	$player.position = pos
	$player.respawn_position = pos

func set_player_position_based_on_previous_scene():
	print("Setting player position based on previous scene:", Global.previous_scene)
	match Global.previous_scene:
		"cliff_side":
			set_player_position(PLAYER_EXIT_CLIFFSIDE_POS)
		"grass_to_snow":
			set_player_position(PLAYER_EXIT_GRASS_TO_SNOW_POS)
		_:
			if Global.game_first_loadin:
				set_player_position(PLAYER_START_POS)
			else:
				# Default to grass_to_snow exit position
				set_player_position(PLAYER_EXIT_GRASS_TO_SNOW_POS)
	print("Player position set to:", $player.position)




