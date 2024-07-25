extends Node2D

@onready var canvas_layer = $CanvasLayer
@onready var daynight_ui = $CanvasLayer/DayNightCycleUI
var night_music_playing = false

var enemy = preload("res://scenes/enemy.tscn")

const world_width = 470
const world_height = 280

const min_enemies = 2
const max_enemies = 4

const PLAYER_EXIT_GRASS_TO_SNOW = Vector2(14, 178)
const PLAYER_EXIT_SNOW_TO_DESERT = Vector2(450, 100) 


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

func _on_snowmap_to_grass_to_snow_body_entered(body):
	if body.has_method("player"):
		Global.player_exit_snowmap_posx = body.position.x
		Global.player_exit_snowmap_posy = body.position.y
		call_deferred("_defer_scene_transition")

func _defer_scene_transition():
	Global.transition_scene = true
	Global.previous_scene = "snowmap"
	Global.target_scene = "grass_to_snow"
	get_tree().change_scene_to_file("res://scenes/grass_to_snow.tscn")
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




func _on_snowmap_to_snow_to_desert_body_entered(body):
	if body.has_method("player"):
		Global.player_exit_snowmap_posx = PLAYER_EXIT_SNOW_TO_DESERT.x
		Global.player_exit_snowmap_posy = PLAYER_EXIT_SNOW_TO_DESERT.y
		call_deferred("_defer_scene_transition_to_desert")
	
func _defer_scene_transition_to_desert():
	Global.transition_scene = true
	Global.previous_scene = "snowmap"
	Global.target_scene = "snow_to_desert"
	get_tree().change_scene_to_file("res://scenes/snow_to_desert.tscn")
	Global.game_first_loadin = false
	Global.finish_change_scene()
	
	
	
func set_player_position_entry_point():
	if Global.previous_scene == "grass_to_snow":
		set_player_position(PLAYER_EXIT_GRASS_TO_SNOW)
	elif Global.previous_scene == "snow_to_desert":
		set_player_position(PLAYER_EXIT_SNOW_TO_DESERT)
		

func set_player_position(pos: Vector2):
	$player.position = pos
	$player.respawn_position = pos

func set_player_position_based_on_previous_scene():
	match Global.previous_scene:
		"grass_to_snow":
			set_player_position(PLAYER_EXIT_GRASS_TO_SNOW)
		"snow_to_desert":
			set_player_position(PLAYER_EXIT_SNOW_TO_DESERT)
