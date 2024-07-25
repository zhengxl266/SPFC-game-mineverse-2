extends Node

var is_paused = false
var pause_menu_scene: PackedScene = preload("res://UI/pause_menu.tscn")
var pause_menu_instance: Control = null
var non_game_scenes: Array = ["res://UI/main_menu.tscn", "res://UI/game_over.tscn","res://UI/authentication.tscn"]

func _ready():
	# Initialize the pause menu instance but do not add it to the tree yet
	pause_menu_instance = pause_menu_scene.instantiate()
	pause_menu_instance.name = "PauseMenu"

func toggle_pause():
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
	var current_scene_path = get_tree().current_scene.scene_file_path
	if current_scene_path in non_game_scenes:
		return
	is_paused = !is_paused
	get_tree().paused = is_paused

	if is_paused:
		if not is_instance_valid(pause_menu_instance):
			pause_menu_instance = pause_menu_scene.instantiate()
			pause_menu_instance.name = "PauseMenu"
		if pause_menu_instance.get_parent() == null:
			get_tree().root.add_child(pause_menu_instance)
	else:
		if is_instance_valid(pause_menu_instance) and pause_menu_instance.get_parent() != null:
			pause_menu_instance.queue_free()
			pause_menu_instance = null


func connect_pause_menu_signals(menu_instance):
	menu_instance.resume_button.pressed.connect(menu_instance._on_resume_pressed)
	menu_instance.restart_button.pressed.connect(menu_instance._on_restart_pressed)
	menu_instance.quit_button.pressed.connect(menu_instance._on_quit_pressed)
