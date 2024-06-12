extends Control

@onready var return_to_menu_button = $MarginContainer/HBoxContainer/VBoxContainer/Return_menu as Button
@onready var respawn_button = $MarginContainer/HBoxContainer/VBoxContainer/Respawn as Button
@onready var main_menu = preload("res://UI/main_menu.tscn") as PackedScene
@onready var player_scene = preload("res://scenes/world.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	respawn_button.button_down.connect(_on_respawn_pressed)
	return_to_menu_button.button_down.connect(_on_return_menu_pressed)

func _on_respawn_pressed():
	var player = find_player()
	if player:
		Global.reset_game_state(player.inv)
	get_tree().change_scene_to_packed(player_scene)


func _on_return_menu_pressed():
	var player = find_player()
	if player:
		Global.reset_game_state(player.inv)
	get_tree().change_scene_to_packed(main_menu)


func find_player():
	var player_scene_instance = player_scene.instantiate()
	var player = player_scene_instance.get_node_or_null("player")
	player_scene_instance.queue_free()
	return player
