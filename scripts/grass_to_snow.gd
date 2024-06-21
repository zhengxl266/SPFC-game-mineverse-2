extends Node2D

@onready var canvas_layer = $CanvasLayer
@onready var daynight_ui = $CanvasLayer/DayNightCycleUI
var night_music_playing = false
var enemy = preload("res://scenes/enemy.tscn")
const world_width = 470
const world_height = 280
const min_enemies = 2
const max_enemies = 4

func _ready():
	set_player_position_entry_point()
	
	randomize()
	var num_enemies = randi_range(min_enemies, max_enemies)
	for i in range(num_enemies):
		inst(Vector2(randf_range(30, world_width), randf_range(90, world_height)))
	
	var canvas_modulate = $CanvasModulate
	canvas_modulate.time_tick.connect(daynight_ui.set_daytime)
	canvas_modulate.connect("time_tick", Callable(self, "_on_time_tick"))

func _process(delta):
	pass

func _on_portal_to_world_body_entered(body):
	if body.has_method("player"):
		Global.player_exit_grass_to_snow_posx = body.position.x
		Global.player_exit_grass_to_snow_posy = body.position.y
		call_deferred("_defer_scene_transition_to_world")

func _defer_scene_transition_to_world():
	Global.transition_scene = true
	Global.target_scene = "world"
	get_tree().change_scene_to_file("res://scenes/world.tscn")
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

func _on_grass_to_snow_to_snowmap_body_entered(body):
	if body.has_method("player"):
		call_deferred("_defer_scene_transition_to_snowmap")

func _defer_scene_transition_to_snowmap():
	Global.transition_scene = true
	Global.target_scene = "snowmap"
	get_tree().change_scene_to_file("res://scenes/snowmap.tscn")
	Global.game_first_loadin = false
	Global.finish_change_scene()

func set_player_position_entry_point():
	if Global.previous_scene == "world":
		$player.position = Vector2(14, 178)
	elif Global.previous_scene == "snowmap":
		$player.position = Vector2(450, 100)  # Adjust these coordinates as needed
	else:
		print("Unexpected previous scene:", Global.previous_scene)
		$player.position = Vector2(Global.player_exit_grass_to_snow_posx, Global.player_exit_grass_to_snow_posy)

# Add this function to handle any input if needed
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key by default
		Pausemanager.toggle_pause()
		
