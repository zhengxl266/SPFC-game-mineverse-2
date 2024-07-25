extends Node2D

@onready var canvas_layer = $CanvasLayer
@onready var daynight_ui = $CanvasLayer/DayNightCycleUI
var night_music_playing = false

var enemy = preload("res://scenes/enemy.tscn")

const world_width = 470
const world_height = 280

const min_enemies = 2
const max_enemies = 4

const PLAYER_ENTRY_FROM_SNOWMAP = Vector2(14, 178)
const PLAYER_ENTRY_FROM_DESERTMAP = Vector2(450, 100)

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

func _on_portal_to_snowmap_body_entered(body):
	if body.has_method("player"):
		Global.player_exit_snow_to_desert_posx = PLAYER_ENTRY_FROM_SNOWMAP.x
		Global.player_exit_snow_to_desert_posy = PLAYER_ENTRY_FROM_SNOWMAP.y
		call_deferred("_defer_scene_transition")


func _defer_scene_transition():
	Global.transition_scene = true
	Global.previous_scene = "snow_to_desert"
	Global.target_scene = "snowmap"
	get_tree().change_scene_to_file("res://scenes/snowmap.tscn")
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


func _on_snow_to_dessert_to_dessertmap_body_entered(body):
	if body.has_method("player"):
		Global.player_exit_snow_to_desert_posx = PLAYER_ENTRY_FROM_DESERTMAP.x
		Global.player_exit_snow_to_desert_posy = PLAYER_ENTRY_FROM_DESERTMAP.y
		call_deferred("_defer_scene_transition_to_desert")

	
func _defer_scene_transition_to_desert():
	Global.transition_scene = true
	Global.previous_scene = "snow_to_desert"
	Global.target_scene = "desertmap"
	get_tree().change_scene_to_file("res://scenes/desertmap.tscn")
	Global.game_first_loadin = false
	Global.finish_change_scene()
	
	
	
func set_player_position_entry_point():
	if Global.previous_scene == "snowmap":
		set_player_position(PLAYER_ENTRY_FROM_SNOWMAP)
	elif Global.previous_scene == "desertmap":
		set_player_position(PLAYER_ENTRY_FROM_DESERTMAP)
		


func set_player_position(pos: Vector2):
	$player.position = pos
	$player.respawn_position = pos


