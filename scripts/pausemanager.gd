extends Node

var is_paused = false
var pause_menu_scene: PackedScene = preload("res://ui/pause_menu.tscn")
var pause_menu_instance: Control = null

func _ready():
	# Initialize the pause menu instance but do not add it to the tree yet
	pause_menu_instance = pause_menu_scene.instantiate()
	pause_menu_instance.name = "PauseMenu"

func toggle_pause():
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
