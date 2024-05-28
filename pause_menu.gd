extends Control

@onready var resume_button = $MarginContainer/HBoxContainer/VBoxContainer/RESUME as Button
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/QUIT as Button
@onready var restart_button = $MarginContainer/HBoxContainer/VBoxContainer/RESTART as Button
# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _on_resume_pressed():
	#get_tree().paused = false
	Pausemanager.toggle_pause()
	queue_free()  

func _on_restart_pressed():
	get_tree().reload_current_scene()
	Global.reset_game_state()
	Pausemanager.toggle_pause()

func _on_quit_pressed():
	get_tree().quit()





