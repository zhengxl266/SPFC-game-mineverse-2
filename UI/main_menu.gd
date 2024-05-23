class_name Mainmenu
extends Control

@onready var start = $MarginContainer/HBoxContainer/VBoxContainer/Start as Button
@onready var quit = $MarginContainer/HBoxContainer/VBoxContainer/Quit as Button
@onready var start_level = preload("res://scenes/world.tscn") as PackedScene


func _ready():
	start.button_down.connect(on_start_pressed)
	quit.button_down.connect(on_quit_pressed)


func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
	
func on_quit_pressed() -> void:
	get_tree().quit()
	

