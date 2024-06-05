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

func _ready():
	randomize()
	var num_enemies = randi_range(min_enemies,max_enemies)
	for i in range(num_enemies):
		inst(Vector2(randf_range(30,world_width),randf_range(90,world_height)))
	BgmGlobal.play_music_level()
	if Global.game_first_loadin == true:
		$player.position.x = Global.player_start_posx
		$player.position.y = Global.player_start_posy
		$player.respawn_position = Vector2(Global.player_start_posx, Global.player_start_posy)
	else:
		$player.position.x = Global.player_exit_cliffside_posx
		$player.position.y = Global.player_exit_cliffside_posy
		$player.respawn_position = Vector2(Global.player_exit_cliffside_posx, Global.player_exit_cliffside_posy)
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
		Global.transition_scene = true


func change_scene():
	if Global.transition_scene == true:
		if Global.current_scene == "world":
			get_tree().change_scene_to_file("res://scenes/cliff_side.tscn")
			Global.game_first_loadin = false
			Global.finish_change_scene()
			
func _on_time_tick(day,hour,minute):
	if (hour >= 18 or hour < 6) and !night_music_playing:
		BgmGlobal.play_music_night()
		night_music_playing = true
	elif (hour <18 and hour >=6) and night_music_playing:
		BgmGlobal.play_music_level()
		night_music_playing = false

func inst(pos):
	var instance = enemy.instantiate()
	instance.position = pos
	add_child(instance)
	
